<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table): void {
            // Accusé de réception de l'alerte pompiste ; SMS de secours si absent.
            $table->timestamp('alert_acknowledged_at')->nullable()->after('confirmed_at');
            $table->timestamp('alert_sms_sent_at')->nullable()->after('alert_acknowledged_at');
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table): void {
            $table->dropColumn(['alert_acknowledged_at', 'alert_sms_sent_at']);
        });
    }
};
