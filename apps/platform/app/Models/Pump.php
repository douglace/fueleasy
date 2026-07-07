<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Stations\FuelType;
use App\Domain\Stations\PumpStatus;
use Database\Factories\PumpFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $organization_id
 * @property string $label
 * @property string $code
 * @property PumpStatus $status
 * @property string|null $fixed_qr_token
 * @property bool $fixed_qr_active
 * @property array<int, string>|null $available_fuels
 * @property-read Organization $organization
 */
class Pump extends Model
{
    /** @use HasFactory<PumpFactory> */
    use HasFactory;

    protected $fillable = [
        'organization_id', 'label', 'code', 'status',
        'fixed_qr_token', 'fixed_qr_active', 'available_fuels',
    ];

    protected function casts(): array
    {
        return [
            'status' => PumpStatus::class,
            'fixed_qr_active' => 'boolean',
            'available_fuels' => 'array',
        ];
    }

    public function isActive(): bool
    {
        return $this->status->isActive();
    }

    public function offersFuel(FuelType $fuel): bool
    {
        return in_array($fuel->value, $this->available_fuels ?? [], true);
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }
}
