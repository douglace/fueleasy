<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web\Admin;

use App\Application\FuelAccounts\CreditFuelAccount;
use App\Application\Organizations\OnboardOrganization;
use App\Domain\Organizations\OrganizationType;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\AuthorizedStation;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Payment;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AdminDashboardController extends Controller
{
    public function index(): Response
    {
        $organizations = Organization::query()
            ->orderByDesc('id')
            ->get(['id', 'code', 'type', 'name', 'status', 'is_demo'])
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

        $recentPayments = Payment::query()
            ->with(['station:id,name', 'enterprise:id,name'])
            ->orderByDesc('id')->limit(20)->get()
            ->map($this->mapPayment(...));

        $audit = AuditLog::query()->orderByDesc('id')->limit(20)->get(['id', 'action', 'organization_id', 'created_at']);

        return Inertia::render('admin/dashboard', [
            'organizations' => $organizations,
            'recentPayments' => $recentPayments,
            'audit' => $audit,
            'stats' => [
                'enterprises' => Organization::query()->where('type', OrganizationType::Enterprise)->count(),
                'stations' => Organization::query()->where('type', OrganizationType::Station)->count(),
                'paidPayments' => Payment::query()->where('status', PaymentStatus::Paid)->count(),
            ],
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
            'amount' => $p->amount,
            'status' => $p->status->value,
            'station' => $p->station->name,
            'enterprise' => $p->enterprise->name,
            'created_at' => $p->created_at?->toDateTimeString(),
        ];
    }
}
