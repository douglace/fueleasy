<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Operations\SettlementStatus;
use Database\Factories\SettlementBatchFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $station_organization_id
 * @property string $reference
 * @property Carbon $period_start
 * @property Carbon $period_end
 * @property int $gross_sales
 * @property int $refunds_deducted
 * @property int $net_amount
 * @property SettlementStatus $status
 * @property Carbon|null $paid_at
 * @property int|null $marked_by
 */
class SettlementBatch extends Model
{
    /** @use HasFactory<SettlementBatchFactory> */
    use HasFactory;

    protected $fillable = [
        'station_organization_id', 'reference', 'period_start', 'period_end',
        'gross_sales', 'refunds_deducted', 'net_amount', 'status', 'paid_at', 'marked_by',
    ];

    protected function casts(): array
    {
        return [
            'period_start' => 'date',
            'period_end' => 'date',
            'gross_sales' => 'integer',
            'refunds_deducted' => 'integer',
            'net_amount' => 'integer',
            'status' => SettlementStatus::class,
            'paid_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function station(): BelongsTo
    {
        return $this->belongsTo(Organization::class, 'station_organization_id');
    }
}
