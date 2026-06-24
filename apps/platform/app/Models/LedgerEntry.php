<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\FuelAccounts\LedgerEntryType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Écriture immuable du ledger financier.
 *
 * @property int $id
 * @property int $fuel_account_id
 * @property int $organization_id
 * @property LedgerEntryType $entry_type
 * @property int $amount
 * @property int $balance_after
 * @property string|null $reference_type
 * @property int|null $reference_id
 * @property string|null $description
 * @property int|null $created_by
 * @property array<string, mixed>|null $metadata
 */
class LedgerEntry extends Model
{
    public const ?string UPDATED_AT = null;

    protected $fillable = [
        'fuel_account_id', 'organization_id', 'entry_type', 'amount', 'balance_after',
        'reference_type', 'reference_id', 'description', 'created_by', 'metadata',
    ];

    protected function casts(): array
    {
        return [
            'entry_type' => LedgerEntryType::class,
            'amount' => 'integer',
            'balance_after' => 'integer',
            'metadata' => 'array',
        ];
    }

    /**
     * @return BelongsTo<FuelAccount, $this>
     */
    public function fuelAccount(): BelongsTo
    {
        return $this->belongsTo(FuelAccount::class);
    }
}
