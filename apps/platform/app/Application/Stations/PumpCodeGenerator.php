<?php

declare(strict_types=1);

namespace App\Application\Stations;

use App\Domain\Stations\PumpCode;
use App\Models\Pump;
use RuntimeException;

/**
 * Génère un code pompe unique globalement.
 *
 * L'unicité finale est garantie par l'index unique en base ; ce générateur
 * réduit la probabilité de collision en testant l'existence avant insertion.
 */
final class PumpCodeGenerator
{
    public const int MAX_ATTEMPTS = 20;

    public function generate(): PumpCode
    {
        for ($attempt = 0; $attempt < self::MAX_ATTEMPTS; $attempt++) {
            $code = PumpCode::random();

            if (! Pump::query()->where('code', $code->value)->exists()) {
                return $code;
            }
        }

        throw new RuntimeException('Impossible de générer un code pompe unique.');
    }
}
