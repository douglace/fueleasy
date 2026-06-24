<?php

declare(strict_types=1);

namespace App\Application\Organizations;

use App\Domain\Organizations\OrganizationCode;
use App\Models\Organization;
use RuntimeException;

/**
 * Génère un code organisation unique globalement.
 *
 * L'unicité finale est garantie par l'index unique en base ; ce générateur
 * réduit la probabilité de collision en testant l'existence avant insertion.
 */
final class OrganizationCodeGenerator
{
    public const int MAX_ATTEMPTS = 20;

    public function generate(): OrganizationCode
    {
        for ($attempt = 0; $attempt < self::MAX_ATTEMPTS; $attempt++) {
            $code = OrganizationCode::random();

            if (! Organization::query()->where('code', $code->value)->exists()) {
                return $code;
            }
        }

        throw new RuntimeException('Impossible de générer un code organisation unique.');
    }
}
