<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Application\DriverBudgets\ResetDriverBudget;
use App\Domain\DriverBudgets\BudgetMode;
use App\Models\DriverBudget;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Carbon;

/**
 * Réinitialise les budgets périodiques (hebdo/mensuel) dont l'échéance est atteinte.
 * Le reset remplace le solde par le montant alloué.
 */
class ResetDueDriverBudgets implements ShouldQueue
{
    use Queueable;

    public function handle(ResetDriverBudget $reset): int
    {
        $count = 0;

        DriverBudget::query()
            ->whereIn('mode', [BudgetMode::Weekly, BudgetMode::Monthly])
            ->whereNotNull('next_reset_at')
            ->where('next_reset_at', '<=', Carbon::now())
            ->orderBy('id')
            ->each(function (DriverBudget $budget) use ($reset, &$count): void {
                $reset->handle($budget);
                $count++;
            });

        return $count;
    }
}
