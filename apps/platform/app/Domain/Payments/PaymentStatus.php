<?php

declare(strict_types=1);

namespace App\Domain\Payments;

enum PaymentStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    case Expired = 'expired';
    case Failed = 'failed';
    case Refunded = 'refunded';

    public function isFinal(): bool
    {
        return $this !== self::Pending;
    }

    public function isPaid(): bool
    {
        return $this === self::Paid;
    }
}
