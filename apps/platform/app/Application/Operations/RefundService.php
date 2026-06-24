<?php

declare(strict_types=1);

namespace App\Application\Operations;

use App\Application\Audit\AuditLogger;
use App\Domain\FuelAccounts\LedgerEntryType;
use App\Domain\Operations\RefundStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\DomainException;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\LedgerEntry;
use App\Models\Payment;
use App\Models\RefundRequest;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Remboursement total : la station demande, l'admin Fusy approuve ou refuse.
 * L'approbation produit des écritures compensatoires (compte entreprise + budget
 * chauffeur) ; le paiement initial reste inchangé dans l'historique. La somme est
 * déduite du prochain reversement station (refund non rattaché à un lot).
 */
final class RefundService
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function request(Payment $payment, ?int $requestedBy = null, ?string $reason = null): RefundRequest
    {
        if (! $payment->isPaid()) {
            throw new DomainException('Seul un paiement réglé peut faire l’objet d’un remboursement.');
        }

        if (RefundRequest::query()->where('payment_id', $payment->id)->exists()) {
            throw new DomainException('Une demande de remboursement existe déjà pour ce paiement.');
        }

        $refund = RefundRequest::query()->create([
            'payment_id' => $payment->id,
            'station_organization_id' => $payment->station_organization_id,
            'requested_by' => $requestedBy,
            'status' => RefundStatus::Pending,
            'reason' => $reason,
        ]);

        $this->audit->record(
            action: 'refund.requested',
            subject: $refund,
            organizationId: $payment->station_organization_id,
            actorId: $requestedBy,
            context: ['payment_id' => $payment->id, 'amount' => $payment->amount],
        );

        return $refund;
    }

    public function approve(RefundRequest $refund, ?int $decidedBy = null): RefundRequest
    {
        return DB::transaction(function () use ($refund, $decidedBy): RefundRequest {
            /** @var RefundRequest $locked */
            $locked = RefundRequest::query()->whereKey($refund->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status !== RefundStatus::Pending) {
                throw new DomainException('Cette demande de remboursement a déjà été traitée.');
            }

            /** @var Payment $payment */
            $payment = Payment::query()->whereKey($locked->payment_id)->lockForUpdate()->firstOrFail();
            if ($payment->status !== PaymentStatus::Paid) {
                throw new DomainException('Le paiement n’est pas dans un état remboursable.');
            }

            $amount = $payment->amount;

            /** @var FuelAccount $account */
            $account = FuelAccount::query()
                ->where('organization_id', $payment->organization_id)
                ->lockForUpdate()
                ->firstOrFail();

            $newBalance = $account->balance + $amount;
            $account->balance = $newBalance;
            $account->save();

            LedgerEntry::query()->create([
                'fuel_account_id' => $account->id,
                'organization_id' => $account->organization_id,
                'entry_type' => LedgerEntryType::RefundCredit,
                'amount' => $amount,
                'balance_after' => $newBalance,
                'reference_type' => 'refund',
                'reference_id' => $locked->id,
                'created_by' => $decidedBy,
                'description' => 'Remboursement '.$payment->reference,
            ]);

            // Restitue le budget chauffeur (s'il existe encore).
            $budget = DriverBudget::query()
                ->where('user_id', $payment->driver_id)
                ->lockForUpdate()
                ->first();
            if ($budget !== null) {
                $budget->balance += $amount;
                $budget->save();
            }

            $payment->forceFill(['status' => PaymentStatus::Refunded])->save();

            $locked->forceFill([
                'status' => RefundStatus::Approved,
                'decided_by' => $decidedBy,
                'decided_at' => Carbon::now(),
            ])->save();

            $this->audit->record(
                action: 'refund.approved',
                subject: $locked,
                organizationId: $payment->station_organization_id,
                actorId: $decidedBy,
                context: ['payment_id' => $payment->id, 'amount' => $amount],
            );

            return $locked;
        });
    }

    public function reject(RefundRequest $refund, ?int $decidedBy = null): RefundRequest
    {
        return DB::transaction(function () use ($refund, $decidedBy): RefundRequest {
            /** @var RefundRequest $locked */
            $locked = RefundRequest::query()->whereKey($refund->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status !== RefundStatus::Pending) {
                throw new DomainException('Cette demande de remboursement a déjà été traitée.');
            }

            $locked->forceFill([
                'status' => RefundStatus::Rejected,
                'decided_by' => $decidedBy,
                'decided_at' => Carbon::now(),
            ])->save();

            $this->audit->record(
                action: 'refund.rejected',
                subject: $locked,
                organizationId: $locked->station_organization_id,
                actorId: $decidedBy,
            );

            return $locked;
        });
    }
}
