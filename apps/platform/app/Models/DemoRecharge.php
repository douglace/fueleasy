<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Demo\DemoProvider;
use App\Domain\Demo\DemoRechargeStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $organization_id
 * @property DemoProvider $provider
 * @property int $amount
 * @property DemoRechargeStatus $status
 * @property string $reference
 * @property string|null $phone
 * @property Carbon|null $settled_at
 */
class DemoRecharge extends Model
{
    protected $fillable = [
        'organization_id', 'provider', 'amount', 'status', 'reference', 'phone', 'settled_at',
    ];

    protected function casts(): array
    {
        return [
            'provider' => DemoProvider::class,
            'amount' => 'integer',
            'status' => DemoRechargeStatus::class,
            'settled_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }
}
