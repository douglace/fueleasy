<?php

declare(strict_types=1);

namespace Tests\Feature\Web;

use App\Application\Identity\DeviceTokenIssuer;
use App\Domain\Organizations\OrganizationStatus;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

/**
 * Suspension / réactivation d'organisation par l'admin Fusy, vue station
 * et filtres de transactions.
 */
class AdminOrganizationStatusTest extends TestCase
{
    use RefreshDatabase;

    private function mobileToken(User $user): string
    {
        return app(DeviceTokenIssuer::class)->issue($user, 'dev-1');
    }

    public function test_admin_suspends_then_reactivates_an_organization(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;

        $this->actingAs($admin)
            ->post("/admin/organizations/{$s->enterprise->id}/toggle-status")
            ->assertRedirect();

        $this->assertSame(OrganizationStatus::Suspended, $s->enterprise->fresh()->status);
        $this->assertDatabaseHas('audit_logs', ['action' => 'organization.status_changed']);

        $this->actingAs($admin)
            ->post("/admin/organizations/{$s->enterprise->id}/toggle-status")
            ->assertRedirect();

        $this->assertSame(OrganizationStatus::Active, $s->enterprise->fresh()->status);
    }

    public function test_a_suspended_enterprise_blocks_payment_creation(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;
        $this->actingAs($admin)->post("/admin/organizations/{$s->enterprise->id}/toggle-status");

        $this->withToken($this->mobileToken($s->driver))
            ->postJson('/api/v1/mobile/payments', [
                'code' => $s->pump->code,
                'fuel_type' => 'gasoil',
                'amount' => 10_000,
            ])->assertUnprocessable()->assertJsonPath('reason', 'organization_inactive');
    }

    public function test_a_suspended_station_blocks_payment_creation(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;
        $this->actingAs($admin)->post("/admin/organizations/{$s->station->id}/toggle-status");

        $this->withToken($this->mobileToken($s->driver))
            ->postJson('/api/v1/mobile/payments', [
                'code' => $s->pump->code,
                'fuel_type' => 'gasoil',
                'amount' => 10_000,
            ])->assertUnprocessable()->assertJsonPath('reason', 'station_inactive');
    }

    public function test_reactivation_restores_payments(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;
        $this->actingAs($admin)->post("/admin/organizations/{$s->enterprise->id}/toggle-status");
        $this->actingAs($admin)->post("/admin/organizations/{$s->enterprise->id}/toggle-status");

        $this->withToken($this->mobileToken($s->driver))
            ->postJson('/api/v1/mobile/payments', [
                'code' => $s->pump->code,
                'fuel_type' => 'gasoil',
                'amount' => 10_000,
            ])->assertCreated();
    }

    public function test_station_detail_page_shows_pumps_and_pompistes(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;

        $this->actingAs($admin)->get("/admin/stations/{$s->station->id}")
            ->assertOk()
            ->assertInertia(fn ($page) => $page
                ->component('admin/station-detail')
                ->where('station.id', $s->station->id)
                ->where('pumps.0.code', $s->pump->code)
                ->where('pompistes.0.id', $s->pompiste->id));
    }

    public function test_station_detail_rejects_an_enterprise(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;

        $this->actingAs($admin)->get("/admin/stations/{$s->enterprise->id}")
            ->assertNotFound();
    }

    public function test_station_detail_is_admin_only(): void
    {
        $s = new PaymentScenario;
        $enterpriseAdmin = User::factory()->enterpriseAdmin($s->enterprise)->create();

        $this->actingAs($enterpriseAdmin)->get("/admin/stations/{$s->station->id}")
            ->assertForbidden();
    }

    public function test_transactions_can_be_filtered_by_status_enterprise_station_and_code(): void
    {
        $admin = User::factory()->fusyAdmin()->create();
        $s = new PaymentScenario;
        $other = new PaymentScenario;

        $paid = Payment::factory()->paid()->create([
            'organization_id' => $s->enterprise->id,
            'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id,
            'pump_id' => $s->pump->id,
        ]);
        Payment::factory()->create([
            'organization_id' => $other->enterprise->id,
            'driver_id' => $other->driver->id,
            'station_organization_id' => $other->station->id,
            'pump_id' => $other->pump->id,
        ]);

        $this->actingAs($admin)
            ->get("/admin/transactions?status=paid&enterprise_id={$s->enterprise->id}&station_id={$s->station->id}")
            ->assertOk()
            ->assertInertia(fn ($page) => $page
                ->component('admin/transactions')
                ->count('payments', 1)
                ->where('payments.0.id', $paid->id)
                ->where('filters.status', 'paid'));

        $this->actingAs($admin)
            ->get('/admin/transactions?q='.strtolower($paid->short_code))
            ->assertOk()
            ->assertInertia(fn ($page) => $page
                ->count('payments', 1)
                ->where('payments.0.id', $paid->id));
    }
}
