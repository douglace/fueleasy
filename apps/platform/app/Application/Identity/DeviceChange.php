<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Application\Audit\AuditLogger;
use App\Application\Notifications\SmsSender;
use App\Domain\Identity\MobileAuthException;
use App\Domain\Identity\PinVerificationResult;
use App\Models\SmsCode;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Changement d'appareil : requiert code organisation + identifiant + PIN, puis
 * confirmation par code SMS. L'ancienne session est révoquée lors de l'émission
 * du nouveau jeton.
 */
final class DeviceChange
{
    public const string PURPOSE = 'device_change';

    public const int CODE_TTL_MINUTES = 10;

    public function __construct(
        private readonly MobileUserResolver $resolver,
        private readonly PinVerifier $pinVerifier,
        private readonly DeviceTokenIssuer $tokenIssuer,
        private readonly SmsSender $sms,
        private readonly AuditLogger $audit,
    ) {}

    /**
     * Étape 1 : vérifie le PIN et envoie un code SMS pour le nouvel appareil.
     */
    public function request(string $organizationCode, string $identifier, string $pin, string $newDeviceId): void
    {
        $user = $this->resolver->resolve($organizationCode, $identifier);

        match ($this->pinVerifier->verify($user, $pin)) {
            PinVerificationResult::Ok => null,
            PinVerificationResult::Locked => throw MobileAuthException::pinLocked(),
            PinVerificationResult::RequiresAdminReset => throw MobileAuthException::requiresAdminReset(),
            PinVerificationResult::Invalid => throw MobileAuthException::invalidCredentials(),
        };

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        SmsCode::query()->create([
            'user_id' => $user->id,
            'purpose' => self::PURPOSE,
            'code_hash' => Hash::make($code),
            'pending_device_id' => $newDeviceId,
            'expires_at' => Carbon::now()->addMinutes(self::CODE_TTL_MINUTES),
        ]);

        if ($user->phone !== null) {
            $this->sms->send(
                to: $user->phone,
                purpose: self::PURPOSE,
                body: "Code de changement d'appareil Fusy : {$code}",
                organizationId: $user->organization_id,
                userId: $user->id,
                payload: ['device_id' => $newDeviceId],
            );
        }
    }

    /**
     * Étape 2 : valide le code SMS, enregistre le nouvel appareil, révoque l'ancien.
     *
     * @return array{user: User, token: string}
     */
    public function confirm(string $organizationCode, string $identifier, string $smsCode, string $deviceId): array
    {
        $user = $this->resolver->resolve($organizationCode, $identifier);
        $now = Carbon::now();

        $record = SmsCode::query()
            ->where('user_id', $user->id)
            ->where('purpose', self::PURPOSE)
            ->where('pending_device_id', $deviceId)
            ->whereNull('consumed_at')
            ->orderByDesc('id')
            ->first();

        if ($record === null || ! $record->isUsable($now) || ! Hash::check($smsCode, $record->code_hash)) {
            throw MobileAuthException::invalidSmsCode();
        }

        $record->forceFill(['consumed_at' => $now])->save();

        $token = $this->tokenIssuer->issue($user, $deviceId);

        $this->audit->record(
            action: 'mobile.device_changed',
            subject: $user,
            organizationId: $user->organization_id,
            actorId: $user->id,
            context: ['device_id' => $deviceId],
        );

        return ['user' => $user, 'token' => $token];
    }
}
