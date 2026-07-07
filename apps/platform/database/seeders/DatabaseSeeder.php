<?php

namespace Database\Seeders;

use App\Application\DriverBudgets\SetDriverBudget;
use App\Application\FuelAccounts\CreditFuelAccount;
use App\Application\Identity\MobileAccountAdmin;
use App\Application\Organizations\OnboardOrganization;
use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Identity\Role;
use App\Domain\Organizations\OrganizationCode;
use App\Domain\Organizations\OrganizationType;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Domain\Stations\PumpCode;
use App\Models\AuthorizedStation;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Seed un environnement pilote complet : Admin Fusy, une entreprise (compte crédité,
 * chauffeurs + budgets), une station (pompes + pompiste), une autorisation, et une
 * organisation démo isolée. Idempotent (skip si déjà seedé).
 */
class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        if (User::query()->where('email', 'admin@fusy.test')->exists()) {
            $this->command->info('Seed déjà appliqué, rien à faire.');

            return;
        }

        /** @var OnboardOrganization $onboard */
        $onboard = app(OnboardOrganization::class);
        /** @var MobileAccountAdmin $accounts */
        $accounts = app(MobileAccountAdmin::class);

        // Admin Fusy.
        $fusyAdmin = User::query()->create([
            'name' => 'Admin Fusy',
            'role' => Role::FusyAdmin,
            'email' => 'admin@fusy.test',
            'password' => Hash::make('password'),
        ]);

        // Entreprise pilote + compte crédité.
        $enterprise = $onboard->handle(
            type: OrganizationType::Enterprise,
            name: 'Transport Pilote SARL',
            admin: ['name' => 'Admin Entreprise', 'email' => 'entreprise@fusy.test', 'password' => 'password'],
            actorId: $fusyAdmin->id,
        );
        $account = FuelAccount::query()->where('organization_id', $enterprise->id)->firstOrFail();
        app(CreditFuelAccount::class)->handle($account, Money::fromInt(2_000_000), actorId: $fusyAdmin->id, description: 'Dépôt pilote');

        // Chauffeurs + budgets.
        foreach (['Boris Mballa' => 80_000, 'Awa Ndongo' => 120_000] as $name => $amount) {
            $driver = $accounts->create($enterprise, Role::Driver, $name, '+2376'.fake()->numerify('########'), null, $fusyAdmin->id)['user'];
            app(SetDriverBudget::class)->handle($driver, BudgetMode::Monthly, Money::fromInt($amount), $fusyAdmin->id);
        }

        // Station pilote + pompe + pompiste.
        $station = $onboard->handle(
            type: OrganizationType::Station,
            name: 'Station Centre-Ville',
            admin: ['name' => 'Admin Station', 'email' => 'station@fusy.test', 'password' => 'password'],
            actorId: $fusyAdmin->id,
        );
        Pump::query()->create([
            'organization_id' => $station->id,
            'label' => 'Pompe 1',
            'code' => PumpCode::random()->value,
            'fixed_qr_token' => Str::random(40),
            'fixed_qr_active' => true,
            'available_fuels' => [FuelType::Gasoil->value, FuelType::Super->value],
        ]);
        $accounts->create($station, Role::Pompiste, 'Eric Pompiste', '+2376'.fake()->numerify('########'), null, $fusyAdmin->id);

        // Autorisation entreprise → station.
        AuthorizedStation::query()->create([
            'enterprise_organization_id' => $enterprise->id,
            'station_organization_id' => $station->id,
            'authorized_by' => $fusyAdmin->id,
        ]);

        // Organisation démo isolée (recharges simulées Orange/MTN/USSD).
        $demo = Organization::query()->create([
            'code' => OrganizationCode::random()->value,
            'type' => OrganizationType::Enterprise,
            'name' => 'Démo Opérateurs',
            'is_demo' => true,
        ]);
        FuelAccount::query()->create(['organization_id' => $demo->id, 'balance' => 0]);

        $this->command->info('Pilote seedé. Admin Fusy: admin@fusy.test / password (code entreprise: '.$enterprise->code.').');
    }
}
