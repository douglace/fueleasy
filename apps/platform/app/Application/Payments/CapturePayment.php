<?php

declare(strict_types=1);

namespace App\Application\Payments;

use App\Application\Audit\AuditLogger;
use App\Application\Identity\PinVerifier;
use App\Domain\FuelAccounts\LedgerEntryType;
use App\Domain\Identity\PinVerificationResult;
use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Jobs\SendPaymentAlertFallback;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\LedgerEntry;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Confirme et capture un paiement. Le débit (compte entreprise + budget chauffeur
 * + paiement + écriture ledger) est atomique dans une seule transaction PostgreSQL.
 *
 * Les effets qui doivent survivre à un échec du débit (marquage d'expiration,
 * comptage des tentatives PIN) sont committés dans des transactions distinctes,
 * avant la transaction de débit, pour ne pas être annulés par son rollback.
 */
final class CapturePayment
{
    public function __construct(
        private readonly CheckPaymentEligibility $eligibility,
        private readonly PinVerifier $pinVerifier,
        private readonly AuditLogger $audit,
    ) {}

    public function handle(Payment $payment, string $pin, string $idempotencyKey, ?Carbon $now = null): Payment
    {
        $now ??= Carbon::now();

        // Phase 1 — résolution des états terminaux (committée indépendamment).
        $resolved = $this->resolveTerminalState($payment, $now);
        if ($resolved !== null) {
            if ($resolved->status === PaymentStatus::Paid) {
                return $resolved; // idempotent
            }

            throw new PaymentException(PaymentFailureReason::SessionExpired);
        }

        // Phase 2 — vérification du PIN (committée : compteur de tentatives / blocage persistés).
        $this->verifyDriverPin($payment->driver_id, $pin, $now);

        // Phase 3 — débit atomique.
        $captured = $this->captureAtomically($payment, $idempotencyKey, $now);

        // Alerte pompiste : SMS de secours si pas d'accusé de réception dans les délais.
        if ($captured->isPaid() && $captured->pompiste_id !== null) {
            SendPaymentAlertFallback::dispatch($captured->id)->afterCommit()->delay(now()->addSeconds(30));
        }

        return $captured;
    }

    private function resolveTerminalState(Payment $payment, Carbon $now): ?Payment
    {
        return DB::transaction(function () use ($payment, $now): ?Payment {
            /** @var Payment $locked */
            $locked = Payment::query()->whereKey($payment->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status === PaymentStatus::Paid) {
                return $locked;
            }

            if ($locked->status !== PaymentStatus::Pending) {
                return $locked;
            }

            if ($locked->isExpired($now)) {
                $locked->forceFill([
                    'status' => PaymentStatus::Expired,
                    'failure_reason' => PaymentFailureReason::SessionExpired->value,
                ])->save();
                $payment->setRawAttributes($locked->getAttributes(), true);

                return $locked;
            }

            return null;
        });
    }

    private function verifyDriverPin(int $driverId, string $pin, Carbon $now): void
    {
        $result = DB::transaction(function () use ($driverId, $pin, $now): PinVerificationResult {
            /** @var User $driver */
            $driver = User::query()->whereKey($driverId)->lockForUpdate()->firstOrFail();

            return $this->pinVerifier->verify($driver, $pin, $now);
        });

        if (! $result->isOk()) {
            throw new PaymentException(
                in_array($result, [PinVerificationResult::Locked, PinVerificationResult::RequiresAdminReset], true)
                    ? PaymentFailureReason::PinLocked
                    : PaymentFailureReason::InvalidPin,
            );
        }
    }

    private function captureAtomically(Payment $payment, string $idempotencyKey, Carbon $now): Payment
    {
        return DB::transaction(function () use ($payment, $idempotencyKey, $now): Payment {
            /** @var Payment $locked */
            $locked = Payment::query()->whereKey($payment->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->status === PaymentStatus::Paid) {
                return $locked; // idempotent : capture concurrente déjà aboutie
            }

            if ($locked->status !== PaymentStatus::Pending || $locked->isExpired($now)) {
                throw new PaymentException(PaymentFailureReason::SessionExpired);
            }

            $amount = Money::fromInt($locked->amount);

            /** @var User $driver */
            $driver = User::query()->findOrFail($locked->driver_id);
            $pump = Pump::query()->findOrFail($locked->pump_id);
            $context = new ScanContext(
                via: $locked->via,
                station: $pump->organization,
                pump: $pump,
            );

            /** @var FuelAccount|null $account */
            $account = FuelAccount::query()
                ->where('organization_id', $locked->organization_id)
                ->lockForUpdate()
                ->first();

            /** @var DriverBudget|null $budget */
            $budget = DriverBudget::query()
                ->where('user_id', $locked->driver_id)
                ->lockForUpdate()
                ->first();

            $this->eligibility->assertContext($driver, $context, $locked->fuel_type);
            $this->eligibility->assertFunds($account, $budget, $amount);

            /** @var FuelAccount $account */
            /** @var DriverBudget $budget */
            $newAccountBalance = $account->balance - $amount->amount;
            $account->balance = $newAccountBalance;
            $account->save();

            $budget->balance -= $amount->amount;
            $budget->save();

            $entry = LedgerEntry::query()->create([
                'fuel_account_id' => $account->id,
                'organization_id' => $account->organization_id,
                'entry_type' => LedgerEntryType::Debit,
                'amount' => $amount->amount,
                'balance_after' => $newAccountBalance,
                'reference_type' => 'payment',
                'reference_id' => $locked->id,
                'created_by' => $driver->id,
                'description' => 'Paiement '.$locked->reference,
            ]);

            $locked->forceFill([
                'status' => PaymentStatus::Paid,
                'confirmed_at' => $now,
                'idempotency_key' => $idempotencyKey,
                'ledger_entry_id' => $entry->id,
                'failure_reason' => null,
            ])->save();

            $this->audit->record(
                action: 'payment.captured',
                subject: $locked,
                organizationId: $locked->organization_id,
                actorId: $driver->id,
                context: ['amount' => $amount->amount, 'station_id' => $locked->station_organization_id],
            );

            $payment->setRawAttributes($locked->getAttributes(), true);

            return $locked;
        });
    }
}
