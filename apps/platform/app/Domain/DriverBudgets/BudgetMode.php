<?php

declare(strict_types=1);

namespace App\Domain\DriverBudgets;

enum BudgetMode: string
{
    case Manual = 'manual';
    case Weekly = 'weekly';
    case Monthly = 'monthly';

    public function isPeriodic(): bool
    {
        return $this === self::Weekly || $this === self::Monthly;
    }

    public function label(): string
    {
        return match ($this) {
            self::Manual => 'Manuel',
            self::Weekly => 'Hebdomadaire',
            self::Monthly => 'Mensuel',
        };
    }
}
