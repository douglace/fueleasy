<?php

declare(strict_types=1);

namespace Tests\Feature\Payments;

use App\Application\Identity\DeviceTokenIssuer;
use App\Application\Notifications\SmsSender;
use App\Application\Payments\CapturePayment;
use App\Application\Payments\CreatePaymentSession;
use App\Application\Payments\QrSigner;
use App\Application\Payments\ResolveScan;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Jobs\SendPaymentAlertFallback;
use App\Models\Payment;
use App\Models\SmsMessage;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Str;
use Tests\Support\PaymentScenario;
use Tests\TestCase;

class PaymentAlertTest extends TestCase
{
    use RefreshDatabase;

    private function capture(PaymentScenario $s, int $amount = 10_000): Payment
    {
        $qr = app(QrSigner::class)->signDynamic($s->workSession);
        $context = app(ResolveScan::class)->handle($qr);
        $payment = app(CreatePaymentSession::class)->handle($s->driver, $context, FuelType::Gasoil, Money::fromInt($amount));

        return app(CapturePayment::class)->handle($payment, $s->pin, (string) Str::uuid());
    }

    public function test_capture_dispatches_the_alert_fallback_job(): void
    {
        Queue::fake();
        $s = new PaymentScenario;
        $this->capture($s);

        Queue::assertPushed(SendPaymentAlertFallback::class);
    }

    public function test_fallback_job_sends_sms_when_not_acknowledged(): void
    {
        Queue::fake(); // évite l'exécution synchrone immédiate du job au moment de la capture
        $s = new PaymentScenario;
        $payment = $this->capture($s);

        app(SendPaymentAlertFallback::class, ['paymentId' => $payment->id])->handle(app(SmsSender::class));

        $this->assertDatabaseHas('sms_messages', ['purpose' => 'payment_alert', 'user_id' => $s->pompiste->id]);
        $this->assertNotNull($payment->fresh()->alert_sms_sent_at);
    }

    public function test_fallback_job_skips_sms_when_acknowledged(): void
    {
        Queue::fake();
        $s = new PaymentScenario;
        $payment = $this->capture($s);
        $payment->forceFill(['alert_acknowledged_at' => now()])->save();

        app(SendPaymentAlertFallback::class, ['paymentId' => $payment->id])->handle(app(SmsSender::class));

        $this->assertSame(0, SmsMessage::query()->where('purpose', 'payment_alert')->count());
    }

    public function test_pompiste_can_acknowledge_an_alert(): void
    {
        $s = new PaymentScenario;
        $payment = $this->capture($s);
        $token = app(DeviceTokenIssuer::class)->issue($s->pompiste, 'pump-dev');

        $this->withToken($token)->postJson("/api/v1/mobile/station/payments/{$payment->id}/ack")
            ->assertOk()->assertJsonPath('acknowledged', true);

        $this->assertNotNull($payment->fresh()->alert_acknowledged_at);
    }

    public function test_driver_can_download_a_receipt_pdf(): void
    {
        $s = new PaymentScenario;
        $payment = $this->capture($s);
        $token = app(DeviceTokenIssuer::class)->issue($s->driver, 'dev-x');

        $response = $this->withToken($token)->get("/api/v1/mobile/payments/{$payment->id}/receipt");
        $response->assertOk();
        $this->assertSame('application/pdf', $response->headers->get('Content-Type'));
        $this->assertStringStartsWith('%PDF', $response->getContent());
    }
}
