<?php

declare(strict_types=1);

namespace App\Application\Operations;

use App\Application\Audit\AuditLogger;
use App\Domain\Operations\RefundStatus;
use App\Domain\Operations\SettlementStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\DomainException;
use App\Models\Payment;
use App\Models\RefundRequest;
use App\Models\SettlementBatch;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Reversements station : ventes Fusy réglées moins remboursements approuvés.
 * Un lot hebdomadaire fige les transactions non encore reversées ; l'admin Fusy
 * marque ensuite le lot comme payé (le reversement réel a lieu hors plateforme).
 */
final class SettlementService
{
    public function __construct(private readonly AuditLogger $audit) {}

    /**
     * Montant en attente de reversement pour une station (hors lots existants).
     */
    public function pendingAmount(int $stationOrganizationId): int
    {
        $sales = (int) Payment::query()
            ->where('station_organization_id', $stationOrganizationId)
            ->where('status', PaymentStatus::Paid)
            ->whereNull('settled_batch_id')
            ->sum('amount');

        // Seuls les remboursements de paiements DÉJÀ reversés sont déduits : un
        // paiement remboursé avant reversement quitte déjà le pool « payé ».
        $refunds = (int) RefundRequest::query()
            ->where('refund_requests.station_organization_id', $stationOrganizationId)
            ->where('refund_requests.status', RefundStatus::Approved)
            ->whereNull('refund_requests.settled_batch_id')
            ->join('payments', 'payments.id', '=', 'refund_requests.payment_id')
            ->whereNotNull('payments.settled_batch_id')
            ->sum('payments.amount');

        return $sales - $refunds;
    }

    public function generateForStation(int $stationOrganizationId, Carbon $periodStart, Carbon $periodEnd, ?int $actorId = null): ?SettlementBatch
    {
        return DB::transaction(function () use ($stationOrganizationId, $periodStart, $periodEnd, $actorId): ?SettlementBatch {
            $payments = Payment::query()
                ->where('station_organization_id', $stationOrganizationId)
                ->where('status', PaymentStatus::Paid)
                ->whereNull('settled_batch_id')
                ->where('confirmed_at', '<=', $periodEnd)
                ->lockForUpdate()
                ->get();

            $refunds = RefundRequest::query()
                ->where('station_organization_id', $stationOrganizationId)
                ->where('status', RefundStatus::Approved)
                ->whereNull('settled_batch_id')
                ->where('decided_at', '<=', $periodEnd)
                ->lockForUpdate()
                ->get();

            if ($payments->isEmpty() && $refunds->isEmpty()) {
                return null;
            }

            $grossSales = (int) $payments->sum('amount');
            // Déduit uniquement les remboursements de paiements déjà reversés dans un lot antérieur.
            $refundsDeducted = (int) $refunds->sum(function (RefundRequest $r): int {
                $payment = Payment::query()->whereKey($r->payment_id)->first(['amount', 'settled_batch_id']);

                return ($payment !== null && $payment->settled_batch_id !== null) ? $payment->amount : 0;
            });

            $batch = SettlementBatch::query()->create([
                'station_organization_id' => $stationOrganizationId,
                'reference' => 'LOT-'.strtoupper(Str::random(8)),
                'period_start' => $periodStart->toDateString(),
                'period_end' => $periodEnd->toDateString(),
                'gross_sales' => $grossSales,
                'refunds_deducted' => $refundsDeducted,
                'net_amount' => $grossSales - $refundsDeducted,
                'status' => SettlementStatus::Open,
            ]);

            Payment::query()->whereIn('id', $payments->pluck('id'))->update(['settled_batch_id' => $batch->id]);
            RefundRequest::query()->whereIn('id', $refunds->pluck('id'))->update(['settled_batch_id' => $batch->id]);

            $this->audit->record(
                action: 'settlement.generated',
                subject: $batch,
                organizationId: $stationOrganizationId,
                actorId: $actorId,
                context: ['net_amount' => $batch->net_amount],
            );

            return $batch;
        });
    }

    public function markPaid(SettlementBatch $batch, ?int $actorId = null): SettlementBatch
    {
        return DB::transaction(function () use ($batch, $actorId): SettlementBatch {
            /** @var SettlementBatch $locked */
            $locked = SettlementBatch::query()->whereKey($batch->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status->isPaid()) {
                throw new DomainException('Ce lot est déjà marqué comme payé.');
            }

            $locked->forceFill([
                'status' => SettlementStatus::Paid,
                'paid_at' => Carbon::now(),
                'marked_by' => $actorId,
            ])->save();

            $this->audit->record(
                action: 'settlement.paid',
                subject: $locked,
                organizationId: $locked->station_organization_id,
                actorId: $actorId,
                context: ['net_amount' => $locked->net_amount],
            );

            return $locked;
        });
    }
}
