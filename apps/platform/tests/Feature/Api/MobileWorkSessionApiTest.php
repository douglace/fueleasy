<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Application\Identity\DeviceTokenIssuer;
use App\Domain\Stations\PumpStatus;
use App\Domain\Stations\WorkSessionStatus;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class MobileWorkSessionApiTest extends TestCase
{
    use RefreshDatabase;

    private function tokenFor(User $user, string $deviceId = 'dev-1'): string
    {
        return app(DeviceTokenIssuer::class)->issue($user, $deviceId);
    }

    public function test_pompiste_lists_active_pumps_of_their_own_station(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->pompiste);

        $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk()
            ->assertJsonPath('data.0.id', $s->pump->id)
            ->assertJsonPath('data.0.label', $s->pump->label)
            ->assertJsonPath('data.0.available_fuels', ['gasoil', 'super']);
    }

    public function test_inactive_pumps_are_excluded(): void
    {
        $s = new PaymentScenario;
        Pump::factory()->create([
            'organization_id' => $s->station->id,
            'status' => PumpStatus::Inactive,
        ]);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk();

        $this->assertCount(1, $response->json('data'));
    }

    public function test_pumps_from_another_station_are_not_visible(): void
    {
        $s = new PaymentScenario;
        $otherStation = Organization::factory()->station()->create();
        Pump::factory()->create(['organization_id' => $otherStation->id]);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk();

        $this->assertCount(1, $response->json('data'));
        $this->assertSame($s->pump->id, $response->json('data.0.id'));
    }

    public function test_a_driver_cannot_list_station_pumps(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertForbidden();
    }

    /**
     * Paie un montant sur une pompe de la station du scénario, aujourd'hui.
     */
    private function paidPaymentOn(PaymentScenario $s, Pump $pump, int $amount): Payment
    {
        return Payment::factory()->paid()->create([
            'organization_id' => $s->enterprise->id,
            'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id,
            'pump_id' => $pump->id,
            'amount' => $amount,
        ]);
    }

    public function test_todays_payments_default_to_the_pump_of_the_open_session(): void
    {
        $s = new PaymentScenario;
        $otherPump = Pump::factory()->create(['organization_id' => $s->station->id]);
        $onMyPump = $this->paidPaymentOn($s, $s->pump, 10_000);
        $this->paidPaymentOn($s, $otherPump, 20_000);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/payments/today')
            ->assertOk()
            ->assertJsonPath('scope', 'pump')
            ->assertJsonPath('pump_id', $s->pump->id);

        $this->assertCount(1, $response->json('data'));
        $this->assertSame($onMyPump->id, $response->json('data.0.id'));
    }

    public function test_station_scope_returns_all_pumps_of_the_station(): void
    {
        $s = new PaymentScenario;
        $otherPump = Pump::factory()->create(['organization_id' => $s->station->id]);
        $this->paidPaymentOn($s, $s->pump, 10_000);
        $this->paidPaymentOn($s, $otherPump, 20_000);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)
            ->getJson('/api/v1/mobile/station/payments/today?scope=station')
            ->assertOk()
            ->assertJsonPath('scope', 'station')
            ->assertJsonPath('pump_id', null);

        $this->assertCount(2, $response->json('data'));
    }

    public function test_pump_scope_falls_back_to_station_without_an_open_session(): void
    {
        $s = new PaymentScenario;
        $s->workSession->update(['status' => WorkSessionStatus::Closed]);
        $this->paidPaymentOn($s, $s->pump, 10_000);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/payments/today')
            ->assertOk()
            ->assertJsonPath('scope', 'station')
            ->assertJsonPath('pump_id', null);

        $this->assertCount(1, $response->json('data'));
    }

    public function test_todays_payments_never_leak_another_station(): void
    {
        $s = new PaymentScenario;
        $other = new PaymentScenario;
        $this->paidPaymentOn($other, $other->pump, 50_000);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)
            ->getJson('/api/v1/mobile/station/payments/today?scope=station')
            ->assertOk();

        $this->assertCount(0, $response->json('data'));
    }
}
