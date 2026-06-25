<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web\Station;

use App\Application\Identity\MobileAccountAdmin;
use App\Application\Operations\RefundService;
use App\Application\Operations\SettlementService;
use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Stations\FuelType;
use App\Domain\Stations\PumpStatus;
use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\SettlementBatch;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;

class StationDashboardController extends Controller
{
    public function index(Request $request, SettlementService $settlements): Response
    {
        $org = (int) $request->user()?->organization_id;

        $today = Payment::query()
            ->where('station_organization_id', $org)->where('status', PaymentStatus::Paid)
            ->whereDate('confirmed_at', now()->toDateString())->sum('amount');

        return Inertia::render('station/dashboard', [
            'stats' => [
                'todaySales' => (int) $today,
                'pendingAmount' => $settlements->pendingAmount($org),
                'pumps' => Pump::query()->where('organization_id', $org)->count(),
                'pompistes' => User::query()->where('organization_id', $org)->where('role', Role::Pompiste)->count(),
            ],
            'recentPayments' => Payment::query()
                ->where('station_organization_id', $org)->where('status', PaymentStatus::Paid)
                ->with('enterprise:id,name')->orderByDesc('id')->limit(8)->get()->map($this->mapPayment(...)),
        ]);
    }

    public function pumps(Request $request): Response
    {
        $org = (int) $request->user()?->organization_id;

        return Inertia::render('station/pumps', [
            'pumps' => Pump::query()->where('organization_id', $org)->orderBy('id')->get()
                ->map(fn (Pump $p): array => [
                    'id' => $p->id,
                    'label' => $p->label,
                    'status' => $p->status->value,
                    'fixed_qr_active' => $p->fixed_qr_active,
                    'available_fuels' => $p->available_fuels ?? [],
                ]),
            'fuels' => array_map(fn (FuelType $f): array => ['value' => $f->value, 'label' => $f->label()], FuelType::cases()),
        ]);
    }

    public function pompistes(Request $request): Response
    {
        $org = (int) $request->user()?->organization_id;

        return Inertia::render('station/pompistes', [
            'pompistes' => User::query()->where('organization_id', $org)->where('role', Role::Pompiste)
                ->orderByDesc('id')->get(['id', 'name', 'phone', 'matricule', 'status', 'pin_is_temporary'])
                ->map(fn (User $u): array => [
                    'id' => $u->id,
                    'name' => $u->name,
                    'phone' => $u->phone,
                    'matricule' => $u->matricule,
                    'status' => $u->status->value,
                    'pin_is_temporary' => $u->pin_is_temporary,
                ]),
        ]);
    }

    public function payments(Request $request): Response
    {
        $org = (int) $request->user()?->organization_id;

        return Inertia::render('station/payments', [
            'payments' => Payment::query()
                ->where('station_organization_id', $org)->with('enterprise:id,name')
                ->orderByDesc('id')->limit(200)->get()
                ->map(fn (Payment $p): array => [
                    'id' => $p->id,
                    'reference' => $p->reference,
                    'short_code' => $p->short_code,
                    'amount' => $p->amount,
                    'status' => $p->status->value,
                    'enterprise' => $p->enterprise->name,
                    'fuel_type' => $p->fuel_type->value,
                    'confirmed_at' => $p->confirmed_at?->toDateTimeString(),
                ]),
        ]);
    }

    public function settlements(Request $request, SettlementService $settlements): Response
    {
        $org = (int) $request->user()?->organization_id;

        $today = Payment::query()
            ->where('station_organization_id', $org)->where('status', PaymentStatus::Paid)
            ->whereDate('confirmed_at', now()->toDateString())->sum('amount');

        return Inertia::render('station/settlements', [
            'summary' => [
                'today_sales' => (int) $today,
                'pending_amount' => $settlements->pendingAmount($org),
            ],
            'batches' => SettlementBatch::query()->where('station_organization_id', $org)
                ->orderByDesc('id')->limit(50)->get(['id', 'reference', 'gross_sales', 'refunds_deducted', 'net_amount', 'status', 'paid_at']),
        ]);
    }

    public function storePump(Request $request): RedirectResponse
    {
        $org = (int) $request->user()?->organization_id;
        $data = $request->validate([
            'label' => ['required', 'string', 'max:64'],
            'available_fuels' => ['required', 'array', 'min:1'],
            'available_fuels.*' => ['in:'.implode(',', array_column(FuelType::cases(), 'value'))],
        ]);

        Pump::query()->create([
            'organization_id' => $org,
            'label' => $data['label'],
            'status' => PumpStatus::Active,
            'fixed_qr_token' => Str::random(40),
            'fixed_qr_active' => true,
            'available_fuels' => array_values($data['available_fuels']),
        ]);

        return back()->with('status', 'Pompe créée.');
    }

    public function togglePumpQr(Request $request, Pump $pump): RedirectResponse
    {
        $this->assertOwnership($request, $pump->organization_id);
        $pump->update(['fixed_qr_active' => ! $pump->fixed_qr_active]);

        return back()->with('status', 'QR fixe mis à jour.');
    }

    public function storePompiste(Request $request, MobileAccountAdmin $accounts): RedirectResponse
    {
        $org = $request->user()?->organization;
        abort_if($org === null, SymfonyResponse::HTTP_FORBIDDEN);
        $data = $request->validate([
            'name' => ['required', 'string', 'max:191'],
            'phone' => ['nullable', 'string', 'max:32'],
            'matricule' => ['nullable', 'string', 'max:64'],
        ]);

        $result = $accounts->create($org, Role::Pompiste, $data['name'], $data['phone'] ?? null, $data['matricule'] ?? null, $request->user()->id);

        return back()->with('status', 'Pompiste créé. PIN temporaire : '.$result['temporary_pin']);
    }

    public function resetPompistePin(Request $request, User $pompiste, MobileAccountAdmin $accounts): RedirectResponse
    {
        $this->assertOwnership($request, $pompiste->organization_id);
        $pin = $accounts->resetPin($pompiste, $request->user()?->id);

        return back()->with('status', 'Nouveau PIN temporaire : '.$pin);
    }

    public function suspendPompiste(Request $request, User $pompiste, MobileAccountAdmin $accounts): RedirectResponse
    {
        $this->assertOwnership($request, $pompiste->organization_id);
        $newStatus = $pompiste->status === UserStatus::Active ? UserStatus::Suspended : UserStatus::Active;
        $accounts->setStatus($pompiste, $newStatus, $request->user()?->id);

        return back()->with('status', 'Statut du pompiste mis à jour.');
    }

    public function requestRefund(Request $request, Payment $payment, RefundService $service): RedirectResponse
    {
        $this->assertOwnership($request, $payment->station_organization_id);
        $data = $request->validate(['reason' => ['nullable', 'string', 'max:191']]);

        $service->request($payment, $request->user()?->id, $data['reason'] ?? null);

        return back()->with('status', 'Demande de remboursement envoyée.');
    }

    private function assertOwnership(Request $request, int $organizationId): void
    {
        abort_unless($organizationId === $request->user()?->organization_id, SymfonyResponse::HTTP_FORBIDDEN);
    }

    /**
     * @return array<string, mixed>
     */
    private function mapPayment(Payment $p): array
    {
        return [
            'id' => $p->id,
            'reference' => $p->reference,
            'short_code' => $p->short_code,
            'amount' => $p->amount,
            'status' => $p->status->value,
            'enterprise' => $p->enterprise->name,
            'fuel_type' => $p->fuel_type->value,
            'confirmed_at' => $p->confirmed_at?->toDateTimeString(),
        ];
    }
}
