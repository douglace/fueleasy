<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Lots hebdomadaires de reversement station.
        Schema::create('settlement_batches', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('station_organization_id')->constrained('organizations')->cascadeOnDelete();
            $table->string('reference')->unique();
            $table->date('period_start');
            $table->date('period_end');
            $table->bigInteger('gross_sales')->default(0);
            $table->bigInteger('refunds_deducted')->default(0);
            $table->bigInteger('net_amount')->default(0);
            $table->string('status')->default('open'); // open | paid
            $table->timestamp('paid_at')->nullable();
            $table->foreignId('marked_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['station_organization_id', 'status']);
        });

        // Demandes de remboursement total.
        Schema::create('refund_requests', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('payment_id')->constrained()->cascadeOnDelete();
            $table->foreignId('station_organization_id')->constrained('organizations')->cascadeOnDelete();
            $table->foreignId('requested_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('status')->default('pending'); // pending | approved | rejected
            $table->string('reason')->nullable();
            $table->foreignId('decided_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('decided_at')->nullable();
            $table->foreignId('settled_batch_id')->nullable()->constrained('settlement_batches')->nullOnDelete();
            $table->timestamps();

            $table->index(['station_organization_id', 'status']);
            // Un seul remboursement (total) par paiement.
            $table->unique('payment_id');
        });

        Schema::table('payments', function (Blueprint $table): void {
            $table->foreignId('settled_batch_id')->nullable()->after('ledger_entry_id')
                ->constrained('settlement_batches')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table): void {
            $table->dropConstrainedForeignId('settled_batch_id');
        });
        Schema::dropIfExists('refund_requests');
        Schema::dropIfExists('settlement_batches');
    }
};
