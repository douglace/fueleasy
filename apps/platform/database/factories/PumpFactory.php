<?php

namespace Database\Factories;

use App\Domain\Stations\FuelType;
use App\Domain\Stations\PumpStatus;
use App\Models\Organization;
use App\Models\Pump;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Pump>
 */
class PumpFactory extends Factory
{
    protected $model = Pump::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'organization_id' => Organization::factory()->station(),
            'label' => 'Pompe '.fake()->unique()->numberBetween(1, 99),
            'status' => PumpStatus::Active,
            'fixed_qr_token' => Str::random(40),
            'fixed_qr_active' => true,
            'available_fuels' => [FuelType::Gasoil->value, FuelType::Super->value],
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => ['status' => PumpStatus::Inactive]);
    }

    public function fixedQrRevoked(): static
    {
        return $this->state(fn (array $attributes) => ['fixed_qr_active' => false]);
    }
}
