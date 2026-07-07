<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web\Admin;

use App\Application\FuelAccounts\CreditFuelAccount;
use App\Application\Organizations\OnboardOrganization;
use App\Application\Organizations\SetOrganizationStatus;
use App\Domain\Identity\Role;
use App\Domain\Organizations\OrganizationStatus;
use App\Domain\Organizations\OrganizationType;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\AuthorizedStation;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\Pump;
use App\Models\RefundRequest;
use App\Models\User;
use App\Support\DashboardCharts;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;

class AdminDashboardController extends Controller
{
    public function index(): Response
    {
        $paid = Payment::query()->where('status', PaymentStatus::Paid);

        return Inertia::render('admin/dashboard', [
            'stats' => [
                'enterprises' => Organization::query()->where('type', OrganizationType::Enterprise)->count(),
                'stations' => Organization::query()->where('type', OrganizationType::Station)->count(),
                'paidPayments' => Payment::query()->where('status', PaymentStatus::Paid)->count(),
                'pendingRefunds' => RefundRequest::query()->where('status', 'pending')->count(),
                'totalBalance' => (int) FuelAccount::query()->sum('balance'),
            ],
            'charts' => [
                'volume' => DashboardCharts::volume($paid),
                'fuelMix' => DashboardCharts::fuelMix($paid),
            ],
            'recentPayments' => Payment::query()
                ->with(['station:id,name', 'enterprise:id,name'])
                ->orderByDesc('id')->limit(8)->get()->map($this->mapPayment(...)),
            'audit' => AuditLog::query()->orderByDesc('id')->limit(10)
                ->get(['id', 'action', 'organization_id', 'created_at']),
        ]);
    }

    public function organizations(): Response
    {
        $organizations = Organization::query()
            ->orderByDesc('id')->get(['id', 'code', 'type', 'name', 'status', 'is_demo'])
            ->map(fn (Organization $o): array => [
                'id' => $o->id,
                'code' => $o->code,
                'type' => $o->type->value,
                'name' => $o->name,
                'status' => $o->status->value,
                'is_demo' => $o->is_demo,
                'balance' => $o->isEnterprise()
                    ? (int) FuelAccount::query()->where('organization_id', $o->id)->value('balance')
                    : null,
            ]);

        return Inertia::render('admin/organizations', [
            'organizations' => $organizations,
            'enterprises' => $organizations->where('type', 'enterprise')->values(),
            'stations' => $organizations->where('type', 'station')->values(),
            'authorizations' => AuthorizedStation::query()->with(['enterprise:id,name', 'station:id,name'])->get()
                ->map(fn (AuthorizedStation $a): array => [
                    'id' => $a->id,
                    'enterprise' => $a->enterprise->name,
                    'station' => $a->station->name,
                ]),
        ]);
    }

    public function transactions(Request $request): Response
    {
        $filters = $request->validate([
            'status' => ['sometimes', 'nullable', 'in:'.implode(',', array_column(PaymentStatus::cases(), 'value'))],
            'enterprise_id' => ['sometimes', 'nullable', 'integer'],
            'station_id' => ['sometimes', 'nullable', 'integer'],
            'q' => ['sometimes', 'nullable', 'string', 'max:64'],
        ]);

        $q = trim((string) ($filters['q'] ?? ''));

        return Inertia::render('admin/transactions', [
            'payments' => Payment::query()
                ->with(['station:id,name', 'enterprise:id,name'])
                ->when($filters['status'] ?? null, fn (Builder $query, string $status) => $query->where('status', $status))
                ->when($filters['enterprise_id'] ?? null, fn (Builder $query, int $id) => $query->where('organization_id', $id))
                ->when($filters['station_id'] ?? null, fn (Builder $query, int $id) => $query->where('station_organization_id', $id))
                ->when($q !== '', fn (Builder $query) => $query->where(
                    fn (Builder $w) => $w->where('reference', 'ilike', "%{$q}%")->orWhere('short_code', strtoupper($q))
                ))
                ->orderByDesc('id')->limit(200)->get()->map($this->mapPayment(...)),
            'filters' => [
                'status' => $filters['status'] ?? null,
                'enterprise_id' => $filters['enterprise_id'] ?? null,
                'station_id' => $filters['station_id'] ?? null,
                'q' => $q !== '' ? $q : null,
            ],
            'enterprises' => Organization::query()->where('type', OrganizationType::Enterprise)
                ->orderBy('name')->get(['id', 'name']),
            'stations' => Organization::query()->where('type', OrganizationType::Station)
                ->orderBy('name')->get(['id', 'name']),
        ]);
    }

    /**
     * Vue lecture seule des pompes et pompistes d'une station.
     */
    public function stationDetail(Organization $organization): Response
    {
        abort_unless($organization->type === OrganizationType::Station, SymfonyResponse::HTTP_NOT_FOUND);

        return Inertia::render('admin/station-detail', [
            'station' => [
                'id' => $organization->id,
                'name' => $organization->name,
                'code' => $organization->code,
                'status' => $organization->status->value,
            ],
            'pumps' => Pump::query()->where('organization_id', $organization->id)->orderBy('id')->get()
                ->map(fn (Pump $p): array => [
                    'id' => $p->id,
                    'label' => $p->label,
                    'code' => $p->code,
                    'status' => $p->status->value,
                    'fixed_qr_active' => $p->fixed_qr_active,
                    'available_fuels' => $p->available_fuels ?? [],
                ]),
            'pompistes' => User::query()->where('organization_id', $organization->id)->where('role', Role::Pompiste)
                ->orderByDesc('id')->get(['id', 'name', 'phone', 'matricule', 'status'])
                ->map(fn (User $u): array => [
                    'id' => $u->id,
                    'name' => $u->name,
                    'phone' => $u->phone,
                    'matricule' => $u->matricule,
                    'status' => $u->status->value,
                ]),
        ]);
    }

    public function toggleOrganizationStatus(Request $request, Organization $organization, SetOrganizationStatus $setStatus): RedirectResponse
    {
        $newStatus = $organization->status === OrganizationStatus::Active
            ? OrganizationStatus::Suspended
            : OrganizationStatus::Active;

        $setStatus->handle($organization, $newStatus, $request->user()?->id);

        return back()->with('status', $newStatus === OrganizationStatus::Suspended
            ? 'Organisation suspendue — ses paiements sont bloqués.'
            : 'Organisation réactivée.');
    }

    public function audit(): Response
    {
        return Inertia::render('admin/audit', [
            'audit' => AuditLog::query()->with('actor:id,name')->orderByDesc('id')->limit(200)->get()
                ->map(fn (AuditLog $a): array => [
                    'id' => $a->id,
                    'action' => $a->action,
                    'actor' => $a->actor?->name,
                    'organization_id' => $a->organization_id,
                    'subject_type' => $a->subject_type,
                    'subject_id' => $a->subject_id,
                    'created_at' => $a->created_at->toDateTimeString(),
                ]),
        ]);
    }

    public function storeOrganization(Request $request, OnboardOrganization $onboard): RedirectResponse
    {
        $data = $request->validate([
            'type' => ['required', 'in:enterprise,station'],
            'name' => ['required', 'string', 'max:191'],
            'is_demo' => ['boolean'],
            'admin_name' => ['required', 'string', 'max:191'],
            'admin_email' => ['required', 'email', 'unique:users,email'],
            'admin_password' => ['required', 'string', 'min:8'],
        ]);

        $onboard->handle(
            type: OrganizationType::from($data['type']),
            name: $data['name'],
            admin: ['name' => $data['admin_name'], 'email' => $data['admin_email'], 'password' => $data['admin_password']],
            isDemo: (bool) ($data['is_demo'] ?? false),
            actorId: $request->user()?->id,
        );

        return back()->with('status', 'Organisation créée.');
    }

    public function creditAccount(Request $request, CreditFuelAccount $credit): RedirectResponse
    {
        $data = $request->validate([
            'organization_id' => ['required', 'integer', 'exists:organizations,id'],
            'amount' => ['required', 'integer', 'min:1'],
            'description' => ['nullable', 'string', 'max:191'],
        ]);

        $account = FuelAccount::query()->where('organization_id', $data['organization_id'])->firstOrFail();
        $credit->handle($account, Money::fromInt($data['amount']), actorId: $request->user()?->id, description: $data['description'] ?? null);

        return back()->with('status', 'Compte crédité.');
    }

    public function authorizeStation(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'enterprise_organization_id' => ['required', 'integer', 'exists:organizations,id'],
            'station_organization_id' => ['required', 'integer', 'exists:organizations,id'],
        ]);

        AuthorizedStation::query()->firstOrCreate([
            'enterprise_organization_id' => $data['enterprise_organization_id'],
            'station_organization_id' => $data['station_organization_id'],
        ], ['authorized_by' => $request->user()?->id]);

        return back()->with('status', 'Station autorisée.');
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
            'fuel_type' => $p->fuel_type->value,
            'station' => $p->station->name,
            'enterprise' => $p->enterprise->name,
            'created_at' => $p->created_at?->toDateTimeString(),
        ];
    }
}
