<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table): void {
            $table->id();
            $table->string('reference')->unique(); // code transaction public
            $table->string('short_code', 12)->unique(); // recherche pompiste
            $table->string('idempotency_key')->nullable(); // fournie à la confirmation
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete(); // entreprise payeuse
            $table->foreignId('driver_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('station_organization_id')->constrained('organizations')->cascadeOnDelete();
            $table->foreignId('pump_id')->constrained()->cascadeOnDelete();
            $table->foreignId('work_session_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('pompiste_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('via'); // dynamic | fixed
            $table->string('fuel_type');
            $table->bigInteger('amount');
            $table->string('status')->default('pending'); // pending | paid | expired | failed | refunded
            $table->string('failure_reason')->nullable();
            $table->timestamp('expires_at');
            $table->timestamp('confirmed_at')->nullable();
            $table->foreignId('ledger_entry_id')->nullable()->constrained('ledger_entries')->nullOnDelete();
            $table->timestamps();

            $table->index(['organization_id', 'status']);
            $table->index(['station_organization_id', 'status']);
            $table->index(['driver_id', 'status']);
        });

        $connection = Schema::getConnection();
        $connection->statement('ALTER TABLE payments ADD CONSTRAINT payments_amount_positive CHECK (amount > 0)');
        // Idempotence : une clé ne peut être associée qu'à un seul paiement.
        $connection->statement('CREATE UNIQUE INDEX payments_idempotency_key_unique ON payments (idempotency_key) WHERE idempotency_key IS NOT NULL');
    }

    public function down(): void
    {
        Schema::getConnection()->statement('DROP INDEX IF EXISTS payments_idempotency_key_unique');
        Schema::dropIfExists('payments');
    }
};
