<?php

declare(strict_types=1);

namespace App\Domain\Organizations;

enum OrganizationStatus: string
{
    case Active = 'active';
    case Suspended = 'suspended';

    public function isActive(): bool
    {
        return $this === self::Active;
    }

    public function label(): string
    {
        return match ($this) {
            self::Active => 'Active',
            self::Suspended => 'Suspendue',
        };
    }
}
