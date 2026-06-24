<?php

declare(strict_types=1);

namespace App\Application\DriverBudgets;

use App\Application\Audit\AuditLogger;
use App\Domain\DriverBudgets\BudgetSchedule;
use App\Models\DriverBudget;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Réinitialise un budget : le solde restant est remplacé par le montant alloué.
 * Sert au reset manuel comme au reset périodique (hebdo/mensuel) déclenché par job.
 */
final class ResetDriverBudget
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(DriverBudget $budget, ?int $actorId = null): DriverBudget
    {
        return DB::transaction(function () use ($budget, $actorId): DriverBudget {
            /** @var DriverBudget $locked */
            $locked = DriverBudget::query()->whereKey($budget->getKey())->lockForUpdate()->firstOrFail();

            $now = Carbon::now();
            $previousBalance = $locked->balance;

            $locked->balance = $locked->amount; // remplace, n'additionne pas
            $locked->last_reset_at = $now;
            $locked->next_reset_at = BudgetSchedule::nextResetAfter($locked->mode, $now);
            $locked->save();

            $this->audit->record(
                action: 'driver_budget.reset',
                subject: $locked,
                organizationId: $locked->organization_id,
                actorId: $actorId,
                context: ['previous_balance' => $previousBalance, 'new_balance' => $locked->balance],
            );

            return $locked->refresh();
        });
    }
}
