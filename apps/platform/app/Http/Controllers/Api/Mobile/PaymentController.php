<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Mobile;

use App\Application\Operations\ReceiptRenderer;
use App\Application\Payments\CapturePayment;
use App\Application\Payments\CreatePaymentSession;
use App\Application\Payments\ResolveScan;
use App\Domain\Identity\Role;
use App\Domain\Shared\Money;
use App\Domain\Stations\FuelType;
use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class PaymentController extends Controller
{
    /**
     * Résout un QR scanné en contexte (station, pompe, pompiste éventuel).
     */
    public function scan(Request $request, ResolveScan $resolveScan): JsonResponse
    {
        $this->assertDriver($request);

        $data = $request->validate(['qr' => ['required', 'string']]);
        $context = $resolveScan->handle($data['qr']);

        return response()->json([
            'via' => $context->via->value,
            'station' => [
                'id' => $context->station->id,
                'name' => $context->station->name,
            ],
            'pump' => [
                'id' => $context->pump->id,
                'label' => $context->pump->label,
                'available_fuels' => $context->pump->available_fuels ?? [],
            ],
            'pompiste_id' => $context->pompisteId,
        ]);
    }

    /**
     * Crée une session de paiement (pending) après scan.
     */
    public function store(Request $request, ResolveScan $resolveScan, CreatePaymentSession $create): JsonResponse
    {
        $driver = $this->assertDriver($request);

        $data = $request->validate([
            'qr' => ['required', 'string'],
            'fuel_type' => ['required', 'string', 'in:'.implode(',', array_column(FuelType::cases(), 'value'))],
            'amount' => ['required', 'integer', 'min:1'],
        ]);

        $context = $resolveScan->handle($data['qr']);
        $payment = $create->handle($driver, $context, FuelType::from($data['fuel_type']), Money::fromInt($data['amount']));

        return (new PaymentResource($payment))->response()->setStatusCode(201);
    }

    /**
     * Confirme un paiement par PIN (idempotent).
     */
    public function confirm(Request $request, Payment $payment, CapturePayment $capture): JsonResponse
    {
        $driver = $this->assertDriver($request);
        abort_unless($payment->driver_id === $driver->id, Response::HTTP_FORBIDDEN);

        $data = $request->validate([
            'pin' => ['required', 'string'],
            'idempotency_key' => ['required', 'string', 'max:191'],
        ]);

        $captured = $capture->handle($payment, $data['pin'], $data['idempotency_key']);

        return (new PaymentResource($captured))->response();
    }

    public function show(Request $request, Payment $payment): JsonResponse
    {
        $driver = $this->assertDriver($request);
        abort_unless($payment->driver_id === $driver->id, Response::HTTP_FORBIDDEN);

        return (new PaymentResource($payment))->response();
    }

    /**
     * Reçu PDF d'un paiement réglé.
     */
    public function receipt(Request $request, Payment $payment, ReceiptRenderer $renderer): Response
    {
        $driver = $this->assertDriver($request);
        abort_unless($payment->driver_id === $driver->id, Response::HTTP_FORBIDDEN);
        abort_unless($payment->isPaid(), Response::HTTP_CONFLICT, 'Reçu disponible uniquement pour un paiement réglé.');

        return response($renderer->receiptPdf($payment), 200, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => 'inline; filename="recu-'.$payment->reference.'.pdf"',
        ]);
    }

    /**
     * Consultation par clé d'idempotence (reprise après perte réseau).
     */
    public function byIdempotencyKey(Request $request): JsonResponse
    {
        $driver = $this->assertDriver($request);
        $data = $request->validate(['idempotency_key' => ['required', 'string']]);

        $payment = Payment::query()
            ->where('driver_id', $driver->id)
            ->where('idempotency_key', $data['idempotency_key'])
            ->first();

        if ($payment === null) {
            return response()->json(['found' => false]);
        }

        return response()->json(['found' => true, 'payment' => new PaymentResource($payment)]);
    }

    public function history(Request $request): JsonResponse
    {
        $driver = $this->assertDriver($request);

        $payments = Payment::query()
            ->where('driver_id', $driver->id)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return response()->json(['data' => PaymentResource::collection($payments)]);
    }

    private function assertDriver(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === Role::Driver, Response::HTTP_FORBIDDEN, 'Réservé aux chauffeurs.');

        return $user;
    }
}
