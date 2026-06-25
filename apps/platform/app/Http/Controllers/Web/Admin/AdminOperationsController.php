<?php

declare(strict_types=1);

namespace App\Http\Controllers\Web\Admin;

use App\Application\Operations\RefundService;
use App\Application\Operations\SettlementService;
use App\Domain\Operations\RefundStatus;
use App\Http\Controllers\Controller;
use App\Models\Organization;
use App\Models\RefundRequest;
use App\Models\SettlementBatch;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Inertia\Inertia;
use Inertia\Response;

class AdminOperationsController extends Controller
{
    public function refunds(): Response
    {
        return Inertia::render('admin/refunds', [
            'refunds' => RefundRequest::query()
                ->with(['payment:id,reference,amount,fuel_type', 'station:id,name'])
                ->orderByDesc('id')->limit(100)->get()
                ->map(fn (RefundRequest $r): array => [
                    'id' => $r->id,
                    'status' => $r->status->value,
                    'reason' => $r->reason,
                    'payment_reference' => $r->payment->reference,
                    'amount' => $r->payment->amount,
                    'station' => $r->station->name,
                ]),
            'pendingRefunds' => RefundRequest::query()->where('status', RefundStatus::Pending)->count(),
        ]);
    }

    public function settlements(): Response
    {
        return Inertia::render('admin/settlements', [
            'batches' => SettlementBatch::query()
                ->with(['station:id,name'])
                ->orderByDesc('id')->limit(100)->get()
                ->map(fn (SettlementBatch $b): array => [
                    'id' => $b->id,
                    'reference' => $b->reference,
                    'station' => $b->station->name,
                    'gross_sales' => $b->gross_sales,
                    'refunds_deducted' => $b->refunds_deducted,
                    'net_amount' => $b->net_amount,
                    'status' => $b->status->value,
                    'paid_at' => $b->paid_at?->toDateTimeString(),
                ]),
        ]);
    }

    public function approveRefund(Request $request, RefundRequest $refund, RefundService $service): RedirectResponse
    {
        $service->approve($refund, decidedBy: $request->user()?->id);

        return back()->with('status', 'Remboursement approuvé.');
    }

    public function rejectRefund(Request $request, RefundRequest $refund, RefundService $service): RedirectResponse
    {
        $service->reject($refund, decidedBy: $request->user()?->id);

        return back()->with('status', 'Remboursement refusé.');
    }

    public function generateSettlements(Request $request, SettlementService $service): RedirectResponse
    {
        $end = Carbon::now();
        $start = $end->copy()->subWeek();

        Organization::query()->where('type', 'station')->get()->each(
            fn (Organization $station) => $service->generateForStation($station->id, $start, $end, $request->user()?->id)
        );

        return back()->with('status', 'Lots de reversement générés.');
    }

    public function markBatchPaid(Request $request, SettlementBatch $batch, SettlementService $service): RedirectResponse
    {
        $service->markPaid($batch, actorId: $request->user()?->id);

        return back()->with('status', 'Lot marqué comme payé.');
    }
}
