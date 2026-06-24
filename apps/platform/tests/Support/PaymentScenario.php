<?php

declare(strict_types=1);

namespace Tests\Support;

use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Stations\FuelType;
use App\Models\AuthorizedStation;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\User;
use App\Models\WorkSession;
use Illuminate\Support\Facades\Hash;

/**
 * Scénario complet et cohérent pour les tests de paiement :
 * entreprise (compte + chauffeur + budget), station (pompe + pompiste + session),
 * autorisation entreprise→station.
 */
final class PaymentScenario
{
    public Organization $enterprise;

    public Organization $station;

    public FuelAccount $account;

    public User $driver;

    public DriverBudget $budget;

    public User $pompiste;

    public Pump $pump;

    public WorkSession $workSession;

    public string $pin = '4321';

    public function __construct(int $accountBalance = 200_000, int $budgetBalance = 100_000)
    {
        $this->enterprise = Organization::factory()->enterprise()->create();
        $this->station = Organization::factory()->station()->create();

        $this->account = FuelAccount::factory()->create([
            'organization_id' => $this->enterprise->id,
            'balance' => $accountBalance,
        ]);

        $this->driver = User::factory()->driver($this->enterprise)->create([
            'pin_hash' => Hash::make($this->pin),
            'pin_is_temporary' => false,
        ]);

        $this->budget = DriverBudget::factory()->forDriver($this->driver)->create([
            'mode' => BudgetMode::Manual,
            'amount' => $budgetBalance,
            'balance' => $budgetBalance,
        ]);

        $this->pompiste = User::factory()->pompiste($this->station)->create();

        $this->pump = Pump::factory()->create([
            'organization_id' => $this->station->id,
            'available_fuels' => [FuelType::Gasoil->value, FuelType::Super->value],
        ]);

        $this->workSession = WorkSession::factory()->create([
            'organization_id' => $this->station->id,
            'user_id' => $this->pompiste->id,
            'pump_id' => $this->pump->id,
        ]);

        AuthorizedStation::query()->create([
            'enterprise_organization_id' => $this->enterprise->id,
            'station_organization_id' => $this->station->id,
        ]);
    }
}
