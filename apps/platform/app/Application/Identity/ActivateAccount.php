<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Application\Audit\AuditLogger;
use App\Application\Notifications\SmsSender;
use App\Domain\Identity\MobileAuthException;
use App\Domain\Identity\PinVerificationResult;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Première connexion : valide le PIN temporaire, impose un nouveau PIN personnel,
 * enregistre l'appareil et émet un jeton. Une confirmation SMS est envoyée.
 *
 * @phpstan-type ActivationResult array{user: User, token: string}
 */
final class ActivateAccount
{
    public function __construct(
        private readonly MobileUserResolver $resolver,
        private readonly PinVerifier $pinVerifier,
        private readonly DeviceTokenIssuer $tokenIssuer,
        private readonly SmsSender $sms,
        private readonly AuditLogger $audit,
    ) {}

    /**
     * @return array{user: User, token: string}
     */
    public function handle(
        string $organizationCode,
        string $identifier,
        string $temporaryPin,
        string $newPin,
        string $deviceId,
        ?string $deviceName = null,
    ): array {
        $user = $this->resolver->resolve($organizationCode, $identifier);

        if (! $user->pin_is_temporary) {
            throw MobileAuthException::pinAlreadyActivated();
        }

        $this->assertPin($this->pinVerifier->verify($user, $temporaryPin));

        $user->forceFill([
            'pin_hash' => Hash::make($newPin),
            'pin_is_temporary' => false,
            'pin_changed_at' => Carbon::now(),
            'failed_pin_attempts' => 0,
            'pin_locked_until' => null,
            'requires_admin_reset' => false,
        ])->save();

        $token = $this->tokenIssuer->issue($user, $deviceId, $deviceName);

        if ($user->phone !== null) {
            $this->sms->send(
                to: $user->phone,
                purpose: 'activation',
                body: 'Votre compte Fusy est activé sur cet appareil.',
                organizationId: $user->organization_id,
                userId: $user->id,
            );
        }

        $this->audit->record(
            action: 'mobile.activated',
            subject: $user,
            organizationId: $user->organization_id,
            actorId: $user->id,
            context: ['device_id' => $deviceId],
        );

        return ['user' => $user, 'token' => $token];
    }

    private function assertPin(PinVerificationResult $result): void
    {
        match ($result) {
            PinVerificationResult::Ok => null,
            PinVerificationResult::Locked => throw MobileAuthException::pinLocked(),
            PinVerificationResult::RequiresAdminReset => throw MobileAuthException::requiresAdminReset(),
            PinVerificationResult::Invalid => throw MobileAuthException::invalidCredentials(),
        };
    }
}
