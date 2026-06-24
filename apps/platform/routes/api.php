<?php

declare(strict_types=1);

use App\Http\Controllers\Api\Mobile\AuthController;
use App\Http\Controllers\Api\Mobile\MeController;
use App\Http\Controllers\Api\Mobile\PaymentController;
use App\Http\Controllers\Api\Mobile\WorkSessionController;
use Illuminate\Support\Facades\Route;

Route::get('/health', static fn (): array => [
    'status' => 'ok',
    'app' => 'Fusy',
]);

Route::prefix('v1/mobile')->group(function (): void {
    // Authentification (publique).
    Route::post('auth/activate', [AuthController::class, 'activate']);
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::post('auth/device/request', [AuthController::class, 'requestDeviceChange']);
    Route::post('auth/device/confirm', [AuthController::class, 'confirmDeviceChange']);

    // Endpoints authentifiés par jeton d'appareil.
    Route::middleware('auth.mobile')->group(function (): void {
        Route::get('me', [MeController::class, 'show']);
        Route::post('budget/reveal', [MeController::class, 'revealBudget']);

        // Chauffeur — paiement.
        Route::post('scan', [PaymentController::class, 'scan']);
        Route::get('payments', [PaymentController::class, 'history']);
        Route::post('payments', [PaymentController::class, 'store']);
        Route::get('payments/by-key', [PaymentController::class, 'byIdempotencyKey']);
        Route::get('payments/{payment}', [PaymentController::class, 'show']);
        Route::get('payments/{payment}/receipt', [PaymentController::class, 'receipt']);
        Route::post('payments/{payment}/confirm', [PaymentController::class, 'confirm']);

        // Pompiste — sessions et alertes.
        Route::post('work-sessions', [WorkSessionController::class, 'open']);
        Route::post('work-sessions/{workSession}/close', [WorkSessionController::class, 'close']);
        Route::get('work-sessions/current/qr', [WorkSessionController::class, 'currentQr']);
        Route::get('station/payments/today', [WorkSessionController::class, 'todaysPayments']);
        Route::get('station/payments/search', [WorkSessionController::class, 'search']);
        Route::post('station/payments/{payment}/ack', [WorkSessionController::class, 'acknowledge']);
    });
});
