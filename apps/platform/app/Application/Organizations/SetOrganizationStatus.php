<?php

declare(strict_types=1);

namespace App\Application\Organizations;

use App\Application\Audit\AuditLogger;
use App\Domain\Organizations\OrganizationStatus;
use App\Models\Organization;

/**
 * Suspension / réactivation d'une organisation par l'admin Fusy.
 *
 * Aucun impact direct sur le moteur de paiement : CheckPaymentEligibility
 * refuse déjà toute entreprise ou station inactive (re-vérifié sous verrou
 * à la capture). La suspension ne révoque ni les sessions web des admins ni
 * les appareils mobiles — seuls les paiements sont bloqués (choix MVP).
 */
final class SetOrganizationStatus
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(Organization $organization, OrganizationStatus $status, ?int $actorId = null): Organization
    {
        $organization->forceFill(['status' => $status])->save();

        $this->audit->record(
            action: 'organization.status_changed',
            subject: $organization,
            organizationId: $organization->id,
            actorId: $actorId,
            context: ['status' => $status->value],
        );

        return $organization;
    }
}
