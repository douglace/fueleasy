<?php

declare(strict_types=1);

namespace Tests\Feature\Payments;

use App\Application\Payments\CapturePayment;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Stations\FuelType;
use App\Models\LedgerEntry;
use App\Models\Payment;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Support\Facades\DB;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

/**
 * Tests de concurrence réels (processus parallèles via pcntl_fork) sur PostgreSQL.
 * N'utilise pas RefreshDatabase : les enfants forkés doivent voir des données
 * committées, donc DatabaseMigrations (sans transaction enveloppante).
 */
class PaymentConcurrencyTest extends TestCase
{
    use DatabaseMigrations;

    /**
     * Fork $n processus exécutant $worker, attend la fin de tous, puis reconnecte.
     *
     * @param  callable(int):void  $worker
     */
    private function runConcurrently(int $n, callable $worker): void
    {
        DB::disconnect();

        $pids = [];
        for ($i = 0; $i < $n; $i++) {
            $pid = pcntl_fork();
            if ($pid === -1) {
                $this->fail('pcntl_fork a échoué.');
            }

            if ($pid === 0) {
                // Processus enfant : connexion fraîche, exécute le worker, sort.
                $code = 0;
                try {
                    DB::reconnect();
                    $worker($i);
                } catch (\Throwable) {
                    $code = 1;
                } finally {
                    DB::disconnect();
                }
                exit($code);
            }

            $pids[] = $pid;
        }

        foreach ($pids as $pid) {
            pcntl_waitpid($pid, $status);
        }

        DB::reconnect();
    }

    private function pendingPayment(PaymentScenario $s, int $amount): Payment
    {
        return Payment::factory()->create([
            'organization_id' => $s->enterprise->id,
            'driver_id' => $s->driver->id,
            'station_organization_id' => $s->station->id,
            'pump_id' => $s->pump->id,
            'fuel_type' => FuelType::Gasoil,
            'amount' => $amount,
            'status' => PaymentStatus::Pending,
            'expires_at' => now()->addMinutes(5),
        ]);
    }

    public function test_same_idempotency_key_concurrent_confirmations_debit_once(): void
    {
        $s = new PaymentScenario(accountBalance: 200_000, budgetBalance: 100_000);
        $payment = $this->pendingPayment($s, 40_000);
        $key = 'idem-fixed-key-123';

        $this->runConcurrently(8, function () use ($payment, $key, $s): void {
            app(CapturePayment::class)->handle($payment->fresh(), $s->pin, $key);
        });

        $this->assertSame(160_000, $s->account->fresh()->balance, 'Le compte ne doit être débité qu’une fois.');
        $this->assertSame(60_000, $s->budget->fresh()->balance, 'Le budget ne doit être débité qu’une fois.');
        $this->assertSame(PaymentStatus::Paid, $payment->fresh()->status);
        $this->assertSame(1, LedgerEntry::query()->where('reference_id', $payment->id)->where('reference_type', 'payment')->count());
    }

    public function test_two_concurrent_payments_cannot_overspend_the_balance(): void
    {
        // Solde 50 000 : un seul des deux paiements de 30 000 peut aboutir.
        $s = new PaymentScenario(accountBalance: 50_000, budgetBalance: 100_000);
        $paymentA = $this->pendingPayment($s, 30_000);
        $paymentB = $this->pendingPayment($s, 30_000);
        $ids = [$paymentA->id, $paymentB->id];

        $this->runConcurrently(2, function (int $i) use ($ids, $s): void {
            $payment = Payment::query()->findOrFail($ids[$i]);
            app(CapturePayment::class)->handle($payment, $s->pin, 'idem-'.$ids[$i]);
        });

        $paidCount = Payment::query()->whereIn('id', $ids)->where('status', PaymentStatus::Paid)->count();

        $this->assertSame(1, $paidCount, 'Un seul des deux paiements concurrents peut aboutir.');
        $this->assertSame(20_000, $s->account->fresh()->balance);
        $this->assertSame(1, LedgerEntry::query()->where('reference_type', 'payment')->count());
    }

    public function test_two_concurrent_payments_cannot_overspend_the_budget(): void
    {
        // Budget 50 000, solde large : un seul des deux paiements de 30 000 peut aboutir.
        $s = new PaymentScenario(accountBalance: 500_000, budgetBalance: 50_000);
        $paymentA = $this->pendingPayment($s, 30_000);
        $paymentB = $this->pendingPayment($s, 30_000);
        $ids = [$paymentA->id, $paymentB->id];

        $this->runConcurrently(2, function (int $i) use ($ids, $s): void {
            $payment = Payment::query()->findOrFail($ids[$i]);
            app(CapturePayment::class)->handle($payment, $s->pin, 'idem-'.$ids[$i]);
        });

        $paidCount = Payment::query()->whereIn('id', $ids)->where('status', PaymentStatus::Paid)->count();

        $this->assertSame(1, $paidCount, 'Un seul des deux paiements concurrents peut consommer le budget.');
        $this->assertSame(20_000, $s->budget->fresh()->balance);
    }

    public function test_network_loss_replay_by_idempotency_key_returns_same_payment(): void
    {
        // Simule la reprise après perte réseau : 2e envoi avec la même clé → même résultat, pas de second débit.
        $s = new PaymentScenario(accountBalance: 100_000, budgetBalance: 100_000);
        $payment = $this->pendingPayment($s, 25_000);
        $key = 'network-retry-key';

        $first = app(CapturePayment::class)->handle($payment->fresh(), $s->pin, $key);
        $second = app(CapturePayment::class)->handle($payment->fresh(), $s->pin, $key);

        $this->assertSame($first->id, $second->id);
        $this->assertSame(PaymentStatus::Paid, $second->status);
        $this->assertSame(75_000, $s->account->fresh()->balance, 'Le rejeu ne doit pas débiter une seconde fois.');
        $this->assertSame(1, LedgerEntry::query()->where('reference_id', $payment->id)->count());
    }
}
