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
        Schema::table('pumps', function (Blueprint $table): void {
            $table->string('code', 6)->nullable()->after('label');
        });

        // Backfill des pompes existantes. Alphabet inliné (sans O/0/I/1)
        // pour que la migration reste autonome vis-à-vis du code applicatif.
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

        foreach (DB::table('pumps')->whereNull('code')->pluck('id') as $id) {
            do {
                $code = '';
                for ($i = 0; $i < 6; $i++) {
                    $code .= $alphabet[random_int(0, 31)];
                }
            } while (DB::table('pumps')->where('code', $code)->exists());

            DB::table('pumps')->where('id', $id)->update(['code' => $code]);
        }

        Schema::table('pumps', function (Blueprint $table): void {
            $table->string('code', 6)->nullable(false)->change();
            $table->unique('code');
        });
    }

    public function down(): void
    {
        Schema::table('pumps', function (Blueprint $table): void {
            $table->dropUnique(['code']);
            $table->dropColumn('code');
        });
    }
};
