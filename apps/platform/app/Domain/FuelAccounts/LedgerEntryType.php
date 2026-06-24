<?php

declare(strict_types=1);

namespace App\Domain\FuelAccounts;

enum LedgerEntryType: string
{
    case Credit = 'credit';
    case Debit = 'debit';
    case RefundCredit = 'refund_credit';

    /**
     * L'écriture augmente-t-elle le solde du compte ?
     */
    public function isIncrease(): bool
    {
        return $this === self::Credit || $this === self::RefundCredit;
    }
}
