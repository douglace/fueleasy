<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fuel_accounts', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('organization_id')->unique()->constrained()->cascadeOnDelete();
            // Solde réel prépayé en FCFA (entier). Ne peut jamais devenir négatif (vérifié sous verrou).
            $table->bigInteger('balance')->default(0);
            $table->timestamps();
        });

        // Garde-fou base : le solde ne peut pas être négatif.
        Schema::getConnection()->statement(
            'ALTER TABLE fuel_accounts ADD CONSTRAINT fuel_accounts_balance_non_negative CHECK (balance >= 0)'
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('fuel_accounts');
    }
};
