<?php

declare(strict_types=1);

namespace App\Application\Organizations;

use App\Application\Audit\AuditLogger;
use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use App\Domain\Organizations\OrganizationStatus;
use App\Domain\Organizations\OrganizationType;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Onboarding contrôlé d'une organisation par Fusy : création de l'organisation,
 * génération du code, compte carburant (entreprise) et premier administrateur.
 */
final class OnboardOrganization
{
    public function __construct(
        private readonly OrganizationCodeGenerator $codeGenerator,
        private readonly AuditLogger $audit,
    ) {}

    /**
     * @param  array{name:string, email:string, password:string, phone?:string|null}  $admin
     */
    public function handle(
        OrganizationType $type,
        string $name,
        array $admin,
        bool $isDemo = false,
        ?string $contactEmail = null,
        ?string $contactPhone = null,
        ?string $address = null,
        ?int $actorId = null,
    ): Organization {
        return DB::transaction(function () use ($type, $name, $admin, $isDemo, $contactEmail, $contactPhone, $address, $actorId): Organization {
            $organization = Organization::query()->create([
                'code' => $this->codeGenerator->generate()->value,
                'type' => $type,
                'name' => $name,
                'status' => OrganizationStatus::Active,
                'is_demo' => $isDemo,
                'contact_email' => $contactEmail,
                'contact_phone' => $contactPhone,
                'address' => $address,
            ]);

            if ($type === OrganizationType::Enterprise) {
                FuelAccount::query()->create(['organization_id' => $organization->id, 'balance' => 0]);
            }

            User::query()->create([
                'organization_id' => $organization->id,
                'name' => $admin['name'],
                'role' => $type === OrganizationType::Enterprise ? Role::EnterpriseAdmin : Role::StationAdmin,
                'status' => UserStatus::Active,
                'email' => $admin['email'],
                'phone' => $admin['phone'] ?? null,
                'password' => Hash::make($admin['password']),
            ]);

            $this->audit->record(
                action: 'organization.onboarded',
                subject: $organization,
                organizationId: $organization->id,
                actorId: $actorId,
                context: ['type' => $type->value, 'is_demo' => $isDemo],
            );

            return $organization;
        });
    }
}
