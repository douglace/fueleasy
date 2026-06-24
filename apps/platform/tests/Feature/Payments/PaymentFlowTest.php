<?php

declare(strict_types=1);

namespace Tests\Feature\Payments;

use App\Application\Payments\CapturePayment;
use App\Application\Payments\CreatePaymentSession;
use App\Application\Payments\QrSigner;
use App\Application\Payments\ResolveScan;
use App\Domain\Payments\PaymentException;
use App\Domain\Payments\PaymentFailureReason;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Payments\QrType;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Models\AuthorizedStation;
use App\Models\LedgerEntry;
use App\Models\Payment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class PaymentFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_full_dynamic_qr_payment_debits_account_and_budget_atomically(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 100_000);

        $token = app(QrSigner::class)->signDynamic($s->workSession);
        $context = app(ResolveScan::class)->handle($token);
        $this->assertSame(QrType::Dynamic, $context->via);

        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt(30_000));
        $this->assertSame(PaymentStatus::Pending, $payment->status);

        $captured = app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());

        $this->assertSame(PaymentStatus::Paid, $captured->status);
        $this->assertNotNull($captured->confirmed_at);
        $this->assertSame(170_000, $s->account->fresh()->balance);
        $this->assertSame(70_000, $s->budget->fresh()->balance);

        $entry = LedgerEntry::query()->where('reference_type', 'payment')->where('reference_id', $payment->id)->firstOrFail();
        $this->assertSame(30_000, $entry->amount);
        $this->assertSame(170_000, $entry->balance_after);
        $this->assertDatabaseHas('audit_logs', ['action' => 'payment.captured']);
    }

    public function test_fixed_qr_is_the_backup_path_and_applies_the_same_rules(): void
    {
        $s = new PaymentScenario;
        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);

        $this->assertSame(QrType::Fixed, $context->via);

        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Super, Money::fromInt(15_000));
        $captured = app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());

        $this->assertSame(PaymentStatus::Paid, $captured->status);
        $this->assertSame(QrType::Fixed, $captured->via);
    }

    public function test_revoked_fixed_qr_is_rejected(): void
    {
        $s = new PaymentScenario;
        $s->pump->update(['fixed_qr_active' => false]);

        $this->expectExceptionObject(new PaymentException(PaymentFailureReason::QrRevoked));
        app(ResolveScan::class)->handle($s->pump->fixed_qr_token);
    }

    public function test_expired_dynamic_qr_is_rejected(): void
    {
        $s = new PaymentScenario;
        $token = app(QrSigner::class)->signDynamic($s->workSession, Carbon::now()->subSeconds(120));

        $this->expectException(PaymentException::class);
        app(ResolveScan::class)->handle($token);
    }

    public function test_unauthorized_station_blocks_before_creation(): void
    {
        $s = new PaymentScenario;
        AuthorizedStation::query()->where('station_organization_id', $s->station->id)->delete();

        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);

        $this->expectExceptionObject(new PaymentException(PaymentFailureReason::StationNotAuthorized));
        app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt(10_000));
    }

    public function test_insufficient_balance_blocks_before_creation(): void
    {
        $s = new PaymentScenario(accountBalance: 5_000, budgetBalance: 100_000);
        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);

        $this->expectExceptionObject(new PaymentException(PaymentFailureReason::BalanceInsufficient));
        app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt(10_000));
    }

    public function test_insufficient_budget_blocks_before_creation(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 4_000);
        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);

        $this->expectExceptionObject(new PaymentException(PaymentFailureReason::BudgetInsufficient));
        app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt(10_000));
    }

    public function test_fuel_not_available_on_pump_is_rejected(): void
    {
        $s = new PaymentScenario;
        $s->pump->update(['available_fuels' => [FuelType::Gasoil->value]]);
        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);

        $this->expectExceptionObject(new PaymentException(PaymentFailureReason::FuelUnavailable));
        app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Super, Money::fromInt(10_000));
    }

    public function test_expired_session_cannot_be_captured(): void
    {
        $s = new PaymentScenario;
        $payment = Payment::factory()->expired()->create([
            'organization_id' => $s->enterprise->id,
            'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id,
            'pump_id' => $s->pump->id,
            'amount' => 10_000,
        ]);

        try {
            app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());
            $this->fail('La capture aurait dû échouer.');
        } catch (PaymentException $e) {
            $this->assertSame(PaymentFailureReason::SessionExpired, $e->reason);
        }

        $this->assertSame(PaymentStatus::Expired, $payment->fresh()->status);
        $this->assertSame(200_000, $s->account->fresh()->balance);
    }

    public function test_wrong_pin_does_not_debit(): void
    {
        $s = new PaymentScenario;
        $context = app(ResolveScan::class)->handle($s->pump->fixed_qr_token);
        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt(10_000));

        try {
            app(CapturePayment::class)->handle($payment, '0000', (string) Str::uuid());
            $this->fail('PIN incorrect aurait dû échouer.');
        } catch (PaymentException $e) {
            $this->assertSame(PaymentFailureReason::InvalidPin, $e->reason);
        }

        $this->assertSame(PaymentStatus::Pending, $payment->fresh()->status);
        $this->assertSame(200_000, $s->account->fresh()->balance);
        $this->assertSame(1, $s->driver->fresh()->failed_pin_attempts);
    }
}
