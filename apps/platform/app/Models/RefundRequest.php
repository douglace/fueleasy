<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Operations\RefundStatus;
use Database\Factories\RefundRequestFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $payment_id
 * @property int $station_organization_id
 * @property int|null $requested_by
 * @property RefundStatus $status
 * @property string|null $reason
 * @property int|null $decided_by
 * @property Carbon|null $decided_at
 * @property int|null $settled_batch_id
 * @property-read Payment $payment
 */
class RefundRequest extends Model
{
    /** @use HasFactory<RefundRequestFactory> */
    use HasFactory;

    protected $fillable = [
        'payment_id', 'station_organization_id', 'requested_by', 'status',
        'reason', 'decided_by', 'decided_at', 'settled_batch_id',
    ];

    protected function casts(): array
    {
        return [
            'status' => RefundStatus::class,
            'decided_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<Payment, $this>
     */
    public function payment(): BelongsTo
    {
        return $this->belongsTo(Payment::class);
    }
}
