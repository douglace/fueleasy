<?php

namespace Database\Factories;

use App\Domain\Stations\WorkSessionStatus;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\User;
use App\Models\WorkSession;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WorkSession>
 */
class WorkSessionFactory extends Factory
{
    protected $model = WorkSession::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $station = Organization::factory()->station();

        return [
            'organization_id' => $station,
            'user_id' => User::factory()->pompiste($station),
            'pump_id' => Pump::factory()->state(['organization_id' => $station]),
            'status' => WorkSessionStatus::Open,
            'opened_at' => now(),
            'closed_at' => null,
        ];
    }

    public function closed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => WorkSessionStatus::Closed,
            'closed_at' => now(),
        ]);
    }
}
