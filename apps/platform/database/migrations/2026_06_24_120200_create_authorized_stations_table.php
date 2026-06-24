<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('authorized_stations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('enterprise_organization_id')->constrained('organizations')->cascadeOnDelete();
            $table->foreignId('station_organization_id')->constrained('organizations')->cascadeOnDelete();
            $table->foreignId('authorized_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['enterprise_organization_id', 'station_organization_id'], 'authorized_stations_pair_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('authorized_stations');
    }
};
