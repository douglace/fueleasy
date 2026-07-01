<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Application\Identity\DeviceTokenIssuer;
use App\Domain\Stations\PumpStatus;
use App\Models\Organization;
use App\Models\Pump;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class MobileWorkSessionApiTest extends TestCase
{
    use RefreshDatabase;

    private function tokenFor(User $user, string $deviceId = 'dev-1'): string
    {
        return app(DeviceTokenIssuer::class)->issue($user, $deviceId);
    }

    public function test_pompiste_lists_active_pumps_of_their_own_station(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->pompiste);

        $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk()
            ->assertJsonPath('data.0.id', $s->pump->id)
            ->assertJsonPath('data.0.label', $s->pump->label)
            ->assertJsonPath('data.0.available_fuels', ['gasoil', 'super']);
    }

    public function test_inactive_pumps_are_excluded(): void
    {
        $s = new PaymentScenario;
        Pump::factory()->create([
            'organization_id' => $s->station->id,
            'status' => PumpStatus::Inactive,
        ]);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk();

        $this->assertCount(1, $response->json('data'));
    }

    public function test_pumps_from_another_station_are_not_visible(): void
    {
        $s = new PaymentScenario;
        $otherStation = Organization::factory()->station()->create();
        Pump::factory()->create(['organization_id' => $otherStation->id]);
        $token = $this->tokenFor($s->pompiste);

        $response = $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertOk();

        $this->assertCount(1, $response->json('data'));
        $this->assertSame($s->pump->id, $response->json('data.0.id'));
    }

    public function test_a_driver_cannot_list_station_pumps(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->getJson('/api/v1/mobile/station/pumps')
            ->assertForbidden();
    }
}
