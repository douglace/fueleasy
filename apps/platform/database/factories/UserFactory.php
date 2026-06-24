<?php

namespace Database\Factories;

use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use App\Models\Organization;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'organization_id' => null,
            'name' => fake()->name(),
            'role' => Role::FusyAdmin,
            'status' => UserStatus::Active,
            'email' => fake()->unique()->safeEmail(),
            'phone' => null,
            'matricule' => null,
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'pin_hash' => null,
            'pin_is_temporary' => false,
            'requires_admin_reset' => false,
            'remember_token' => Str::random(10),
            'two_factor_secret' => null,
            'two_factor_recovery_codes' => null,
            'two_factor_confirmed_at' => null,
        ];
    }

    public function fusyAdmin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => Role::FusyAdmin,
            'organization_id' => null,
        ]);
    }

    /**
     * @param  Organization|Factory<Organization>|null  $organization
     */
    public function enterpriseAdmin($organization = null): static
    {
        return $this->forOrganization($organization ?? Organization::factory()->enterprise(), Role::EnterpriseAdmin);
    }

    /**
     * @param  Organization|Factory<Organization>|null  $organization
     */
    public function stationAdmin($organization = null): static
    {
        return $this->forOrganization($organization ?? Organization::factory()->station(), Role::StationAdmin);
    }

    /**
     * @param  Organization|Factory<Organization>|null  $organization
     */
    public function driver($organization = null): static
    {
        return $this->mobile($organization ?? Organization::factory()->enterprise(), Role::Driver);
    }

    /**
     * @param  Organization|Factory<Organization>|null  $organization
     */
    public function pompiste($organization = null): static
    {
        return $this->mobile($organization ?? Organization::factory()->station(), Role::Pompiste);
    }

    /**
     * @param  Organization|Factory<Organization>  $organization
     */
    private function forOrganization($organization, Role $role): static
    {
        return $this->state(fn (array $attributes) => [
            'organization_id' => $organization,
            'role' => $role,
        ]);
    }

    /**
     * Utilisateur mobile : pas d'email/mot de passe, PIN à 4 chiffres.
     *
     * @param  Organization|Factory<Organization>  $organization
     */
    private function mobile($organization, Role $role): static
    {
        return $this->state(fn (array $attributes) => [
            'organization_id' => $organization,
            'role' => $role,
            'email' => null,
            'password' => null,
            'phone' => '+2376'.fake()->numerify('########'),
            'matricule' => strtoupper(fake()->bothify('MAT-####')),
            'pin_hash' => Hash::make('1234'),
            'pin_is_temporary' => true,
            'device_id' => null,
        ]);
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * Indicate that the model has two-factor authentication configured.
     */
    public function withTwoFactor(): static
    {
        return $this->state(fn (array $attributes) => [
            'two_factor_secret' => encrypt('secret'),
            'two_factor_recovery_codes' => encrypt(json_encode(['recovery-code-1'])),
            'two_factor_confirmed_at' => now(),
        ]);
    }
}
