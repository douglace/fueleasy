<?php

declare(strict_types=1);

namespace App\Domain\Payments;

use App\Domain\Shared\DomainException;

final class PaymentException extends DomainException
{
    public function __construct(public readonly PaymentFailureReason $reason)
    {
        parent::__construct($reason->message());
    }
}
