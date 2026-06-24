<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Mobile;

use App\Application\Payments\QrSigner;
use App\Application\Stations\CloseWorkSession;
use App\Application\Stations\OpenWorkSession;
use App\Domain\Identity\Role;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Stations\WorkSessionStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\User;
use App\Models\WorkSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class WorkSessionController extends Controller
{
    public function open(Request $request, OpenWorkSession $open): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);
        $data = $request->validate(['pump_id' => ['required', 'integer']]);

        $pump = Pump::query()->where('organization_id', $pompiste->organization_id)->whereKey($data['pump_id'])->firstOrFail();
        $session = $open->handle($pompiste, $pump);

        return response()->json($this->sessionPayload($session, $request), 201);
    }

    public function close(Request $request, WorkSession $workSession, CloseWorkSession $close): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);
        abort_unless($workSession->user_id === $pompiste->id, Response::HTTP_FORBIDDEN);

        $close->handle($workSession, $pompiste->id);

        return response()->json(['status' => WorkSessionStatus::Closed->value]);
    }

    /**
     * Renvoie le QR dynamique signé de la session ouverte (renouvelé à chaque appel).
     */
    public function currentQr(Request $request, QrSigner $signer): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);

        $session = WorkSession::query()
            ->where('user_id', $pompiste->id)
            ->where('status', WorkSessionStatus::Open)
            ->latest('id')
            ->first();

        if ($session === null) {
            return response()->json(['message' => 'Aucune session ouverte.'], 404);
        }

        return response()->json([
            'qr' => $signer->signDynamic($session),
            'expires_in' => QrSigner::TTL_SECONDS,
            'pump_id' => $session->pump_id,
            'work_session_id' => $session->id,
        ]);
    }

    /**
     * Paiements du jour reçus par la station du pompiste (alertes / preuve serveur).
     */
    public function todaysPayments(Request $request): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);

        $payments = Payment::query()
            ->where('station_organization_id', $pompiste->organization_id)
            ->where('status', PaymentStatus::Paid)
            ->whereDate('confirmed_at', now()->toDateString())
            ->orderByDesc('confirmed_at')
            ->limit(100)
            ->get();

        return response()->json(['data' => PaymentResource::collection($payments)]);
    }

    /**
     * Accusé de réception d'une alerte de paiement (désactive le SMS de secours).
     */
    public function acknowledge(Request $request, Payment $payment): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);
        abort_unless($payment->station_organization_id === $pompiste->organization_id, Response::HTTP_FORBIDDEN);

        if ($payment->alert_acknowledged_at === null) {
            $payment->forceFill(['alert_acknowledged_at' => now()])->save();
        }

        return response()->json(['acknowledged' => true]);
    }

    /**
     * Recherche d'une transaction par code court (vérification avant de servir).
     */
    public function search(Request $request): JsonResponse
    {
        $pompiste = $this->assertPompiste($request);
        $data = $request->validate(['code' => ['required', 'string']]);

        $payment = Payment::query()
            ->where('station_organization_id', $pompiste->organization_id)
            ->where('short_code', strtoupper($data['code']))
            ->first();

        if ($payment === null) {
            return response()->json(['found' => false]);
        }

        return response()->json(['found' => true, 'payment' => new PaymentResource($payment)]);
    }

    /**
     * @return array<string, mixed>
     */
    private function sessionPayload(WorkSession $session, Request $request): array
    {
        return [
            'work_session_id' => $session->id,
            'pump_id' => $session->pump_id,
            'status' => $session->status->value,
            'qr' => app(QrSigner::class)->signDynamic($session),
            'expires_in' => QrSigner::TTL_SECONDS,
        ];
    }

    private function assertPompiste(Request $request): User
    {
        /** @var User $user */
        $user = $request->user();
        abort_unless($user->role === Role::Pompiste, Response::HTTP_FORBIDDEN, 'Réservé aux pompistes.');

        return $user;
    }
}
