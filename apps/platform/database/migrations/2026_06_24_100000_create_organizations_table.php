<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organizations', function (Blueprint $table): void {
            $table->id();
            $table->string('code', 6)->unique();
            $table->string('type'); // enterprise | station
            $table->string('name');
            $table->string('status')->default('active'); // active | suspended
            $table->boolean('is_demo')->default(false);
            $table->string('contact_email')->nullable();
            $table->string('contact_phone')->nullable();
            $table->string('address')->nullable();
            $table->json('settings')->nullable();
            $table->timestamps();

            $table->index('type');
            $table->index('status');
            $table->index('is_demo');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organizations');
    }
};
