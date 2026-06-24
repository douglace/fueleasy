<?php

declare(strict_types=1);

namespace Tests\Feature\DriverBudgets;

use App\Application\DriverBudgets\ResetDriverBudget;
use App\Application\DriverBudgets\SetDriverBudget;
use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Shared\Money;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use Tests\TestCase;

class DriverBudgetTest extends TestCase
{
    use RefreshDatabase;

    public function test_setting_a_budget_replaces_the_balance(): void
    {
        $driver = User::factory()->driver()->create();

        $budget = app(SetDriverBudget::class)->handle($driver, BudgetMode::Manual, Money::fromInt(50_000));

        $this->assertSame(50_000, $budget->amount);
        $this->assertSame(50_000, $budget->balance);
        $this->assertNull($budget->next_reset_at);

        // Spend some, then re-set: balance is replaced, not added.
        $budget->update(['balance' => 12_000]);
        $updated = app(SetDriverBudget::class)->handle($driver, BudgetMode::Manual, Money::fromInt(50_000));

        $this->assertSame(50_000, $updated->balance);
        $this->assertSame(1, DriverBudget::query()->count());
    }

    public function test_reset_replaces_remaining_balance_with_allocation(): void
    {
        $driver = User::factory()->driver()->create();
        $budget = DriverBudget::factory()->forDriver($driver)->create([
            'mode' => BudgetMode::Weekly,
            'amount' => 40_000,
            'balance' => 9_000,
        ]);

        $reset = app(ResetDriverBudget::class)->handle($budget);

        $this->assertSame(40_000, $reset->balance);
        $this->assertNotNull($reset->next_reset_at);
        $this->assertDatabaseHas('audit_logs', ['action' => 'driver_budget.reset']);
    }

    public function test_periodic_modes_compute_a_next_reset_date(): void
    {
        $driver = User::factory()->driver()->create();

        $weekly = app(SetDriverBudget::class)->handle($driver, BudgetMode::Weekly, Money::fromInt(30_000));
        $this->assertNotNull($weekly->next_reset_at);
        $this->assertEqualsWithDelta(
            now()->addWeek()->timestamp,
            $weekly->next_reset_at->timestamp,
            5,
        );
    }

    public function test_over_allocation_is_allowed_across_drivers(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        FuelAccount::factory()->create(['organization_id' => $enterprise->id, 'balance' => 50_000]);

        $driverA = User::factory()->driver($enterprise)->create();
        $driverB = User::factory()->driver($enterprise)->create();

        // Somme des budgets (80 000) > solde entreprise (50 000) : autorisé.
        app(SetDriverBudget::class)->handle($driverA, BudgetMode::Manual, Money::fromInt(40_000));
        app(SetDriverBudget::class)->handle($driverB, BudgetMode::Manual, Money::fromInt(40_000));

        $this->assertSame(80_000, (int) DriverBudget::query()->sum('amount'));
    }

    public function test_budget_can_only_be_assigned_to_a_driver(): void
    {
        $pompiste = User::factory()->pompiste()->create();

        $this->expectException(InvalidArgumentException::class);

        app(SetDriverBudget::class)->handle($pompiste, BudgetMode::Manual, Money::fromInt(10_000));
    }
}
