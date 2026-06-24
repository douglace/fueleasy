<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Domain\Identity\MobileAuthException;
use App\Domain\Identity\PinVerificationResult;
use App\Models\User;

/**
 * Connexion sur l'appareil enregistré : PIN personnel uniquement.
 * Un appareil différent exige un changement d'appareil confirmé par SMS.
 */
final class MobileLogin
{
    public function __construct(
        private readonly MobileUserResolver $resolver,
        private readonly PinVerifier $pinVerifier,
        private readonly DeviceTokenIssuer $tokenIssuer,
    ) {}

    /**
     * @return array{user: User, token: string}
     */
    public function handle(string $organizationCode, string $identifier, string $pin, string $deviceId): array
    {
        $user = $this->resolver->resolve($organizationCode, $identifier);

        if ($user->pin_is_temporary) {
            throw MobileAuthException::invalidCredentials();
        }

        match ($this->pinVerifier->verify($user, $pin)) {
            PinVerificationResult::Ok => null,
            PinVerificationResult::Locked => throw MobileAuthException::pinLocked(),
            PinVerificationResult::RequiresAdminReset => throw MobileAuthException::requiresAdminReset(),
            PinVerificationResult::Invalid => throw MobileAuthException::invalidCredentials(),
        };

        if ($user->device_id !== null && $user->device_id !== $deviceId) {
            throw MobileAuthException::deviceMismatch();
        }

        $token = $this->tokenIssuer->issue($user, $deviceId);

        return ['user' => $user, 'token' => $token];
    }
}
