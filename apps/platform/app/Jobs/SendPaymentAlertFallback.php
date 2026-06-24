<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Application\Notifications\SmsSender;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Carbon;

/**
 * Si l'app pompiste n'a pas accusé réception de l'alerte d'un paiement, envoie un
 * SMS de secours contenant les informations minimales.
 */
class SendPaymentAlertFallback implements ShouldQueue
{
    use Queueable;

    public function __construct(public readonly int $paymentId) {}

    public function handle(SmsSender $sms): void
    {
        /** @var Payment|null $payment */
        $payment = Payment::query()->find($this->paymentId);

        if ($payment === null
            || ! $payment->isPaid()
            || $payment->alert_acknowledged_at !== null
            || $payment->alert_sms_sent_at !== null
            || $payment->pompiste_id === null) {
            return;
        }

        $pompiste = User::query()->find($payment->pompiste_id);
        if ($pompiste?->phone === null) {
            return;
        }

        $sms->send(
            to: $pompiste->phone,
            purpose: 'payment_alert',
            body: sprintf(
                'Paiement Fusy %s — %s FCFA, pompe %d. Vérifiez l’historique avant de servir.',
                $payment->short_code,
                number_format($payment->amount, 0, ',', ' '),
                $payment->pump_id,
            ),
            organizationId: $payment->station_organization_id,
            userId: $pompiste->id,
            payload: ['payment_id' => $payment->id, 'short_code' => $payment->short_code],
        );

        $payment->forceFill(['alert_sms_sent_at' => Carbon::now()])->save();
    }
}
