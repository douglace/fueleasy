<?php

declare(strict_types=1);

namespace App\Domain\Identity;

use App\Domain\Shared\DomainException;

final class MobileAuthException extends DomainException
{
    public static function invalidCredentials(): self
    {
        return new self('Identifiants invalides.');
    }

    public static function pinLocked(): self
    {
        return new self('Compte temporairement bloqué. Réessayez plus tard.');
    }

    public static function requiresAdminReset(): self
    {
        return new self('PIN bloqué : contactez votre administrateur pour réinitialisation.');
    }

    public static function pinAlreadyActivated(): self
    {
        return new self('Le compte est déjà activé.');
    }

    public static function deviceMismatch(): self
    {
        return new self('Appareil non reconnu. Un changement d’appareil est requis.');
    }

    public static function invalidSmsCode(): self
    {
        return new self('Code SMS invalide ou expiré.');
    }
}
