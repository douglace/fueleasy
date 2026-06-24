<?php

namespace Database\Factories;

use App\Domain\Operations\SettlementStatus;
use App\Models\Organization;
use App\Models\SettlementBatch;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<SettlementBatch>
 */
class SettlementBatchFactory extends Factory
{
    protected $model = SettlementBatch::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'station_organization_id' => Organization::factory()->station(),
            'reference' => 'LOT-'.strtoupper(Str::random(8)),
            'period_start' => now()->subWeek()->toDateString(),
            'period_end' => now()->toDateString(),
            'gross_sales' => 0,
            'refunds_deducted' => 0,
            'net_amount' => 0,
            'status' => SettlementStatus::Open,
        ];
    }
}
