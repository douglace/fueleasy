<?php

declare(strict_types=1);

namespace App\Domain\Stations;

use App\Domain\Organizations\OrganizationCode;
use InvalidArgumentException;

/**
 * Code pompe : 6 caractères alphanumériques majuscules, sans caractères
 * ambigus (O, 0, I, 1). Saisi manuellement par le chauffeur quand le
 * scan du QR n'est pas possible.
 */
final readonly class PumpCode
{
    public const int LENGTH = 6;

    public const string ALPHABET = OrganizationCode::ALPHABET;

    public function __construct(public string $value)
    {
        if (! self::isValid($value)) {
            throw new InvalidArgumentException("Code pompe invalide : {$value}");
        }
    }

    public static function isValid(string $value): bool
    {
        if (strlen($value) !== self::LENGTH) {
            return false;
        }

        return strspn($value, self::ALPHABET) === self::LENGTH;
    }

    /**
     * Génère un code aléatoire valide. L'unicité globale est garantie
     * en base par un index unique ; voir PumpCodeGenerator.
     */
    public static function random(): self
    {
        $alphabet = self::ALPHABET;
        $max = strlen($alphabet) - 1;
        $code = '';

        for ($i = 0; $i < self::LENGTH; $i++) {
            $code .= $alphabet[random_int(0, $max)];
        }

        return new self($code);
    }

    public function __toString(): string
    {
        return $this->value;
    }
}
