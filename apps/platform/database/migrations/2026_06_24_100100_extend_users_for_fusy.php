<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->foreignId('organization_id')->nullable()->after('id')
                ->constrained('organizations')->nullOnDelete();
            $table->string('role')->after('name'); // fusy_admin | enterprise_admin | station_admin | driver | pompiste
            $table->string('status')->default('active')->after('role'); // active | suspended
            $table->string('phone')->nullable()->after('email');
            $table->string('matricule')->nullable()->after('phone');

            // Authentification mobile par PIN.
            $table->string('pin_hash')->nullable()->after('password');
            $table->boolean('pin_is_temporary')->default(false)->after('pin_hash');
            $table->timestamp('pin_changed_at')->nullable()->after('pin_is_temporary');
            $table->unsignedSmallInteger('failed_pin_attempts')->default(0)->after('pin_changed_at');
            $table->timestamp('pin_locked_until')->nullable()->after('failed_pin_attempts');
            $table->boolean('requires_admin_reset')->default(false)->after('pin_locked_until');

            // Appareil unique.
            $table->string('device_id')->nullable()->after('requires_admin_reset');
            $table->timestamp('device_registered_at')->nullable()->after('device_id');

            $table->index('role');
            $table->index('status');
        });

        // L'email reste optionnel (utilisateurs mobiles) ; unique uniquement lorsqu'il est présent.
        Schema::table('users', function (Blueprint $table): void {
            $table->dropUnique('users_email_unique');
            $table->string('email')->nullable()->change();
            $table->string('name')->nullable()->change();
            $table->string('password')->nullable()->change();
        });

        // Index uniques partiels (PostgreSQL) : unicité par organisation.
        DB::statement('CREATE UNIQUE INDEX users_email_unique ON users (email) WHERE email IS NOT NULL');
        DB::statement('CREATE UNIQUE INDEX users_org_phone_unique ON users (organization_id, phone) WHERE phone IS NOT NULL');
        DB::statement('CREATE UNIQUE INDEX users_org_matricule_unique ON users (organization_id, matricule) WHERE matricule IS NOT NULL');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS users_org_matricule_unique');
        DB::statement('DROP INDEX IF EXISTS users_org_phone_unique');
        DB::statement('DROP INDEX IF EXISTS users_email_unique');

        Schema::table('users', function (Blueprint $table): void {
            $table->dropConstrainedForeignId('organization_id');
            $table->dropColumn([
                'role', 'status', 'phone', 'matricule',
                'pin_hash', 'pin_is_temporary', 'pin_changed_at',
                'failed_pin_attempts', 'pin_locked_until', 'requires_admin_reset',
                'device_id', 'device_registered_at',
            ]);
        });
    }
};
