<?php

declare(strict_types=1);

namespace App\Domain\Identity;

enum PinVerificationResult: string
{
    case Ok = 'ok';
    case Invalid = 'invalid';
    case Locked = 'locked';
    case RequiresAdminReset = 'requires_admin_reset';

    public function isOk(): bool
    {
        return $this === self::Ok;
    }
}
