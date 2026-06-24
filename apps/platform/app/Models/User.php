<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Carbon;
use Laravel\Fortify\Contracts\PasskeyUser;
use Laravel\Fortify\PasskeyAuthenticatable;
use Laravel\Fortify\TwoFactorAuthenticatable;

/**
 * @property int $id
 * @property int|null $organization_id
 * @property string|null $name
 * @property Role $role
 * @property UserStatus $status
 * @property string|null $email
 * @property string|null $phone
 * @property string|null $matricule
 * @property Carbon|null $email_verified_at
 * @property string|null $password
 * @property string|null $pin_hash
 * @property bool $pin_is_temporary
 * @property Carbon|null $pin_changed_at
 * @property int $failed_pin_attempts
 * @property Carbon|null $pin_locked_until
 * @property bool $requires_admin_reset
 * @property string|null $device_id
 * @property Carbon|null $device_registered_at
 * @property string|null $two_factor_secret
 * @property string|null $two_factor_recovery_codes
 * @property Carbon|null $two_factor_confirmed_at
 * @property string|null $remember_token
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read Organization|null $organization
 */
class User extends Authenticatable implements PasskeyUser
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable, PasskeyAuthenticatable, TwoFactorAuthenticatable;

    protected $fillable = [
        'organization_id', 'name', 'role', 'status',
        'email', 'phone', 'matricule', 'password',
        'pin_hash', 'pin_is_temporary', 'pin_changed_at',
        'failed_pin_attempts', 'pin_locked_until', 'requires_admin_reset',
        'device_id', 'device_registered_at',
    ];

    protected $hidden = [
        'password', 'pin_hash',
        'two_factor_secret', 'two_factor_recovery_codes', 'remember_token',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => Role::class,
            'status' => UserStatus::class,
            'pin_is_temporary' => 'boolean',
            'pin_changed_at' => 'datetime',
            'pin_locked_until' => 'datetime',
            'requires_admin_reset' => 'boolean',
            'device_registered_at' => 'datetime',
            'two_factor_confirmed_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<Organization, $this>
     */
    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function isFusyAdmin(): bool
    {
        return $this->role === Role::FusyAdmin;
    }

    public function isEnterpriseAdmin(): bool
    {
        return $this->role === Role::EnterpriseAdmin;
    }

    public function isStationAdmin(): bool
    {
        return $this->role === Role::StationAdmin;
    }

    public function isActive(): bool
    {
        return $this->status === UserStatus::Active;
    }

    /**
     * Un utilisateur (hors Admin Fusy) ne peut accéder qu'aux données de son organisation.
     */
    public function belongsToOrganization(int $organizationId): bool
    {
        return $this->organization_id === $organizationId;
    }

    public function isPinLocked(): bool
    {
        return $this->pin_locked_until !== null && $this->pin_locked_until->isFuture();
    }
}
