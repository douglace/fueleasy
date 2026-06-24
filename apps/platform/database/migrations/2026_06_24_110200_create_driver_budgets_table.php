<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('driver_budgets', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete(); // chauffeur
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('mode'); // manual | weekly | monthly
            $table->bigInteger('amount'); // enveloppe allouée à chaque (re)set
            $table->bigInteger('balance'); // reste disponible
            $table->timestamp('last_reset_at')->nullable();
            $table->timestamp('next_reset_at')->nullable();
            $table->timestamps();

            $table->index('next_reset_at');
        });

        $connection = Schema::getConnection();
        $connection->statement('ALTER TABLE driver_budgets ADD CONSTRAINT driver_budgets_amount_non_negative CHECK (amount >= 0)');
        $connection->statement('ALTER TABLE driver_budgets ADD CONSTRAINT driver_budgets_balance_non_negative CHECK (balance >= 0)');
    }

    public function down(): void
    {
        Schema::dropIfExists('driver_budgets');
    }
};
