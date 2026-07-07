<?php

declare(strict_types=1);

namespace App\Domain\Identity;

use App\Domain\Shared\DomainException;

final class MobileAuthException extends DomainException
{
    public function __construct(string $message, public readonly ?string $reason = null)
    {
        parent::__construct($message);
    }

    public static function invalidCredentials(): self
    {
        return new self('Identifiants invalides.');
    }

    /**
     * Compte à PIN temporaire jamais activé. N'est levée qu'APRÈS vérification
     * du PIN temporaire fourni : sans le bon PIN, l'appelant reçoit le même
     * invalidCredentials() qu'un compte inexistant (pas de fuite d'état).
     */
    public static function accountNotActivated(): self
    {
        return new self(
            'Compte non activé. Utilisez « Activer mon compte » avec votre PIN temporaire.',
            'account_not_activated',
        );
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
