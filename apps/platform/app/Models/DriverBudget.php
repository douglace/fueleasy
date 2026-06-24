<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Shared\Money;
use Database\Factories\DriverBudgetFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Budget (enveloppe d'autorisation) d'un chauffeur — distinct du solde réel entreprise.
 *
 * @property int $id
 * @property int $user_id
 * @property int $organization_id
 * @property BudgetMode $mode
 * @property int $amount
 * @property int $balance
 * @property Carbon|null $last_reset_at
 * @property Carbon|null $next_reset_at
 * @property-read User $driver
 */
class DriverBudget extends Model
{
    /** @use HasFactory<DriverBudgetFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id', 'organization_id', 'mode', 'amount', 'balance',
        'last_reset_at', 'next_reset_at',
    ];

    protected function casts(): array
    {
        return [
            'mode' => BudgetMode::class,
            'amount' => 'integer',
            'balance' => 'integer',
            'last_reset_at' => 'datetime',
            'next_reset_at' => 'datetime',
        ];
    }

    public function balanceMoney(): Money
    {
        return Money::fromInt($this->balance);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
