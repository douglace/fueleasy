<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Domain\Identity\PinVerificationResult;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Vérifie le PIN d'un utilisateur mobile et applique la politique de blocage :
 * 5 tentatives incorrectes → blocage 15 minutes ; récidive → reset admin requis.
 */
final class PinVerifier
{
    public const int MAX_ATTEMPTS = 5;

    public const int LOCK_MINUTES = 15;

    public function verify(User $user, string $pin, ?Carbon $now = null): PinVerificationResult
    {
        $now ??= Carbon::now();

        if ($user->requires_admin_reset) {
            return PinVerificationResult::RequiresAdminReset;
        }

        if ($user->pin_locked_until !== null && $user->pin_locked_until->greaterThan($now)) {
            return PinVerificationResult::Locked;
        }

        if ($user->pin_hash !== null && Hash::check($pin, $user->pin_hash)) {
            $user->forceFill([
                'failed_pin_attempts' => 0,
                'pin_locked_until' => null,
            ])->save();

            return PinVerificationResult::Ok;
        }

        $attempts = $user->failed_pin_attempts + 1;

        if ($attempts > self::MAX_ATTEMPTS) {
            // Récidive après un premier blocage : l'admin doit réinitialiser le PIN.
            $user->forceFill([
                'failed_pin_attempts' => $attempts,
                'requires_admin_reset' => true,
                'pin_locked_until' => $now->copy()->addMinutes(self::LOCK_MINUTES),
            ])->save();

            return PinVerificationResult::RequiresAdminReset;
        }

        if ($attempts >= self::MAX_ATTEMPTS) {
            $user->forceFill([
                'failed_pin_attempts' => $attempts,
                'pin_locked_until' => $now->copy()->addMinutes(self::LOCK_MINUTES),
            ])->save();

            return PinVerificationResult::Locked;
        }

        $user->forceFill(['failed_pin_attempts' => $attempts])->save();

        return PinVerificationResult::Invalid;
    }
}
