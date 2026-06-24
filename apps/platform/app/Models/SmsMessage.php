<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int $id
 * @property int|null $organization_id
 * @property int|null $user_id
 * @property string $to
 * @property string $purpose
 * @property string $body
 * @property array<string, mixed>|null $payload
 */
class SmsMessage extends Model
{
    public const ?string UPDATED_AT = null;

    protected $fillable = [
        'organization_id', 'user_id', 'to', 'purpose', 'body', 'payload',
    ];

    protected function casts(): array
    {
        return ['payload' => 'array'];
    }
}
