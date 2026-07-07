<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Models\DeviceSession;
use App\Models\Organization;
use App\Models\SmsCode;
use App\Models\SmsMessage;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class MobileAuthTest extends TestCase
{
    use RefreshDatabase;

    private function driverWithTempPin(Organization $org): User
    {
        return User::factory()->driver($org)->create([
            'phone' => '+237699000111',
            'matricule' => 'MAT-001',
            'pin_hash' => Hash::make('0000'),
            'pin_is_temporary' => true,
        ]);
    }

    public function test_activation_sets_new_pin_registers_device_and_returns_token(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = $this->driverWithTempPin($org);

        $response = $this->postJson('/api/v1/mobile/auth/activate', [
            'organization_code' => $org->code,
            'identifier' => '+237699000111',
            'temporary_pin' => '0000',
            'new_pin' => '4729',
            'device_id' => 'device-A',
        ]);

        $response->assertCreated()->assertJsonStructure(['token', 'user' => ['id', 'role']]);

        $driver->refresh();
        $this->assertFalse($driver->pin_is_temporary);
        $this->assertTrue(Hash::check('4729', $driver->pin_hash));
        $this->assertSame('device-A', $driver->device_id);
        $this->assertDatabaseHas('sms_messages', ['purpose' => 'activation', 'user_id' => $driver->id]);
        $this->assertSame(1, DeviceSession::query()->where('user_id', $driver->id)->whereNull('revoked_at')->count());
    }

    public function test_login_on_registered_device_returns_token(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = $this->driverWithTempPin($org);

        $this->postJson('/api/v1/mobile/auth/activate', [
            'organization_code' => $org->code,
            'identifier' => 'MAT-001',
            'temporary_pin' => '0000',
            'new_pin' => '4729',
            'device_id' => 'device-A',
        ])->assertCreated();

        $this->postJson('/api/v1/mobile/auth/login', [
            'organization_code' => $org->code,
            'identifier' => 'MAT-001',
            'pin' => '4729',
            'device_id' => 'device-A',
        ])->assertOk()->assertJsonStructure(['token']);
    }

    public function test_login_from_another_device_is_rejected(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = $this->driverWithTempPin($org);
        $this->postJson('/api/v1/mobile/auth/activate', [
            'organization_code' => $org->code, 'identifier' => 'MAT-001',
            'temporary_pin' => '0000', 'new_pin' => '4729', 'device_id' => 'device-A',
        ])->assertCreated();

        $this->postJson('/api/v1/mobile/auth/login', [
            'organization_code' => $org->code, 'identifier' => 'MAT-001',
            'pin' => '4729', 'device_id' => 'device-B',
        ])->assertStatus(422);
    }

    public function test_device_change_revokes_old_session_via_sms_code(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = $this->driverWithTempPin($org);
        $this->postJson('/api/v1/mobile/auth/activate', [
            'organization_code' => $org->code, 'identifier' => 'MAT-001',
            'temporary_pin' => '0000', 'new_pin' => '4729', 'device_id' => 'device-A',
        ])->assertCreated();

        $this->postJson('/api/v1/mobile/auth/device/request', [
            'organization_code' => $org->code, 'identifier' => 'MAT-001',
            'pin' => '4729', 'device_id' => 'device-B',
        ])->assertOk();

        // Récupère le code envoyé par SMS (outbox simulée).
        $sms = SmsMessage::query()->where('purpose', 'device_change')->latest('id')->firstOrFail();
        preg_match('/(\d{6})/', $sms->body, $m);
        $code = $m[1];

        $this->postJson('/api/v1/mobile/auth/device/confirm', [
            'organization_code' => $org->code, 'identifier' => 'MAT-001',
            'sms_code' => $code, 'device_id' => 'device-B',
        ])->assertOk()->assertJsonStructure(['token']);

        $driver->refresh();
        $this->assertSame('device-B', $driver->device_id);
        $this->assertSame(1, DeviceSession::query()->where('user_id', $driver->id)->whereNull('revoked_at')->count());
        $this->assertNotNull(SmsCode::query()->latest('id')->first()->consumed_at);
    }

    public function test_login_with_correct_temporary_pin_returns_account_not_activated_reason(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $this->driverWithTempPin($org);

        $this->postJson('/api/v1/mobile/auth/login', [
            'organization_code' => $org->code,
            'identifier' => 'MAT-001',
            'pin' => '0000',
            'device_id' => 'device-A',
        ])->assertStatus(422)->assertJson(['reason' => 'account_not_activated']);
    }

    public function test_login_with_wrong_pin_on_unactivated_account_stays_generic(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $this->driverWithTempPin($org);

        // Sans le PIN temporaire, aucune fuite d'état : erreur générique, pas de reason.
        $this->postJson('/api/v1/mobile/auth/login', [
            'organization_code' => $org->code,
            'identifier' => 'MAT-001',
            'pin' => '9999',
            'device_id' => 'device-A',
        ])->assertStatus(422)
            ->assertJson(['message' => 'Identifiants invalides.'])
            ->assertJsonMissingPath('reason');
    }

    public function test_failed_logins_on_unactivated_account_feed_the_lockout(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = $this->driverWithTempPin($org);

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/v1/mobile/auth/login', [
                'organization_code' => $org->code, 'identifier' => 'MAT-001',
                'pin' => '9999', 'device_id' => 'device-A',
            ])->assertStatus(422);
        }

        $driver->refresh();
        $this->assertNotNull($driver->pin_locked_until);
        $this->assertTrue($driver->isPinLocked());
    }

    public function test_pin_lockout_after_five_failed_attempts(): void
    {
        $org = Organization::factory()->enterprise()->create();
        $driver = User::factory()->driver($org)->create([
            'matricule' => 'MAT-009', 'pin_hash' => Hash::make('1234'), 'pin_is_temporary' => false,
        ]);

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/v1/mobile/auth/login', [
                'organization_code' => $org->code, 'identifier' => 'MAT-009',
                'pin' => '0000', 'device_id' => 'device-A',
            ])->assertStatus(422);
        }

        $driver->refresh();
        $this->assertNotNull($driver->pin_locked_until);
        $this->assertTrue($driver->isPinLocked());
    }

    public function test_unauthenticated_request_is_rejected(): void
    {
        $this->getJson('/api/v1/mobile/me')->assertStatus(401);
    }
}
