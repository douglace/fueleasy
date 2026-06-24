<?php

declare(strict_types=1);

namespace App\Domain\Operations;

enum SettlementStatus: string
{
    case Open = 'open';
    case Paid = 'paid';

    public function isPaid(): bool
    {
        return $this === self::Paid;
    }
}
