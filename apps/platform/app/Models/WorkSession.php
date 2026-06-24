<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Stations\WorkSessionStatus;
use Database\Factories\WorkSessionFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * Session de travail d'un pompiste sur une pompe.
 *
 * @property int $id
 * @property int $organization_id
 * @property int $user_id
 * @property int $pump_id
 * @property WorkSessionStatus $status
 * @property Carbon $opened_at
 * @property Carbon|null $closed_at
 * @property-read User $pompiste
 * @property-read Pump $pump
 */
class WorkSession extends Model
{
    /** @use HasFactory<WorkSessionFactory> */
    use HasFactory;

    protected $fillable = [
        'organization_id', 'user_id', 'pump_id', 'status', 'opened_at', 'closed_at',
    ];

    protected function casts(): array
    {
        return [
            'status' => WorkSessionStatus::class,
            'opened_at' => 'datetime',
            'closed_at' => 'datetime',
        ];
    }

    public function isOpen(): bool
    {
        return $this->status->isOpen();
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function pompiste(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * @return BelongsTo<Pump, $this>
     */
    public function pump(): BelongsTo
    {
        return $this->belongsTo(Pump::class);
    }
}
