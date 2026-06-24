<?php

namespace Database\Factories;

use App\Domain\Organizations\OrganizationCode;
use App\Domain\Organizations\OrganizationStatus;
use App\Domain\Organizations\OrganizationType;
use App\Models\Organization;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Organization>
 */
class OrganizationFactory extends Factory
{
    protected $model = Organization::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'code' => OrganizationCode::random()->value,
            'type' => OrganizationType::Enterprise,
            'name' => fake()->company(),
            'status' => OrganizationStatus::Active,
            'is_demo' => false,
            'contact_email' => fake()->companyEmail(),
            'contact_phone' => '+2376'.fake()->numerify('########'),
            'address' => fake()->address(),
            'settings' => null,
        ];
    }

    public function enterprise(): static
    {
        return $this->state(fn (array $attributes) => ['type' => OrganizationType::Enterprise]);
    }

    public function station(): static
    {
        return $this->state(fn (array $attributes) => ['type' => OrganizationType::Station]);
    }

    public function suspended(): static
    {
        return $this->state(fn (array $attributes) => ['status' => OrganizationStatus::Suspended]);
    }

    public function demo(): static
    {
        return $this->state(fn (array $attributes) => ['is_demo' => true]);
    }
}
