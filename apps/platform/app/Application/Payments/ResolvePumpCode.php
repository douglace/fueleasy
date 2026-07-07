<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Payments\QrType;
use App\Domain\Stations\PumpCode;
use App\Models\Organization;
use App\Models\Pump;

/**
 * Résout un code pompe saisi manuellement (secours quand le scan QR
 * n'est pas possible : caméra refusée, QR illisible).
 *
 * Le code suit uniquement le statut de la pompe, pas fixed_qr_active :
 * ce flag est le kill-switch du sticker QR compromis, et le révoquer ne
 * doit pas couper le canal de secours. Les mitigations restent celles du
 * flux normal : chauffeur authentifié, station autorisée, PIN.
 */
final class ResolvePumpCode
{
    public function handle(string $code): ScanContext
    {
        $code = strtoupper(trim($code));

        if (! PumpCode::isValid($code)) {
            throw new PaymentException(PaymentFailureReason::PumpCodeUnknown);
        }

        $pump = Pump::query()->where('code', $code)->first();
        if ($pump === null) {
            throw new PaymentException(PaymentFailureReason::PumpCodeUnknown);
        }

        return new ScanContext(
            via: QrType::Code,
            station: Organization::query()->findOrFail($pump->organization_id),
            pump: $pump,
        );
    }
}
