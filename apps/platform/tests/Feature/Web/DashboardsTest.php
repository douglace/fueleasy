<?php

declare(strict_types=1);

namespace Tests\Feature\Web;

use App\Domain\Identity\Role;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class DashboardsTest extends TestCase
{
    use RefreshDatabase;

    public function test_fusy_admin_can_onboard_an_enterprise_with_admin_and_account(): void
    {
        $admin = User::factory()->fusyAdmin()->create();

        $this->actingAs($admin)->get('/dashboard')->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component('admin/dashboard'));

        $this->actingAs($admin)->post('/admin/organizations', [
            'type' => 'enterprise',
            'name' => 'Transport Sud',
            'admin_name' => 'Awa',
            'admin_email' => 'awa@example.com',
            'admin_password' => 'password123',
        ])->assertRedirect();

        $org = Organization::query()->where('name', 'Transport Sud')->firstOrFail();
        $this->assertSame('enterprise', $org->type->value);
        $this->assertDatabaseHas('fuel_accounts', ['organization_id' => $org->id]);
        $this->assertDatabaseHas('users', ['email' => 'awa@example.com', 'role' => Role::EnterpriseAdmin->value]);
    }

    public function test_fusy_admin_can_credit_a_fuel_account(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $enterprise = Organization::factory()->enterprise()->create();
        FuelAccount::factory()->create(['organization_id' => $enterprise->id, 'balance' => 0]);

        $this->actingAs($admin)->post('/admin/fuel-credits', [
            'organization_id' => $enterprise->id, 'amount' => 500_000,
        ])->assertRedirect();

        $this->assertSame(500_000, (int) FuelAccount::query()->where('organization_id', $enterprise->id)->value('balance'));
    }

    public function test_enterprise_admin_is_isolated_from_admin_area(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();

        $this->actingAs($admin)->get('/dashboard')->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component('enterprise/dashboard'));

        $this->actingAs($admin)->get('/admin')->assertForbidden();
        $this->actingAs($admin)->get('/station')->assertForbidden();
    }

    public function test_enterprise_admin_creates_driver_and_sets_budget(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        FuelAccount::factory()->create(['organization_id' => $enterprise->id, 'balance' => 0]);
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();

        $this->actingAs($admin)->post('/enterprise/drivers', ['name' => 'Boris'])->assertRedirect();
        $driver = User::query()->where('organization_id', $enterprise->id)->where('role', Role::Driver)->firstOrFail();
        $this->assertTrue($driver->pin_is_temporary);

        $this->actingAs($admin)->post("/enterprise/drivers/{$driver->id}/budget", [
            'mode' => 'weekly', 'amount' => 60_000,
        ])->assertRedirect();

        $this->assertSame(60_000, DriverBudget::query()->where('user_id', $driver->id)->value('balance'));
    }

    public function test_enterprise_admin_cannot_manage_another_orgs_driver(): void
    {
        $orgA = Organization::factory()->enterprise()->create();
        $orgB = Organization::factory()->enterprise()->create();
        $adminA = User::factory()->enterpriseAdmin($orgA)->create();
        $driverB = User::factory()->driver($orgB)->create();

        $this->actingAs($adminA)->post("/enterprise/drivers/{$driverB->id}/budget", [
            'mode' => 'manual', 'amount' => 10_000,
        ])->assertForbidden();
    }

    public function test_station_admin_creates_pump_and_pompiste_and_requests_refund(): void
    {
        $s = new PaymentScenario;
        $stationAdmin = User::factory()->stationAdmin($s->station)->create();

        $this->actingAs($stationAdmin)->get('/dashboard')->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component('station/dashboard'));

        $this->actingAs($stationAdmin)->post('/station/pumps', [
            'label' => 'Pompe 7', 'available_fuels' => ['gasoil'],
        ])->assertRedirect();
        $this->assertDatabaseHas('pumps', ['organization_id' => $s->station->id, 'label' => 'Pompe 7']);

        $this->actingAs($stationAdmin)->post('/station/pompistes', ['name' => 'Eric'])->assertRedirect();
        $this->assertDatabaseHas('users', ['organization_id' => $s->station->id, 'name' => 'Eric', 'role' => Role::Pompiste->value]);

        // Paiement réglé puis demande de remboursement.
        $payment = Payment::factory()->paid()->create([
            'organization_id' => $s->enterprise->id, 'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id, 'pump_id' => $s->pump->id, 'amount' => 10_000,
        ]);
        $this->actingAs($stationAdmin)->post("/station/payments/{$payment->id}/refund", ['reason' => 'Erreur'])->assertRedirect();
        $this->assertDatabaseHas('refund_requests', ['payment_id' => $payment->id, 'status' => 'pending']);
    }

    public function test_pump_creation_is_isolated_per_station(): void
    {
        $stationA = Organization::factory()->station()->create();
        $stationB = Organization::factory()->station()->create();
        $adminA = User::factory()->stationAdmin($stationA)->create();
        $foreignPump = Pump::factory()->create(['organization_id' => $stationB->id]);

        $this->actingAs($adminA)->post("/station/pumps/{$foreignPump->id}/toggle-qr")->assertForbidden();
    }
}
