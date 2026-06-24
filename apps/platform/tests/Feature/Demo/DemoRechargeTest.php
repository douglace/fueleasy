<?php

declare(strict_types=1);

namespace Tests\Feature\Demo;

use App\Application\Demo\DemoRechargeService;
use App\Domain\Demo\DemoProvider;
use App\Domain\Demo\DemoRechargeStatus;
use App\Domain\Shared\DomainException;
use App\Domain\Shared\Money;
use App\Models\FuelAccount;
use App\Models\Organization;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DemoRechargeTest extends TestCase
{
    use RefreshDatabase;

    public function test_successful_demo_recharge_credits_the_demo_balance(): void
    {
        $demo = Organization::factory()->enterprise()->demo()->create();
        FuelAccount::factory()->create(['organization_id' => $demo->id, 'balance' => 0]);

        $service = app(DemoRechargeService::class);
        $recharge = $service->initiate($demo, DemoProvider::OrangeMoney, Money::fromInt(100_000), '+237699000000');
        $this->assertSame(DemoRechargeStatus::Pending, $recharge->status);

        $settled = $service->settle($recharge, DemoRechargeStatus::Successful);

        $this->assertSame(DemoRechargeStatus::Successful, $settled->status);
        $this->assertSame(100_000, FuelAccount::query()->where('organization_id', $demo->id)->value('balance'));
        $this->assertDatabaseHas('ledger_entries', ['reference_type' => 'demo_recharge', 'amount' => 100_000]);
    }

    public function test_failed_demo_recharge_does_not_credit(): void
    {
        $demo = Organization::factory()->enterprise()->demo()->create();
        FuelAccount::factory()->create(['organization_id' => $demo->id, 'balance' => 0]);

        $service = app(DemoRechargeService::class);
        $recharge = $service->initiate($demo, DemoProvider::MtnMomo, Money::fromInt(50_000));
        $settled = $service->settle($recharge, DemoRechargeStatus::Failed);

        $this->assertSame(DemoRechargeStatus::Failed, $settled->status);
        $this->assertSame(0, FuelAccount::query()->where('organization_id', $demo->id)->value('balance'));
    }

    public function test_demo_recharge_is_forbidden_on_a_real_organization(): void
    {
        $real = Organization::factory()->enterprise()->create(['is_demo' => false]);

        $this->expectException(DomainException::class);
        app(DemoRechargeService::class)->initiate($real, DemoProvider::OrangeMoney, Money::fromInt(10_000));
    }

    public function test_ussd_provider_is_supported(): void
    {
        $demo = Organization::factory()->enterprise()->demo()->create();
        FuelAccount::factory()->create(['organization_id' => $demo->id, 'balance' => 0]);

        $service = app(DemoRechargeService::class);
        $recharge = $service->initiate($demo, DemoProvider::Ussd, Money::fromInt(25_000));
        $service->settle($recharge, DemoRechargeStatus::Successful);

        $this->assertSame(25_000, FuelAccount::query()->where('organization_id', $demo->id)->value('balance'));
    }

    public function test_a_recharge_cannot_be_settled_twice(): void
    {
        $demo = Organization::factory()->enterprise()->demo()->create();
        FuelAccount::factory()->create(['organization_id' => $demo->id, 'balance' => 0]);

        $service = app(DemoRechargeService::class);
        $recharge = $service->initiate($demo, DemoProvider::OrangeMoney, Money::fromInt(10_000));
        $service->settle($recharge, DemoRechargeStatus::Successful);

        $this->expectException(DomainException::class);
        $service->settle($recharge, DemoRechargeStatus::Successful);
    }
}
