<?php

declare(strict_types=1);

namespace App\Application\Stations;

use App\Application\Audit\AuditLogger;
use App\Domain\Identity\Role;
use App\Domain\Shared\DomainException;
use App\Domain\Stations\WorkSessionStatus;
use App\Models\Pump;
use App\Models\User;
use App\Models\WorkSession;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Ouvre une session de travail pour un pompiste sur une pompe de sa station.
 * Un pompiste ne peut avoir qu'une session ouverte à la fois.
 */
final class OpenWorkSession
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(User $pompiste, Pump $pump): WorkSession
    {
        if ($pompiste->role !== Role::Pompiste) {
            throw new DomainException('Seul un pompiste peut ouvrir une session de travail.');
        }

        if ($pompiste->organization_id !== $pump->organization_id) {
            throw new DomainException('La pompe n’appartient pas à la station du pompiste.');
        }

        if (! $pump->isActive()) {
            throw new DomainException('La pompe est inactive.');
        }

        return DB::transaction(function () use ($pompiste, $pump): WorkSession {
            $alreadyOpen = WorkSession::query()
                ->where('user_id', $pompiste->id)
                ->where('status', WorkSessionStatus::Open)
                ->lockForUpdate()
                ->exists();

            if ($alreadyOpen) {
                throw new DomainException('Le pompiste a déjà une session ouverte.');
            }

            $session = WorkSession::query()->create([
                'organization_id' => $pompiste->organization_id,
                'user_id' => $pompiste->id,
                'pump_id' => $pump->id,
                'status' => WorkSessionStatus::Open,
                'opened_at' => Carbon::now(),
            ]);

            $this->audit->record(
                action: 'work_session.opened',
                subject: $session,
                organizationId: $pompiste->organization_id,
                actorId: $pompiste->id,
                context: ['pump_id' => $pump->id],
            );

            return $session;
        });
    }
}
