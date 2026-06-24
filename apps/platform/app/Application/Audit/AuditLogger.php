<?php

declare(strict_types=1);

namespace App\Application\Audit;

use App\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;

/**
 * Journalise les opérations sensibles (crédits, resets PIN, paiements, remboursements...).
 */
final class AuditLogger
{
    /**
     * @param  array<string, mixed>  $context
     */
    public function record(
        string $action,
        ?Model $subject = null,
        ?int $organizationId = null,
        ?int $actorId = null,
        array $context = [],
    ): AuditLog {
        return AuditLog::query()->create([
            'organization_id' => $organizationId,
            'actor_id' => $actorId,
            'action' => $action,
            'subject_type' => $subject !== null ? $subject::class : null,
            'subject_id' => $subject?->getKey(),
            'context' => $context === [] ? null : $context,
        ]);
    }
}
