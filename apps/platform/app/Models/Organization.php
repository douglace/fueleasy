<?php

declare(strict_types=1);

namespace App\Models;

use App\Domain\Organizations\OrganizationStatus;
use App\Domain\Organizations\OrganizationType;
use Database\Factories\OrganizationFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

/**
 * @property int $id
 * @property string $code
 * @property OrganizationType $type
 * @property string $name
 * @property OrganizationStatus $status
 * @property bool $is_demo
 * @property string|null $contact_email
 * @property string|null $contact_phone
 * @property string|null $address
 * @property array<string, mixed>|null $settings
 */
class Organization extends Model
{
    /** @use HasFactory<OrganizationFactory> */
    use HasFactory;

    protected $fillable = [
        'code', 'type', 'name', 'status', 'is_demo',
        'contact_email', 'contact_phone', 'address', 'settings',
    ];

    protected function casts(): array
    {
        return [
            'type' => OrganizationType::class,
            'status' => OrganizationStatus::class,
            'is_demo' => 'boolean',
            'settings' => 'array',
        ];
    }

    public function isActive(): bool
    {
        return $this->status->isActive();
    }

    public function isEnterprise(): bool
    {
        return $this->type === OrganizationType::Enterprise;
    }

    public function isStation(): bool
    {
        return $this->type === OrganizationType::Station;
    }

    /**
     * @return HasMany<User, $this>
     */
    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * @return HasOne<FuelAccount, $this>
     */
    public function fuelAccount(): HasOne
    {
        return $this->hasOne(FuelAccount::class);
    }
}
