<?php

declare(strict_types=1);

namespace App\Application\DriverBudgets;

use App\Application\Audit\AuditLogger;
use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\DriverBudgets\BudgetSchedule;
use App\Domain\Identity\Role;
use App\Domain\Shared\Money;
use App\Models\DriverBudget;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * Définit (ou redéfinit) le budget d'un chauffeur. Le solde disponible est
 * remplacé par le montant alloué — il n'est jamais additionné.
 */
final class SetDriverBudget
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(User $driver, BudgetMode $mode, Money $amount, ?int $actorId = null): DriverBudget
    {
        if ($driver->role !== Role::Driver) {
            throw new InvalidArgumentException('Un budget ne peut être attribué qu’à un chauffeur.');
        }

        return DB::transaction(function () use ($driver, $mode, $amount, $actorId): DriverBudget {
            $now = Carbon::now();

            $budget = DriverBudget::query()->updateOrCreate(
                ['user_id' => $driver->id],
                [
                    'organization_id' => $driver->organization_id,
                    'mode' => $mode,
                    'amount' => $amount->amount,
                    'balance' => $amount->amount,
                    'last_reset_at' => $now,
                    'next_reset_at' => BudgetSchedule::nextResetAfter($mode, $now),
                ],
            );

            $this->audit->record(
                action: 'driver_budget.set',
                subject: $budget,
                organizationId: $driver->organization_id,
                actorId: $actorId,
                context: ['mode' => $mode->value, 'amount' => $amount->amount],
            );

            return $budget;
        });
    }
}
