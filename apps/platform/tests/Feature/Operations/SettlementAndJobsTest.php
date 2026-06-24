<?php

declare(strict_types=1);

namespace Tests\Feature\Operations;

use App\Application\DriverBudgets\ResetDriverBudget;
use App\Application\Operations\RefundService;
use App\Application\Operations\SettlementService;
use App\Application\Operations\TransactionExporter;
use App\Application\Payments\CapturePayment;
use App\Application\Payments\CreatePaymentSession;
use App\Application\Payments\QrSigner;
use App\Application\Payments\ResolveScan;
use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Operations\SettlementStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Jobs\ExpireStalePayments;
use App\Jobs\GenerateWeeklySettlements;
use App\Jobs\ResetDueDriverBudgets;
use App\Models\DriverBudget;
use App\Models\Payment;
use App\Models\SettlementBatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class SettlementAndJobsTest extends TestCase
{
    use RefreshDatabase;

    private function capture(PaymentScenario $s, int $amount): Payment
    {
        $qr = app(QrSigner::class)->signDynamic($s->workSession);
        $context = app(ResolveScan::class)->handle($qr);
        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt($amount));

        return app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());
    }

    public function test_pending_amount_and_weekly_batch_account_for_refunds(): void
    {
        $s = new PaymentScenario(accountBalance: 500_000, budgetBalance: 500_000);
        $this->capture($s, 30_000);
        $this->capture($s, 20_000);
        $toRefund = $this->capture($s, 10_000);

        $settlements = app(SettlementService::class);
        $this->assertSame(60_000, $settlements->pendingAmount($s->station->id));

        // Un remboursement approuvé réduit le montant en attente.
        $admin = User::factory()->fusyAdmin()->create();
        $refund = app(RefundService::class)->request($toRefund, $s->pompiste->id);
        app(RefundService::class)->approve($refund, decidedBy: $admin->id);
        $this->assertSame(50_000, $settlements->pendingAmount($s->station->id));

        $batch = app(GenerateWeeklySettlements::class)->handle($settlements);
        $this->assertCount(1, $batch);

        $created = SettlementBatch::query()->firstOrFail();
        $this->assertSame(50_000, $created->gross_sales); // 2 ventes non remboursées (la 3e est refunded → pas paid)
        $this->assertSame(SettlementStatus::Open, $created->status);

        // Plus rien en attente après génération.
        $this->assertSame(0, $settlements->pendingAmount($s->station->id));

        $paid = $settlements->markPaid($created, actorId: $admin->id);
        $this->assertSame(SettlementStatus::Paid, $paid->status);
        $this->assertNotNull($paid->paid_at);
    }

    public function test_expire_stale_payments_job_marks_expired(): void
    {
        $s = new PaymentScenario;
        Payment::factory()->create([
            'organization_id' => $s->enterprise->id, 'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id, 'pump_id' => $s->pump->id,
            'status' => PaymentStatus::Pending, 'expires_at' => now()->subMinute(),
        ]);
        Payment::factory()->create([
            'organization_id' => $s->enterprise->id, 'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id, 'pump_id' => $s->pump->id,
            'status' => PaymentStatus::Pending, 'expires_at' => now()->addMinutes(5),
        ]);

        $count = app(ExpireStalePayments::class)->handle();

        $this->assertSame(1, $count);
        $this->assertSame(1, Payment::query()->where('status', PaymentStatus::Expired)->count());
        $this->assertSame(1, Payment::query()->where('status', PaymentStatus::Pending)->count());
    }

    public function test_reset_due_budgets_job_replaces_balances(): void
    {
        $driver = User::factory()->driver()->create();
        DriverBudget::factory()->forDriver($driver)->create([
            'mode' => BudgetMode::Weekly,
            'amount' => 40_000,
            'balance' => 5_000,
            'next_reset_at' => now()->subDay(),
        ]);

        $count = app(ResetDueDriverBudgets::class)->handle(app(ResetDriverBudget::class));

        $this->assertSame(1, $count);
        $this->assertSame(40_000, DriverBudget::query()->first()->balance);
    }

    public function test_csv_export_lists_transactions(): void
    {
        $s = new PaymentScenario(accountBalance: 500_000, budgetBalance: 500_000);
        $this->capture($s, 30_000);

        $payments = Payment::query()->with(['station', 'enterprise'])->get();
        $csv = app(TransactionExporter::class)->csv($payments);

        $this->assertStringContainsString('Référence', $csv);
        $this->assertStringContainsString('30000', $csv);
        $this->assertStringContainsString($s->station->name, $csv);
    }
}
