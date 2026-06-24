<?php

declare(strict_types=1);

namespace App\Application\Stations;

use App\Application\Audit\AuditLogger;
use App\Domain\Stations\WorkSessionStatus;
use App\Models\WorkSession;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

final class CloseWorkSession
{
    public function __construct(private readonly AuditLogger $audit) {}

    public function handle(WorkSession $session, ?int $actorId = null): WorkSession
    {
        return DB::transaction(function () use ($session, $actorId): WorkSession {
            /** @var WorkSession $locked */
            $locked = WorkSession::query()->whereKey($session->getKey())->lockForUpdate()->firstOrFail();

            if ($locked->isOpen()) {
                $locked->status = WorkSessionStatus::Closed;
                $locked->closed_at = Carbon::now();
                $locked->save();

                $this->audit->record(
                    action: 'work_session.closed',
                    subject: $locked,
                    organizationId: $locked->organization_id,
                    actorId: $actorId ?? $locked->user_id,
                );
            }

            return $locked->refresh();
        });
    }
}
