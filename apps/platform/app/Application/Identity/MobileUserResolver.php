<?php

declare(strict_types=1);

namespace App\Application\Identity;

use App\Domain\Identity\MobileAuthException;
use App\Domain\Identity\Role;
use App\Models\Organization;
use App\Models\User;

/**
 * Résout un compte mobile par (code organisation + téléphone/matricule).
 * L'unicité d'un compte mobile est définie par organisation + identifiant.
 */
final class MobileUserResolver
{
    public function resolve(string $organizationCode, string $identifier): User
    {
        $organization = Organization::query()->where('code', $organizationCode)->first();
        if ($organization === null || ! $organization->isActive()) {
            throw MobileAuthException::invalidCredentials();
        }

        $user = User::query()
            ->where('organization_id', $organization->id)
            ->whereIn('role', [Role::Driver, Role::Pompiste])
            ->where(function ($query) use ($identifier): void {
                $query->where('phone', $identifier)->orWhere('matricule', $identifier);
            })
            ->first();

        if ($user === null || ! $user->isActive()) {
            throw MobileAuthException::invalidCredentials();
        }

        return $user;
    }
}
