<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web;

use App\Application\Operations\SettlementService;
use App\Domain\Identity\Role;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Web\Admin\AdminDashboardController;
use App\Http\Controllers\Web\Enterprise\EnterpriseDashboardController;
use App\Http\Controllers\Web\Station\StationDashboardController;
use Illuminate\Http\Request;
use Inertia\Response;

/**
 * Point d'entrée /dashboard : rend le tableau de bord correspondant au rôle.
 */
class DashboardController extends Controller
{
    public function index(Request $request): Response
    {
        $user = $request->user();

        return match ($user?->role) {
            Role::FusyAdmin => app(AdminDashboardController::class)->index(),
            Role::EnterpriseAdmin => app(EnterpriseDashboardController::class)->index($request),
            Role::StationAdmin => app(StationDashboardController::class)->index($request, app(SettlementService::class)),
            default => app(AdminDashboardController::class)->index(),
        };
    }
}
