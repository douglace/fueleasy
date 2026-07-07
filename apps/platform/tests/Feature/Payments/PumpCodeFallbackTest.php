<?php

declare(strict_types=1);

namespace Tests\Feature\Payments;

use App\Application\Identity\DeviceTokenIssuer;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Stations\PumpStatus;
use App\Models\AuthorizedStation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

/**
 * Fallback de saisie manuelle du code pompe quand le scan QR est impossible.
 */
class PumpCodeFallbackTest extends TestCase
{
    use RefreshDatabase;

    private function tokenFor(User $user, string $deviceId = 'dev-1'): string
    {
        return app(DeviceTokenIssuer::class)->issue($user, $deviceId);
    }

    public function test_scan_by_pump_code_resolves_station_and_pump(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => $s->pump->code])
            ->assertOk()
            ->assertJsonPath('via', 'code')
            ->assertJsonPath('station.id', $s->station->id)
            ->assertJsonPath('pump.id', $s->pump->id)
            ->assertJsonPath('pompiste_id', null);
    }

    public function test_pump_code_is_case_insensitive(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => strtolower($s->pump->code)])
            ->assertOk()
            ->assertJsonPath('pump.id', $s->pump->id);
    }

    public function test_unknown_pump_code_is_rejected(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => 'ZZZZZZ'])
            ->assertUnprocessable()
            ->assertJsonPath('reason', 'pump_code_unknown');
    }

    public function test_invalid_code_format_is_rejected_without_oracle(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        // Même raison qu'un code inconnu : pas d'indice sur le format attendu.
        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => 'AB'])
            ->assertUnprocessable()
            ->assertJsonPath('reason', 'pump_code_unknown');
    }

    public function test_inactive_pump_code_is_rejected(): void
    {
        $s = new PaymentScenario;
        $s->pump->update(['status' => PumpStatus::Inactive]);
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => $s->pump->code])
            ->assertUnprocessable()
            ->assertJsonPath('reason', 'pump_inactive');
    }

    public function test_revoked_fixed_qr_does_not_disable_the_manual_code(): void
    {
        // Le kill-switch du QR fixe (sticker compromis) ne doit pas couper le
        // canal de secours : le code manuel suit uniquement le statut pompe.
        $s = new PaymentScenario;
        $s->pump->update(['fixed_qr_active' => false]);
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => $s->pump->code])
            ->assertOk()
            ->assertJsonPath('via', 'code');
    }

    public function test_sending_both_qr_and_code_is_a_validation_error(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', [
            'qr' => $s->pump->fixed_qr_token,
            'code' => $s->pump->code,
        ])->assertUnprocessable()->assertJsonValidationErrors(['qr']);
    }

    public function test_full_payment_by_pump_code_from_creation_to_pin_confirmation(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 100_000);
        $token = $this->tokenFor($s->driver);

        $created = $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'code' => $s->pump->code,
            'fuel_type' => 'gasoil',
            'amount' => 30_000,
        ])->assertCreated()
            ->assertJsonPath('data.via', 'code')
            ->assertJsonPath('data.status', PaymentStatus::Pending->value);

        $paymentId = $created->json('data.id');

        $this->withToken($token)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin,
            'idempotency_key' => (string) Str::uuid(),
        ])->assertOk()
            ->assertJsonPath('data.status', PaymentStatus::Paid->value)
            ->assertJsonPath('data.via', 'code');

        $this->assertSame(170_000, $s->account->fresh()->balance);
        $this->assertSame(70_000, $s->budget->fresh()->balance);
        $this->assertDatabaseHas('payments', [
            'id' => $paymentId,
            'via' => 'code',
            'work_session_id' => null,
            'pompiste_id' => null,
        ]);
    }

    public function test_unauthorized_station_still_blocks_payment_creation_by_code(): void
    {
        $s = new PaymentScenario;
        AuthorizedStation::query()
            ->where('enterprise_organization_id', $s->enterprise->id)
            ->where('station_organization_id', $s->station->id)
            ->delete();
        $token = $this->tokenFor($s->driver);

        $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'code' => $s->pump->code,
            'fuel_type' => 'gasoil',
            'amount' => 10_000,
        ])->assertUnprocessable()->assertJsonPath('reason', 'station_not_authorized');
    }

    public function test_a_pompiste_cannot_use_the_scan_endpoint(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->pompiste);

        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['code' => $s->pump->code])
            ->assertForbidden();
    }
}
