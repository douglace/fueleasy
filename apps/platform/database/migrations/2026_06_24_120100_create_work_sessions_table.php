<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('work_sessions', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('organization_id')->constrained()->cascadeOnDelete(); // station
            $table->foreignId('user_id')->constrained()->cascadeOnDelete(); // pompiste
            $table->foreignId('pump_id')->constrained()->cascadeOnDelete();
            $table->string('status')->default('open'); // open | closed
            $table->timestamp('opened_at')->useCurrent();
            $table->timestamp('closed_at')->nullable();
            $table->timestamps();

            $table->index(['organization_id', 'status']);
        });

        // Un pompiste ne peut avoir qu'une seule session ouverte à la fois (PostgreSQL, index partiel).
        Schema::getConnection()->statement(
            "CREATE UNIQUE INDEX work_sessions_one_open_per_user ON work_sessions (user_id) WHERE status = 'open'"
        );
    }

    public function down(): void
    {
        Schema::getConnection()->statement('DROP INDEX IF EXISTS work_sessions_one_open_per_user');
        Schema::dropIfExists('work_sessions');
    }
};
