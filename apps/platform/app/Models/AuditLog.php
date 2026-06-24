<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int|null $organization_id
 * @property int|null $actor_id
 * @property string $action
 * @property string|null $subject_type
 * @property int|null $subject_id
 * @property array<string, mixed>|null $context
 */
class AuditLog extends Model
{
    public const ?string UPDATED_AT = null;

    protected $fillable = [
        'organization_id', 'actor_id', 'action',
        'subject_type', 'subject_id', 'context',
    ];

    protected function casts(): array
    {
        return ['context' => 'array'];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}
