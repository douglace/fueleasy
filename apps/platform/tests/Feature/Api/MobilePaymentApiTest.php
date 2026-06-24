<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Application\Identity\DeviceTokenIssuer;
use App\Application\Payments\QrSigner;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Stations\FuelType;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class MobilePaymentApiTest extends TestCase
{
    use RefreshDatabase;

    private function tokenFor(User $user, string $deviceId = 'dev-1'): string
    {
        return app(DeviceTokenIssuer::class)->issue($user, $deviceId);
    }

    public function test_driver_completes_a_payment_over_the_api(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 100_000);
        $token = $this->tokenFor($s->driver);
        $qr = app(QrSigner::class)->signDynamic($s->workSession);

        // Scan
        $this->withToken($token)->postJson('/api/v1/mobile/scan', ['qr' => $qr])
            ->assertOk()->assertJsonPath('via', 'dynamic');

        // Création de session de paiement
        $create = $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'qr' => $qr, 'fuel_type' => FuelType::Gasoil->value, 'amount' => 30_000,
        ])->assertCreated();
        $paymentId = $create->json('data.id');

        // Confirmation par PIN
        $this->withToken($token)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin, 'idempotency_key' => 'key-1',
        ])->assertOk()->assertJsonPath('data.status', PaymentStatus::Paid->value);

        $this->assertSame(170_000, $s->account->fresh()->balance);
        $this->assertSame(70_000, $s->budget->fresh()->balance);
    }

    public function test_confirm_is_idempotent_over_the_api(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);
        $qr = app(QrSigner::class)->signDynamic($s->workSession);

        $paymentId = $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'qr' => $qr, 'fuel_type' => FuelType::Gasoil->value, 'amount' => 20_000,
        ])->json('data.id');

        $this->withToken($token)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin, 'idempotency_key' => 'same-key',
        ])->assertOk();
        $this->withToken($token)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin, 'idempotency_key' => 'same-key',
        ])->assertOk();

        $this->assertSame(180_000, $s->account->fresh()->balance);
    }

    public function test_by_key_lookup_supports_network_loss_recovery(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);
        $qr = app(QrSigner::class)->signDynamic($s->workSession);

        $paymentId = $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'qr' => $qr, 'fuel_type' => FuelType::Gasoil->value, 'amount' => 10_000,
        ])->json('data.id');
        $this->withToken($token)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin, 'idempotency_key' => 'net-key',
        ])->assertOk();

        $this->withToken($token)->getJson('/api/v1/mobile/payments/by-key?idempotency_key=net-key')
            ->assertOk()->assertJsonPath('found', true)->assertJsonPath('payment.status', PaymentStatus::Paid->value);
    }

    public function test_a_driver_cannot_confirm_another_drivers_payment(): void
    {
        $s = new PaymentScenario;
        $token = $this->tokenFor($s->driver);
        $qr = app(QrSigner::class)->signDynamic($s->workSession);
        $paymentId = $this->withToken($token)->postJson('/api/v1/mobile/payments', [
            'qr' => $qr, 'fuel_type' => FuelType::Gasoil->value, 'amount' => 10_000,
        ])->json('data.id');

        $intruder = User::factory()->driver($s->enterprise)->create([
            'pin_hash' => Hash::make('9999'), 'pin_is_temporary' => false,
        ]);
        $intruderToken = $this->tokenFor($intruder, 'dev-2');

        $this->withToken($intruderToken)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => '9999', 'idempotency_key' => 'x',
        ])->assertForbidden();
    }

    public function test_pompiste_opens_session_and_sees_paid_payment(): void
    {
        $s = new PaymentScenario;
        $driverToken = $this->tokenFor($s->driver);
        $pompisteToken = $this->tokenFor($s->pompiste, 'pump-dev');

        // Pompiste récupère le QR de sa session déjà ouverte.
        $qrResponse = $this->withToken($pompisteToken)->getJson('/api/v1/mobile/work-sessions/current/qr')->assertOk();
        $qr = $qrResponse->json('qr');

        $paymentId = $this->withToken($driverToken)->postJson('/api/v1/mobile/payments', [
            'qr' => $qr, 'fuel_type' => FuelType::Gasoil->value, 'amount' => 12_000,
        ])->json('data.id');
        $this->withToken($driverToken)->postJson("/api/v1/mobile/payments/{$paymentId}/confirm", [
            'pin' => $s->pin, 'idempotency_key' => 'p-key',
        ])->assertOk();

        $shortCode = Payment::query()->find($paymentId)->short_code;

        $this->withToken($pompisteToken)->getJson('/api/v1/mobile/station/payments/search?code='.$shortCode)
            ->assertOk()->assertJsonPath('found', true)->assertJsonPath('payment.status', 'paid');

        $this->withToken($pompisteToken)->getJson('/api/v1/mobile/station/payments/today')
            ->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_driver_endpoint_forbidden_for_pompiste(): void
    {
        $s = new PaymentScenario;
        $pompisteToken = $this->tokenFor($s->pompiste, 'pump-dev');

        $this->withToken($pompisteToken)->getJson('/api/v1/mobile/payments')->assertForbidden();
    }
}
