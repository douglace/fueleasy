<?php

declare(strict_types=1);

namespace App\Domain\Organizations;

enum OrganizationType: string
{
    case Enterprise = 'enterprise';
    case Station = 'station';

    public function label(): string
    {
        return match ($this) {
            self::Enterprise => 'Entreprise',
            self::Station => 'Station',
        };
    }
}
