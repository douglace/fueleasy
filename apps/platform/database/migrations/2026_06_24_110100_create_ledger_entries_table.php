<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ledger_entries', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('fuel_account_id')->constrained()->cascadeOnDelete();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('entry_type'); // credit | debit | refund_credit
            $table->bigInteger('amount'); // toujours positif, signe porté par entry_type
            $table->bigInteger('balance_after'); // solde du compte après cette écriture
            $table->string('reference_type')->nullable(); // morph : payment, manual_credit, refund...
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->string('description')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->json('metadata')->nullable();
            // Écriture immuable : pas de updated_at.
            $table->timestamp('created_at')->useCurrent();

            $table->index(['fuel_account_id', 'created_at']);
            $table->index(['reference_type', 'reference_id']);
        });

        $connection = Schema::getConnection();
        $connection->statement('ALTER TABLE ledger_entries ADD CONSTRAINT ledger_entries_amount_positive CHECK (amount > 0)');

        // Ledger immuable : interdire UPDATE et DELETE au niveau base (PostgreSQL).
        $connection->statement(<<<'SQL'
            CREATE OR REPLACE FUNCTION fusy_block_ledger_mutation() RETURNS trigger AS $$
            BEGIN
                RAISE EXCEPTION 'Les écritures du ledger sont immuables (% interdite).', TG_OP;
            END;
            $$ LANGUAGE plpgsql;
        SQL);
        $connection->statement(<<<'SQL'
            CREATE TRIGGER ledger_entries_immutable
            BEFORE UPDATE OR DELETE ON ledger_entries
            FOR EACH ROW EXECUTE FUNCTION fusy_block_ledger_mutation();
        SQL);
    }

    public function down(): void
    {
        $connection = Schema::getConnection();
        $connection->statement('DROP TRIGGER IF EXISTS ledger_entries_immutable ON ledger_entries');
        $connection->statement('DROP FUNCTION IF EXISTS fusy_block_ledger_mutation()');
        Schema::dropIfExists('ledger_entries');
    }
};
