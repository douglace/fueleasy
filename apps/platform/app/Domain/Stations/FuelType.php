<?php

declare(strict_types=1);

namespace App\Domain\Stations;

enum FuelType: string
{
    case Gasoil = 'gasoil';
    case Super = 'super';
    case Petrole = 'petrole';

    public function label(): string
    {
        return match ($this) {
            self::Gasoil => 'Gasoil',
            self::Super => 'Super sans plomb',
            self::Petrole => 'Pétrole lampant',
        };
    }
}
