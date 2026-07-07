<?php

declare(strict_types=1);

namespace Tests\Feature\Web;

use App\Models\Organization;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Édition des fiches chauffeur (entreprise) et pompiste (station).
 */
class AccountEditTest extends TestCase
{
    use RefreshDatabase;

    public function test_enterprise_admin_updates_a_driver_profile(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();
        $driver = User::factory()->driver($enterprise)->create();

        $this->actingAs($admin)->patch("/enterprise/drivers/{$driver->id}", [
            'name' => 'Nouveau Nom',
            'phone' => '+237600000001',
            'matricule' => 'TS-042',
        ])->assertRedirect();

        $driver->refresh();
        $this->assertSame('Nouveau Nom', $driver->name);
        $this->assertSame('+237600000001', $driver->phone);
        $this->assertSame('TS-042', $driver->matricule);
        $this->assertDatabaseHas('audit_logs', ['action' => 'mobile_account.updated']);
    }

    public function test_duplicate_phone_in_the_same_organization_is_rejected(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();
        User::factory()->driver($enterprise)->create(['phone' => '+237600000002']);
        $driver = User::factory()->driver($enterprise)->create(['phone' => '+237600000003']);

        $this->actingAs($admin)->from('/enterprise/drivers')
            ->patch("/enterprise/drivers/{$driver->id}", [
                'name' => $driver->name,
                'phone' => '+237600000002',
            ])->assertSessionHasErrors(['phone']);
    }

    public function test_the_same_phone_in_another_organization_is_allowed(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $otherOrg = Organization::factory()->enterprise()->create();
        User::factory()->driver($otherOrg)->create(['phone' => '+237600000004']);

        $admin = User::factory()->enterpriseAdmin($enterprise)->create();
        $driver = User::factory()->driver($enterprise)->create();

        $this->actingAs($admin)->patch("/enterprise/drivers/{$driver->id}", [
            'name' => $driver->name,
            'phone' => '+237600000004',
        ])->assertRedirect()->assertSessionHasNoErrors();
    }

    public function test_an_admin_cannot_edit_a_driver_of_another_organization(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $otherOrg = Organization::factory()->enterprise()->create();
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();
        $foreignDriver = User::factory()->driver($otherOrg)->create();

        $this->actingAs($admin)->patch("/enterprise/drivers/{$foreignDriver->id}", [
            'name' => 'Pirate',
        ])->assertForbidden();
    }

    public function test_the_driver_route_rejects_a_non_driver_target(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $admin = User::factory()->enterpriseAdmin($enterprise)->create();
        $otherAdmin = User::factory()->enterpriseAdmin($enterprise)->create();

        $this->actingAs($admin)->patch("/enterprise/drivers/{$otherAdmin->id}", [
            'name' => 'Pirate',
        ])->assertNotFound();
    }

    public function test_station_admin_updates_a_pompiste_profile(): void
    {
        $station = Organization::factory()->station()->create();
        $admin = User::factory()->stationAdmin($station)->create();
        $pompiste = User::factory()->pompiste($station)->create();

        $this->actingAs($admin)->patch("/station/pompistes/{$pompiste->id}", [
            'name' => 'Eric Renommé',
            'phone' => '+237600000005',
            'matricule' => 'PP-07',
        ])->assertRedirect();

        $pompiste->refresh();
        $this->assertSame('Eric Renommé', $pompiste->name);
        $this->assertSame('PP-07', $pompiste->matricule);
    }

    public function test_station_admin_cannot_edit_a_pompiste_of_another_station(): void
    {
        $station = Organization::factory()->station()->create();
        $otherStation = Organization::factory()->station()->create();
        $admin = User::factory()->stationAdmin($station)->create();
        $foreignPompiste = User::factory()->pompiste($otherStation)->create();

        $this->actingAs($admin)->patch("/station/pompistes/{$foreignPompiste->id}", [
            'name' => 'Pirate',
        ])->assertForbidden();
    }
}
