<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Application\Audit\AuditLogger;
use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use App\Models\DeviceSession;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Gestion des comptes mobiles (chauffeurs/pompistes) par un admin d'organisation.
 * L'admin ne voit jamais le PIN personnel ; il ne peut que générer un PIN temporaire.
 *
 * @phpstan-type CreatedUser array{user: User, temporary_pin: string}
 */
final class MobileAccountAdmin
{
    public function __construct(private readonly AuditLogger $audit) {}

    /**
     * @return array{user: User, temporary_pin: string}
     */
    public function create(Organization $organization, Role $role, string $name, ?string $phone = null, ?string $matricule = null, ?int $actorId = null): array
    {
        $temporaryPin = $this->generatePin();

        $user = User::query()->create([
            'organization_id' => $organization->id,
            'name' => $name,
            'role' => $role,
            'status' => UserStatus::Active,
            'phone' => $phone,
            'matricule' => $matricule,
            'pin_hash' => Hash::make($temporaryPin),
            'pin_is_temporary' => true,
        ]);

        $this->audit->record(
            action: 'mobile_account.created',
            subject: $user,
            organizationId: $organization->id,
            actorId: $actorId,
            context: ['role' => $role->value],
        );

        return ['user' => $user, 'temporary_pin' => $temporaryPin];
    }

    public function update(User $user, string $name, ?string $phone = null, ?string $matricule = null, ?int $actorId = null): User
    {
        $user->forceFill([
            'name' => $name,
            'phone' => $phone,
            'matricule' => $matricule,
        ])->save();

        $this->audit->record(
            action: 'mobile_account.updated',
            subject: $user,
            organizationId: $user->organization_id,
            actorId: $actorId,
            context: ['changed' => array_keys($user->getChanges())],
        );

        return $user;
    }

    public function resetPin(User $user, ?int $actorId = null): string
    {
        $temporaryPin = $this->generatePin();

        $user->forceFill([
            'pin_hash' => Hash::make($temporaryPin),
            'pin_is_temporary' => true,
            'failed_pin_attempts' => 0,
            'pin_locked_until' => null,
            'requires_admin_reset' => false,
            'device_id' => null,
            'device_registered_at' => null,
        ])->save();

        // Révoque les sessions d'appareil existantes.
        $user->load('organization');
        DeviceSession::query()->where('user_id', $user->id)->whereNull('revoked_at')
            ->update(['revoked_at' => Carbon::now()]);

        $this->audit->record(
            action: 'mobile_account.pin_reset',
            subject: $user,
            organizationId: $user->organization_id,
            actorId: $actorId,
        );

        return $temporaryPin;
    }

    public function setStatus(User $user, UserStatus $status, ?int $actorId = null): User
    {
        $user->forceFill(['status' => $status])->save();

        if ($status === UserStatus::Suspended) {
            DeviceSession::query()->where('user_id', $user->id)->whereNull('revoked_at')
                ->update(['revoked_at' => Carbon::now()]);
        }

        $this->audit->record(
            action: 'mobile_account.status_changed',
            subject: $user,
            organizationId: $user->organization_id,
            actorId: $actorId,
            context: ['status' => $status->value],
        );

        return $user;
    }

    private function generatePin(): string
    {
        return str_pad((string) random_int(0, 9999), 4, '0', STR_PAD_LEFT);
    }
}
