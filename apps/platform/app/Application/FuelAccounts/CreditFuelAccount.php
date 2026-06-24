<?php

declare(strict_types=1);

namespace App\Application\FuelAccounts;

use App\Application\Audit\AuditLogger;
use App\Domain\FuelAccounts\LedgerEntryType;
use App\Domain\Shared\Money;
use App\Models\FuelAccount;
use App\Models\LedgerEntry;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

/**
 * Crédite manuellement le compte carburant d'une entreprise, de façon atomique,
 * et enregistre l'écriture ledger correspondante + un log d'audit.
 */
final class CreditFuelAccount
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(
        FuelAccount $account,
        Money $amount,
        ?int $actorId = null,
        ?string $description = null,
        string $referenceType = 'manual_credit',
        ?int $referenceId = null,
    ): LedgerEntry {
        if ($amount->isZero()) {
            throw new InvalidArgumentException('Le montant du crédit doit être strictement positif.');
        }

        return DB::transaction(function () use ($account, $amount, $actorId, $description, $referenceType, $referenceId): LedgerEntry {
            /** @var FuelAccount $locked */
            $locked = FuelAccount::query()->whereKey($account->getKey())->lockForUpdate()->firstOrFail();

            $newBalance = $locked->balance + $amount->amount;
            $locked->balance = $newBalance;
            $locked->save();

            $entry = LedgerEntry::query()->create([
                'fuel_account_id' => $locked->id,
                'organization_id' => $locked->organization_id,
                'entry_type' => LedgerEntryType::Credit,
                'amount' => $amount->amount,
                'balance_after' => $newBalance,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'description' => $description,
                'created_by' => $actorId,
            ]);

            $this->audit->record(
                action: 'fuel_account.credited',
                subject: $locked,
                organizationId: $locked->organization_id,
                actorId: $actorId,
                context: ['amount' => $amount->amount, 'balance_after' => $newBalance],
            );

            $account->balance = $newBalance;

            return $entry;
        });
    }
}
