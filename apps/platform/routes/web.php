<?php

use App\Http\Controllers\Web\Admin\AdminDashboardController;
use App\Http\Controllers\Web\Admin\AdminOperationsController;
use App\Http\Controllers\Web\DashboardController;
use App\Http\Controllers\Web\Enterprise\EnterpriseDashboardController;
use App\Http\Controllers\Web\Station\StationDashboardController;
use Illuminate\Support\Facades\Route;

Route::inertia('/', 'welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function (): void {
    Route::get('dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Admin Fusy
    Route::middleware('role:fusy_admin')->prefix('admin')->name('admin.')->group(function (): void {
        Route::get('/', [AdminDashboardController::class, 'index'])->name('dashboard');
        Route::get('organizations', [AdminDashboardController::class, 'organizations'])->name('organizations');
        Route::get('transactions', [AdminDashboardController::class, 'transactions'])->name('transactions');
        Route::get('audit', [AdminDashboardController::class, 'audit'])->name('audit');
        Route::get('refunds', [AdminOperationsController::class, 'refunds'])->name('refunds');
        Route::get('settlements', [AdminOperationsController::class, 'settlements'])->name('settlements');

        Route::post('organizations', [AdminDashboardController::class, 'storeOrganization'])->name('organizations.store');
        Route::post('fuel-credits', [AdminDashboardController::class, 'creditAccount'])->name('fuel-credits.store');
        Route::post('authorized-stations', [AdminDashboardController::class, 'authorizeStation'])->name('authorized-stations.store');
        Route::post('refunds/{refund}/approve', [AdminOperationsController::class, 'approveRefund'])->name('refunds.approve');
        Route::post('refunds/{refund}/reject', [AdminOperationsController::class, 'rejectRefund'])->name('refunds.reject');
        Route::post('settlements/generate', [AdminOperationsController::class, 'generateSettlements'])->name('settlements.generate');
        Route::post('settlements/{batch}/paid', [AdminOperationsController::class, 'markBatchPaid'])->name('settlements.paid');
    });

    // Admin entreprise
    Route::middleware('role:enterprise_admin')->prefix('enterprise')->name('enterprise.')->group(function (): void {
        Route::get('/', [EnterpriseDashboardController::class, 'index'])->name('dashboard');
        Route::get('drivers', [EnterpriseDashboardController::class, 'drivers'])->name('drivers');
        Route::get('stations', [EnterpriseDashboardController::class, 'stations'])->name('stations');
        Route::get('transactions', [EnterpriseDashboardController::class, 'transactions'])->name('transactions');

        Route::post('drivers', [EnterpriseDashboardController::class, 'storeDriver'])->name('drivers.store');
        Route::post('drivers/{driver}/reset-pin', [EnterpriseDashboardController::class, 'resetDriverPin'])->name('drivers.reset-pin');
        Route::post('drivers/{driver}/suspend', [EnterpriseDashboardController::class, 'suspendDriver'])->name('drivers.suspend');
        Route::post('drivers/{driver}/budget', [EnterpriseDashboardController::class, 'setBudget'])->name('drivers.budget');
        Route::post('drivers/{driver}/budget/reset', [EnterpriseDashboardController::class, 'resetBudget'])->name('drivers.budget.reset');
        Route::get('export/transactions', [EnterpriseDashboardController::class, 'exportTransactions'])->name('export.transactions');
    });

    // Admin station
    Route::middleware('role:station_admin')->prefix('station')->name('station.')->group(function (): void {
        Route::get('/', [StationDashboardController::class, 'index'])->name('dashboard');
        Route::get('pumps', [StationDashboardController::class, 'pumps'])->name('pumps');
        Route::get('pompistes', [StationDashboardController::class, 'pompistes'])->name('pompistes');
        Route::get('payments', [StationDashboardController::class, 'payments'])->name('payments');
        Route::get('settlements', [StationDashboardController::class, 'settlements'])->name('settlements');

        Route::post('pumps', [StationDashboardController::class, 'storePump'])->name('pumps.store');
        Route::post('pumps/{pump}/toggle-qr', [StationDashboardController::class, 'togglePumpQr'])->name('pumps.toggle-qr');
        Route::post('pompistes', [StationDashboardController::class, 'storePompiste'])->name('pompistes.store');
        Route::post('pompistes/{pompiste}/reset-pin', [StationDashboardController::class, 'resetPompistePin'])->name('pompistes.reset-pin');
        Route::post('pompistes/{pompiste}/suspend', [StationDashboardController::class, 'suspendPompiste'])->name('pompistes.suspend');
        Route::post('payments/{payment}/refund', [StationDashboardController::class, 'requestRefund'])->name('payments.refund');
    });
});

require __DIR__.'/settings.php';
