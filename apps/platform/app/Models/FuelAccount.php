<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Shared\Money;
use Database\Factories\FuelAccountFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Compte carburant réel d'une entreprise (argent prépayé en FCFA).
 *
 * @property int $id
 * @property int $organization_id
 * @property int $balance
 * @property-read Organization $organization
 */
class FuelAccount extends Model
{
    /** @use HasFactory<FuelAccountFactory> */
    use HasFactory;

    protected $fillable = ['organization_id', 'balance'];

    protected function casts(): array
    {
        return ['balance' => 'integer'];
    }

    public function balanceMoney(): Money
    {
        return Money::fromInt($this->balance);
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    /**
     * @return HasMany<LedgerEntry, $this>
     */
    public function ledgerEntries(): HasMany
    {
        return $this->hasMany(LedgerEntry::class);
    }
}
