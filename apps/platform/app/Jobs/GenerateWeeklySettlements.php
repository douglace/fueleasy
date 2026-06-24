<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Application\Operations\SettlementService;
use App\Domain\Organizations\OrganizationType;
use App\Models\Organization;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Carbon;

/**
 * Génère un lot hebdomadaire de reversement par station partenaire active.
 */
class GenerateWeeklySettlements implements ShouldQueue
{
    use Queueable;

    public function __construct(
        private readonly ?Carbon $periodStart = null,
        private readonly ?Carbon $periodEnd = null,
    ) {}

    /**
     * @return list<int> identifiants des lots générés
     */
    public function handle(SettlementService $settlements): array
    {
        $end = $this->periodEnd ?? Carbon::now();
        $start = $this->periodStart ?? $end->copy()->subWeek();
        $generated = [];

        Organization::query()
            ->where('type', OrganizationType::Station)
            ->orderBy('id')
            ->each(function (Organization $station) use ($settlements, $start, $end, &$generated): void {
                $batch = $settlements->generateForStation($station->id, $start, $end);
                if ($batch !== null) {
                    $generated[] = $batch->id;
                }
            });

        return $generated;
    }
}
