<?php

declare(strict_types=1);

namespace App\Application\Operations;

use App\Models\Payment;
use Dompdf\Dompdf;
use Illuminate\Support\Collection;

/**
 * Génère des PDF simples : reçu de paiement et rapport de transactions.
 */
final class ReceiptRenderer
{
    public function receiptPdf(Payment $payment): string
    {
        $payment->loadMissing(['station', 'enterprise', 'pump']);

        $rows = [
            'Référence' => $payment->reference,
            'Code transaction' => $payment->short_code,
            'Statut' => $payment->status->value,
            'Date' => $payment->confirmed_at !== null ? $payment->confirmed_at->toDateTimeString() : '—',
            'Entreprise' => $payment->enterprise->name,
            'Station' => $payment->station->name,
            'Pompe' => $payment->pump->label,
            'Carburant' => $payment->fuel_type->label(),
            'Montant' => number_format($payment->amount, 0, ',', ' ').' FCFA',
        ];

        $html = '<html><head><meta charset="utf-8"><style>'
            .'body{font-family:DejaVu Sans,sans-serif;color:#111}'
            .'h1{font-size:20px}table{width:100%;border-collapse:collapse;margin-top:12px}'
            .'td{padding:6px 8px;border-bottom:1px solid #ddd;font-size:13px}'
            .'.k{color:#666;width:40%}</style></head><body>'
            .'<h1>Reçu Fusy</h1>';
        $html .= '<table>';
        foreach ($rows as $key => $value) {
            $html .= '<tr><td class="k">'.e($key).'</td><td>'.e((string) $value).'</td></tr>';
        }
        $html .= '</table><p style="margin-top:18px;font-size:11px;color:#888">'
            .'La preuve du paiement est l’historique serveur Fusy.</p></body></html>';

        return $this->render($html);
    }

    /**
     * @param  Collection<int, Payment>  $payments
     */
    public function transactionsPdf(Collection $payments, string $title = 'Transactions Fusy'): string
    {
        $html = '<html><head><meta charset="utf-8"><style>'
            .'body{font-family:DejaVu Sans,sans-serif;color:#111;font-size:11px}'
            .'h1{font-size:18px}table{width:100%;border-collapse:collapse;margin-top:10px}'
            .'th,td{padding:4px 6px;border-bottom:1px solid #ddd;text-align:left}'
            .'th{background:#f2f2f2}</style></head><body>';
        $html .= '<h1>'.e($title).'</h1><table><thead><tr>'
            .'<th>Référence</th><th>Date</th><th>Station</th><th>Carburant</th><th>Montant</th><th>Statut</th>'
            .'</tr></thead><tbody>';
        foreach ($payments as $payment) {
            $html .= '<tr>'
                .'<td>'.e($payment->reference).'</td>'
                .'<td>'.e($payment->confirmed_at !== null ? $payment->confirmed_at->toDateTimeString() : '').'</td>'
                .'<td>'.e($payment->station->name).'</td>'
                .'<td>'.e($payment->fuel_type->value).'</td>'
                .'<td>'.e(number_format($payment->amount, 0, ',', ' ')).'</td>'
                .'<td>'.e($payment->status->value).'</td>'
                .'</tr>';
        }
        $html .= '</tbody></table></body></html>';

        return $this->render($html);
    }

    private function render(string $html): string
    {
        $dompdf = new Dompdf;
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4');
        $dompdf->render();

        return (string) $dompdf->output();
    }
}
