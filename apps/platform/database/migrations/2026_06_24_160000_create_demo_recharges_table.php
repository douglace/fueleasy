<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('demo_recharges', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete();
            $table->string('provider'); // orange_money | mtn_momo | ussd
            $table->bigInteger('amount');
            $table->string('status')->default('pending'); // pending | successful | failed
            $table->string('reference')->unique();
            $table->string('phone')->nullable();
            $table->timestamp('settled_at')->nullable();
            $table->timestamps();

            $table->index(['organization_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('demo_recharges');
    }
};
