<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Payments\PaymentStatus;
use App\Models\Payment;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Carbon;

/**
 * Marque « expirées » les sessions de paiement en attente dont le délai de 5 min
 * est dépassé. Aucun débit n'a eu lieu : simple changement d'état.
 */
class ExpireStalePayments implements ShouldQueue
{
    use Queueable;

    public function handle(): int
    {
        return Payment::query()
            ->where('status', PaymentStatus::Pending)
            ->where('expires_at', '<', Carbon::now())
            ->update([
                'status' => PaymentStatus::Expired,
                'failure_reason' => PaymentFailureReason::SessionExpired->value,
            ]);
    }
}
