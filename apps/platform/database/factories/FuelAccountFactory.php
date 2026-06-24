<?php

namespace Database\Factories;

use App\Models\FuelAccount;
use App\Models\Organization;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<FuelAccount>
 */
class FuelAccountFactory extends Factory
{
    protected $model = FuelAccount::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'organization_id' => Organization::factory()->enterprise(),
            'balance' => 0,
        ];
    }

    public function withBalance(int $balance): static
    {
        return $this->state(fn (array $attributes) => ['balance' => $balance]);
    }
}
