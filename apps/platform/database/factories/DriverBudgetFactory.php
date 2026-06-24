<?php

namespace Database\Factories;

use App\Domain\DriverBudgets\BudgetMode;
use App\Models\DriverBudget;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DriverBudget>
 */
class DriverBudgetFactory extends Factory
{
    protected $model = DriverBudget::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $organization = Organization::factory()->enterprise();
        $amount = 50_000;

        return [
            'user_id' => User::factory()->driver($organization),
            'organization_id' => $organization,
            'mode' => BudgetMode::Manual,
            'amount' => $amount,
            'balance' => $amount,
            'last_reset_at' => now(),
            'next_reset_at' => null,
        ];
    }

    public function forDriver(User $driver): static
    {
        return $this->state(fn (array $attributes) => [
            'user_id' => $driver->id,
            'organization_id' => $driver->organization_id,
        ]);
    }

    public function balance(int $balance): static
    {
        return $this->state(fn (array $attributes) => ['balance' => $balance]);
    }
}
