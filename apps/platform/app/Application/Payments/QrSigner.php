<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Models\WorkSession;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;

/**
 * Signe et vérifie les QR dynamiques pompiste (jeton HMAC valable 60 secondes).
 */
final class QrSigner
{
    public const int TTL_SECONDS = 60;

    public function signDynamic(WorkSession $session, ?Carbon $now = null): string
    {
        $now ??= Carbon::now();

        $payload = [
            'sid' => $session->id,
            'pid' => $session->pump_id,
            'oid' => $session->organization_id,
            'uid' => $session->user_id,
            'iat' => $now->getTimestamp(),
        ];

        $encoded = $this->base64UrlEncode((string) json_encode($payload));

        return $encoded.'.'.$this->signature($encoded);
    }

    /**
     * @return array{sid:int,pid:int,oid:int,uid:int,iat:int}
     */
    public function verifyDynamic(string $token, ?Carbon $now = null): array
    {
        $now ??= Carbon::now();

        $parts = explode('.', $token);
        if (count($parts) !== 2) {
            throw new PaymentException(PaymentFailureReason::QrInvalid);
        }

        [$encoded, $signature] = $parts;

        if (! hash_equals($this->signature($encoded), $signature)) {
            throw new PaymentException(PaymentFailureReason::QrInvalid);
        }

        $decoded = json_decode($this->base64UrlDecode($encoded), true);
        if (! is_array($decoded) || ! isset($decoded['sid'], $decoded['pid'], $decoded['oid'], $decoded['uid'], $decoded['iat'])) {
            throw new PaymentException(PaymentFailureReason::QrInvalid);
        }

        if (($decoded['iat'] + self::TTL_SECONDS) < $now->getTimestamp()) {
            throw new PaymentException(PaymentFailureReason::QrExpired);
        }

        return [
            'sid' => (int) $decoded['sid'],
            'pid' => (int) $decoded['pid'],
            'oid' => (int) $decoded['oid'],
            'uid' => (int) $decoded['uid'],
            'iat' => (int) $decoded['iat'],
        ];
    }

    private function signature(string $encoded): string
    {
        return $this->base64UrlEncode(hash_hmac('sha256', $encoded, $this->key(), true));
    }

    private function key(): string
    {
        $key = (string) Config::get('app.key');

        return str_starts_with($key, 'base64:') ? base64_decode(substr($key, 7)) : $key;
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private function base64UrlDecode(string $value): string
    {
        return base64_decode(strtr($value, '-_', '+/')) ?: '';
    }
}
