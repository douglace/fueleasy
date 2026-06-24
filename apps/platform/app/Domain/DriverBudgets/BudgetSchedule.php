<?php

declare(strict_types=1);

namespace App\Domain\DriverBudgets;

use Illuminate\Support\Carbon;

/**
 * Calcule la prochaine échéance de reset d'un budget selon son mode.
 */
final class BudgetSchedule
{
    public static function nextResetAfter(BudgetMode $mode, Carbon $from): ?Carbon
    {
        return match ($mode) {
            BudgetMode::Manual => null,
            BudgetMode::Weekly => $from->copy()->addWeek(),
            BudgetMode::Monthly => $from->copy()->addMonthNoOverflow(),
        };
    }
}
