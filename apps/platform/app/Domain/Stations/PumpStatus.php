<?php

declare(strict_types=1);

namespace App\Domain\Stations;

enum PumpStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';

    public function isActive(): bool
    {
        return $this === self::Active;
    }
}
