<?php

namespace Database\Factories;

use App\Domain\Payments\PaymentStatus;
use App\Domain\Payments\QrType;
use App\Domain\Stations\FuelType;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Payment>
 */
class PaymentFactory extends Factory
{
    protected $model = Payment::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $enterprise = Organization::factory()->enterprise();
        $station = Organization::factory()->station();

        return [
            'reference' => 'FUSY-'.strtoupper(Str::random(8)),
            'short_code' => strtoupper(Str::random(6)),
            'organization_id' => $enterprise,
            'driver_id' => User::factory()->driver($enterprise),
            'station_organization_id' => $station,
            'pump_id' => Pump::factory()->state(['organization_id' => $station]),
            'via' => QrType::Dynamic,
            'fuel_type' => FuelType::Gasoil,
            'amount' => 10_000,
            'status' => PaymentStatus::Pending,
            'expires_at' => now()->addMinutes(5),
        ];
    }

    public function paid(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => PaymentStatus::Paid,
            'confirmed_at' => now(),
        ]);
    }

    public function expired(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => PaymentStatus::Pending,
            'expires_at' => now()->subMinute(),
        ]);
    }
}
