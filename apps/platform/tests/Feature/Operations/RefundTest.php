<?php

declare(strict_types=1);

namespace Tests\Feature\Operations;

use App\Application\Operations\RefundService;
use App\Application\Payments\CapturePayment;
use App\Application\Payments\CreatePaymentSession;
use App\Application\Payments\QrSigner;
use App\Application\Payments\ResolveScan;
use App\Domain\FuelAccounts\LedgerEntryType;
use App\Domain\Operations\RefundStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\DomainException;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Models\LedgerEntry;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class RefundTest extends TestCase
{
    use RefreshDatabase;

    private function capturedPayment(PaymentScenario $s, int $amount = 30_000): Payment
    {
        $qr = app(QrSigner::class)->signDynamic($s->workSession);
        $context = app(ResolveScan::class)->handle($qr);
        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt($amount));

        return app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());
    }

    public function test_approved_refund_creates_compensating_entries_and_keeps_original(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 100_000);
        $payment = $this->capturedPayment($s, 30_000);

        $this->assertSame(170_000, $s->account->fresh()->balance);
        $this->assertSame(70_000, $s->budget->fresh()->balance);

        $admin = User::factory()->fusyAdmin()->create();
        $refund = app(RefundService::class)->request($payment, $s->pompiste->id, 'Mauvais montant');
        $approved = app(RefundService::class)->approve($refund, decidedBy: $admin->id);

        $this->assertSame(RefundStatus::Approved, $approved->status);
        $this->assertSame(PaymentStatus::Refunded, $payment->fresh()->status);
        // Compte et budget restitués.
        $this->assertSame(200_000, $s->account->fresh()->balance);
        $this->assertSame(100_000, $s->budget->fresh()->balance);

        // Écriture compensatoire présente, écriture de débit initiale conservée.
        $this->assertSame(1, LedgerEntry::query()->where('entry_type', LedgerEntryType::RefundCredit)->count());
        $this->assertSame(1, LedgerEntry::query()->where('entry_type', LedgerEntryType::Debit)->where('reference_id', $payment->id)->count());
        $this->assertDatabaseHas('audit_logs', ['action' => 'refund.approved']);
    }

    public function test_refund_requires_a_paid_payment(): void
    {
        $s = new PaymentScenario;
        $pending = Payment::factory()->create([
            'organization_id' => $s->enterprise->id, 'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id, 'pump_id' => $s->pump->id,
            'status' => PaymentStatus::Pending,
        ]);

        $this->expectException(DomainException::class);
        app(RefundService::class)->request($pending);
    }

    public function test_rejected_refund_does_not_touch_balances(): void
    {
        $s = new PaymentScenario;
        $payment = $this->capturedPayment($s, 20_000);
        $admin = User::factory()->fusyAdmin()->create();
        $refund = app(RefundService::class)->request($payment);

        app(RefundService::class)->reject($refund, decidedBy: $admin->id);

        $this->assertSame(RefundStatus::Rejected, $refund->fresh()->status);
        $this->assertSame(PaymentStatus::Paid, $payment->fresh()->status);
        $this->assertSame(180_000, $s->account->fresh()->balance);
    }

    public function test_a_payment_cannot_be_refunded_twice(): void
    {
        $s = new PaymentScenario;
        $payment = $this->capturedPayment($s, 10_000);
        app(RefundService::class)->request($payment);

        $this->expectException(DomainException::class);
        app(RefundService::class)->request($payment);
    }
}
