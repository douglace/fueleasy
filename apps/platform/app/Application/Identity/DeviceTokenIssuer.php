<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Models\DeviceSession;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Émet un jeton de session pour un appareil. Un seul appareil actif par compte :
 * toute session active antérieure est révoquée. Retourne le jeton en clair (seul
 * son hash est stocké).
 */
final class DeviceTokenIssuer
{
    public function issue(User $user, string $deviceId, ?string $deviceName = null): string
    {
        $plain = Str::random(64);

        DB::transaction(function () use ($user, $deviceId, $deviceName, $plain): void {
            DeviceSession::query()
                ->where('user_id', $user->id)
                ->whereNull('revoked_at')
                ->update(['revoked_at' => Carbon::now()]);

            DeviceSession::query()->create([
                'user_id' => $user->id,
                'device_id' => $deviceId,
                'device_name' => $deviceName,
                'token_hash' => hash('sha256', $plain),
                'last_used_at' => Carbon::now(),
            ]);

            $user->forceFill([
                'device_id' => $deviceId,
                'device_registered_at' => Carbon::now(),
            ])->save();
        });

        return $plain;
    }
}
