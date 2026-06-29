<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web\Enterprise;

use App\Application\DriverBudgets\ResetDriverBudget;
use App\Application\DriverBudgets\SetDriverBudget;
use App\Application\Identity\MobileAccountAdmin;
use App\Application\Operations\TransactionExporter;
use App\Domain\DriverBudgets\BudgetMode;
use App\Domain\Identity\Role;
use App\Domain\Identity\UserStatus;
use App\Domain\Payments\PaymentStatus;
use App\Domain\Shared\Money;
use App\Http\Controllers\Controller;
use App\Models\AuthorizedStation;
use App\Models\DriverBudget;
use App\Models\FuelAccount;
use App\Models\Organization;
use App\Models\Payment;
use App\Models\User;
use App\Support\DashboardCharts;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;
use Symfony\Component\HttpFoundation\Response as SymfonyResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;

class EnterpriseDashboardController extends Controller
{
    public function index(Request $request): Response
    {
        $org = $this->organizationId($request);
        $paid = Payment::query()->where('organization_id', $org)->where('status', PaymentStatus::Paid);

        return Inertia::render('enterprise/dashboard', [
            'balance' => (int) FuelAccount::query()->where('organization_id', $org)->value('balance'),
            'stats' => [
                'drivers' => User::query()->where('organization_id', $org)->where('role', Role::Driver)->count(),
                'authorizedStations' => AuthorizedStation::query()->where('enterprise_organization_id', $org)->count(),
                'paidPayments' => Payment::query()->where('organization_id', $org)->where('status', PaymentStatus::Paid)->count(),
                'spentTotal' => (int) Payment::query()->where('organization_id', $org)->where('status', PaymentStatus::Paid)->sum('amount'),
            ],
            'charts' => [
                'volume' => DashboardCharts::volume($paid),
                'fuelMix' => DashboardCharts::fuelMix($paid),
            ],
            'recentTransactions' => Payment::query()
                ->where('organization_id', $org)->with('station:id,name')
                ->orderByDesc('id')->limit(8)->get()->map($this->mapPayment(...)),
        ]);
    }

    public function drivers(Request $request): Response
    {
        $org = $this->organizationId($request);

        return Inertia::render('enterprise/drivers', [
            'drivers' => User::query()
                ->where('organization_id', $org)->where('role', Role::Driver)
                ->orderByDesc('id')->get(['id', 'name', 'phone', 'matricule', 'status', 'pin_is_temporary'])
                ->map(function (User $u): array {
                    $budget = DriverBudget::query()->where('user_id', $u->id)->first();

                    return [
                        'id' => $u->id,
                        'name' => $u->name,
                        'phone' => $u->phone,
                        'matricule' => $u->matricule,
                        'status' => $u->status->value,
                        'pin_is_temporary' => $u->pin_is_temporary,
                        'budget' => $budget === null ? null : [
                            'mode' => $budget->mode->value,
                            'amount' => $budget->amount,
                            'balance' => $budget->balance,
                        ],
                    ];
                }),
        ]);
    }

    public function stations(Request $request): Response
    {
        $org = $this->organizationId($request);

        return Inertia::render('enterprise/stations', [
            'stations' => AuthorizedStation::query()
                ->where('enterprise_organization_id', $org)->with('station:id,name,code,status')
                ->get()->map(fn (AuthorizedStation $a): array => [
                    'id' => $a->station->id,
                    'name' => $a->station->name,
                    'code' => $a->station->code,
                    'status' => $a->station->status->value,
                ]),
        ]);
    }

    public function transactions(Request $request): Response
    {
        $org = $this->organizationId($request);

        return Inertia::render('enterprise/transactions', [
            'transactions' => Payment::query()
                ->where('organization_id', $org)->with('station:id,name')
                ->orderByDesc('id')->limit(200)->get()->map($this->mapPayment(...)),
        ]);
    }

    public function storeDriver(Request $request, MobileAccountAdmin $accounts): RedirectResponse
    {
        $org = $this->organization($request);
        $data = $request->validate([
            'name' => ['required', 'string', 'max:191'],
            'phone' => ['nullable', 'string', 'max:32'],
            'matricule' => ['nullable', 'string', 'max:64'],
        ]);

        $result = $accounts->create($org, Role::Driver, $data['name'], $data['phone'] ?? null, $data['matricule'] ?? null, $request->user()?->id);

        return back()->with('status', 'Chauffeur créé. PIN temporaire : '.$result['temporary_pin']);
    }

    public function resetDriverPin(Request $request, User $driver, MobileAccountAdmin $accounts): RedirectResponse
    {
        $this->assertOwnership($request, $driver);
        $pin = $accounts->resetPin($driver, $request->user()?->id);

        return back()->with('status', 'Nouveau PIN temporaire : '.$pin);
    }

    public function suspendDriver(Request $request, User $driver, MobileAccountAdmin $accounts): RedirectResponse
    {
        $this->assertOwnership($request, $driver);
        $newStatus = $driver->status === UserStatus::Active ? UserStatus::Suspended : UserStatus::Active;
        $accounts->setStatus($driver, $newStatus, $request->user()?->id);

        return back()->with('status', 'Statut du chauffeur mis à jour.');
    }

    public function setBudget(Request $request, User $driver, SetDriverBudget $setBudget): RedirectResponse
    {
        $this->assertOwnership($request, $driver);
        $data = $request->validate([
            'mode' => ['required', 'in:manual,weekly,monthly'],
            'amount' => ['required', 'integer', 'min:0'],
        ]);

        $setBudget->handle($driver, BudgetMode::from($data['mode']), Money::fromInt($data['amount']), $request->user()?->id);

        return back()->with('status', 'Budget mis à jour.');
    }

    public function resetBudget(Request $request, User $driver, ResetDriverBudget $resetBudget): RedirectResponse
    {
        $this->assertOwnership($request, $driver);
        $budget = DriverBudget::query()->where('user_id', $driver->id)->firstOrFail();
        $resetBudget->handle($budget, $request->user()?->id);

        return back()->with('status', 'Budget réinitialisé.');
    }

    public function exportTransactions(Request $request, TransactionExporter $exporter): StreamedResponse
    {
        $org = $this->organizationId($request);
        $payments = Payment::query()->where('organization_id', $org)->with(['station', 'enterprise'])->orderByDesc('id')->get();
        $csv = $exporter->csv($payments);

        return response()->streamDownload(fn () => print ($csv), 'transactions-fusy.csv', ['Content-Type' => 'text/csv']);
    }

    private function organization(Request $request): Organization
    {
        $user = $request->user();
        abort_if($user?->organization === null, SymfonyResponse::HTTP_FORBIDDEN);

        return $user->organization;
    }

    private function organizationId(Request $request): int
    {
        return (int) $request->user()?->organization_id;
    }

    private function assertOwnership(Request $request, User $driver): void
    {
        abort_unless($driver->organization_id === $request->user()?->organization_id, SymfonyResponse::HTTP_FORBIDDEN);
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
            'fuel_type' => $p->fuel_type->value,
            'station' => $p->station->name,
            'created_at' => $p->created_at?->toDateTimeString(),
        ];
    }
}
