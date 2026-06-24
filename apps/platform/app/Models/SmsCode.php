<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $user_id
 * @property string $purpose
 * @property string $code_hash
 * @property string|null $pending_device_id
 * @property Carbon $expires_at
 * @property Carbon|null $consumed_at
 */
class SmsCode extends Model
{
    protected $fillable = [
        'user_id', 'purpose', 'code_hash', 'pending_device_id', 'expires_at', 'consumed_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
            'consumed_at' => 'datetime',
        ];
    }

    public function isUsable(Carbon $now): bool
    {
        return $this->consumed_at === null && $this->expires_at->greaterThan($now);
    }
}
