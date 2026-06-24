<?php

declare(strict_types=1);

namespace App\Application\Operations;

use App\Models\Payment;
use Illuminate\Support\Collection;

/**
 * Exporte des transactions au format CSV.
 */
final class TransactionExporter
{
    /**
     * @param  Collection<int, Payment>  $payments
     */
    public function csv(Collection $payments): string
    {
        $handle = fopen('php://temp', 'r+');
        if ($handle === false) {
            return '';
        }

        fputcsv($handle, ['Référence', 'Code', 'Date', 'Station', 'Entreprise', 'Carburant', 'Montant FCFA', 'Statut'], ',', '"', '\\');

        foreach ($payments as $payment) {
            fputcsv($handle, [
                $payment->reference,
                $payment->short_code,
                $payment->confirmed_at?->toDateTimeString() ?? $payment->created_at?->toDateTimeString() ?? '',
                $payment->station->name,
                $payment->enterprise->name,
                $payment->fuel_type->value,
                (string) $payment->amount,
                $payment->status->value,
            ], ',', '"', '\\');
        }

        rewind($handle);
        $csv = stream_get_contents($handle) ?: '';
        fclose($handle);

        return $csv;
    }
}
