<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Payments\QrType;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\WorkSession;
use Illuminate\Support\Carbon;

/**
 * Résout un QR scanné (dynamique pompiste ou fixe pompe) en contexte de paiement.
 */
final class ResolveScan
{
    public function __construct(private readonly QrSigner $signer) {}

    public function handle(string $scanned, ?Carbon $now = null): ScanContext
    {
        $now ??= Carbon::now();

        // 1) QR fixe de secours : jeton persistant stocké sur la pompe.
        $pump = Pump::query()->where('fixed_qr_token', $scanned)->first();
        if ($pump !== null) {
            if (! $pump->fixed_qr_active) {
                throw new PaymentException(PaymentFailureReason::QrRevoked);
            }

            return new ScanContext(
                via: QrType::Fixed,
                station: $this->loadStation($pump->organization_id),
                pump: $pump,
            );
        }

        // 2) QR dynamique pompiste : jeton signé valable 60 s.
        $payload = $this->signer->verifyDynamic($scanned, $now);

        /** @var WorkSession|null $session */
        $session = WorkSession::query()->find($payload['sid']);
        if ($session === null || ! $session->isOpen() || $session->pump_id !== $payload['pid']) {
            throw new PaymentException(PaymentFailureReason::QrInvalid);
        }

        $pump = Pump::query()->findOrFail($session->pump_id);

        return new ScanContext(
            via: QrType::Dynamic,
            station: $this->loadStation($session->organization_id),
            pump: $pump,
            workSession: $session,
            pompisteId: $session->user_id,
        );
    }

    private function loadStation(int $organizationId): Organization
    {
        return Organization::query()->findOrFail($organizationId);
    }
}
