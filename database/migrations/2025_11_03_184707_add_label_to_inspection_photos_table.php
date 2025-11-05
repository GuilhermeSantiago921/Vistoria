<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('inspection_photos', function (Blueprint $table) {
            // Este é o código que pertence a este arquivo
            $table->string('label')->nullable()->after('path');
        });
    }

    public function down(): void
    {
        Schema::table('inspection_photos', function (Blueprint $table) {
            $table->dropColumn('label');
        });
    }
};