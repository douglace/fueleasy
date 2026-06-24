<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Domain\Identity\Role;
use App\Models\AuthorizedStation;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SeederTest extends TestCase
{
    use RefreshDatabase;

    public function test_seeder_creates_a_coherent_pilot_environment(): void
    {
        $this->seed(DatabaseSeeder::class);

        $this->assertDatabaseHas('users', ['email' => 'admin@fusy.test', 'role' => Role::FusyAdmin->value]);

        $enterprise = Organization::query()->where('name', 'Transport Pilote SARL')->firstOrFail();
        $this->assertSame(2_000_000, (int) FuelAccount::query()->where('organization_id', $enterprise->id)->value('balance'));
        $this->assertSame(2, User::query()->where('organization_id', $enterprise->id)->where('role', Role::Driver)->count());

        $station = Organization::query()->where('name', 'Station Centre-Ville')->firstOrFail();
        $this->assertDatabaseHas('pumps', ['organization_id' => $station->id]);
        $this->assertTrue(AuthorizedStation::isAuthorized($enterprise->id, $station->id));

        $this->assertDatabaseHas('organizations', ['name' => 'Démo Opérateurs', 'is_demo' => true]);
    }

    public function test_seeder_is_idempotent(): void
    {
        $this->seed(DatabaseSeeder::class);
        $this->seed(DatabaseSeeder::class);

        $this->assertSame(1, User::query()->where('email', 'admin@fusy.test')->count());
    }
}
