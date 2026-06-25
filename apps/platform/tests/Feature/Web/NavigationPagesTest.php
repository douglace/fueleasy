<?php

declare(strict_types=1);

namespace Tests\Feature\Web;

use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class NavigationPagesTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return array<string, array{string, string}>
     */
    public static function adminPages(): array
    {
        return [
            'dashboard' => ['/admin', 'admin/dashboard'],
            'organizations' => ['/admin/organizations', 'admin/organizations'],
            'transactions' => ['/admin/transactions', 'admin/transactions'],
            'refunds' => ['/admin/refunds', 'admin/refunds'],
            'settlements' => ['/admin/settlements', 'admin/settlements'],
            'audit' => ['/admin/audit', 'admin/audit'],
        ];
    }

    /**
     * @return array<string, array{string, string}>
     */
    public static function enterprisePages(): array
    {
        return [
            'dashboard' => ['/enterprise', 'enterprise/dashboard'],
            'drivers' => ['/enterprise/drivers', 'enterprise/drivers'],
            'stations' => ['/enterprise/stations', 'enterprise/stations'],
            'transactions' => ['/enterprise/transactions', 'enterprise/transactions'],
        ];
    }

    /**
     * @return array<string, array{string, string}>
     */
    public static function stationPages(): array
    {
        return [
            'dashboard' => ['/station', 'station/dashboard'],
            'pumps' => ['/station/pumps', 'station/pumps'],
            'pompistes' => ['/station/pompistes', 'station/pompistes'],
            'payments' => ['/station/payments', 'station/payments'],
            'settlements' => ['/station/settlements', 'station/settlements'],
        ];
    }

    #[DataProvider('adminPages')]
    public function test_admin_pages_render(string $url, string $component): void
    {
        $admin = User::factory()->fusyAdmin()->create();

        $this->actingAs($admin)->get($url)->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component($component));
    }

    #[DataProvider('enterprisePages')]
    public function test_enterprise_pages_render(string $url, string $component): void
    {
        $org = Organization::factory()->enterprise()->create();
        FuelAccount::factory()->create(['organization_id' => $org->id, 'balance' => 0]);
        $admin = User::factory()->enterpriseAdmin($org)->create();

        $this->actingAs($admin)->get($url)->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component($component));
    }

    #[DataProvider('stationPages')]
    public function test_station_pages_render(string $url, string $component): void
    {
        $org = Organization::factory()->station()->create();
        $admin = User::factory()->stationAdmin($org)->create();

        $this->actingAs($admin)->get($url)->assertOk()
            ->assertInertia(fn (Assert $page) => $page->component($component));
    }

    public function test_each_role_is_isolated_from_other_areas(): void
    {
        $enterprise = Organization::factory()->enterprise()->create();
        $station = Organization::factory()->station()->create();

        $enterpriseAdmin = User::factory()->enterpriseAdmin($enterprise)->create();
        $stationAdmin = User::factory()->stationAdmin($station)->create();
        $fusyAdmin = User::factory()->fusyAdmin()->create();

        // Un admin entreprise n'accède ni à l'admin Fusy ni à la station.
        $this->actingAs($enterpriseAdmin)->get('/admin/organizations')->assertForbidden();
        $this->actingAs($enterpriseAdmin)->get('/station/pumps')->assertForbidden();

        // Un admin station n'accède ni à l'admin Fusy ni à l'entreprise.
        $this->actingAs($stationAdmin)->get('/admin/settlements')->assertForbidden();
        $this->actingAs($stationAdmin)->get('/enterprise/drivers')->assertForbidden();

        // L'admin Fusy n'accède pas aux espaces entreprise/station.
        $this->actingAs($fusyAdmin)->get('/enterprise/drivers')->assertForbidden();
        $this->actingAs($fusyAdmin)->get('/station/pumps')->assertForbidden();
    }
}
