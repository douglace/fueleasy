<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pumps', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete(); // station
            $table->string('label'); // ex: "Pompe 1"
            $table->string('status')->default('active'); // active | inactive
            // QR fixe de secours (jeton signé), désactivable / remplaçable.
            $table->string('fixed_qr_token', 64)->nullable()->unique();
            $table->boolean('fixed_qr_active')->default(true);
            $table->json('available_fuels')->nullable(); // liste de FuelType
            $table->timestamps();

            $table->unique(['organization_id', 'label']);
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pumps');
    }
};
