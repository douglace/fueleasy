<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Payments\PaymentStatus;
use App\Domain\Payments\QrType;
use App\Domain\Stations\FuelType;
use Database\Factories\PaymentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property string $reference
 * @property string $short_code
 * @property string|null $idempotency_key
 * @property int $organization_id
 * @property int $driver_id
 * @property int $station_organization_id
 * @property int $pump_id
 * @property int|null $work_session_id
 * @property int|null $pompiste_id
 * @property QrType $via
 * @property FuelType $fuel_type
 * @property int $amount
 * @property PaymentStatus $status
 * @property string|null $failure_reason
 * @property Carbon $expires_at
 * @property Carbon|null $confirmed_at
 * @property int|null $ledger_entry_id
 * @property-read Organization $enterprise
 * @property-read User $driver
 */
class Payment extends Model
{
    /** @use HasFactory<PaymentFactory> */
    use HasFactory;

    protected $fillable = [
        'reference', 'short_code', 'idempotency_key', 'organization_id', 'driver_id',
        'station_organization_id', 'pump_id', 'work_session_id', 'pompiste_id',
        'via', 'fuel_type', 'amount', 'status', 'failure_reason',
        'expires_at', 'confirmed_at', 'ledger_entry_id',
    ];

    protected function casts(): array
    {
        return [
            'via' => QrType::class,
            'fuel_type' => FuelType::class,
            'amount' => 'integer',
            'status' => PaymentStatus::class,
            'expires_at' => 'datetime',
            'confirmed_at' => 'datetime',
        ];
    }

    public function isPending(): bool
    {
        return $this->status === PaymentStatus::Pending;
    }

    public function isPaid(): bool
    {
        return $this->status === PaymentStatus::Paid;
    }

    public function isExpired(Carbon $now): bool
    {
        return $this->expires_at->lessThan($now);
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function enterprise(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'organization_id');
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function station(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'station_organization_id');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function driver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'driver_id');
    }

    /**
     * @return BelongsTo<Pump, $this>
     */
    public function pump(): BelongsTo
    {
        return $this->belongsTo(Pump::class);
    }
}
