<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddVehicleDetailsToVehiclesTable extends Migration
{
    public function up()
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->string('vin')->unique()->after('year')->nullable();
            $table->string('engine_number')->after('vin')->nullable();
            $table->integer('odometer')->after('engine_number')->nullable();
            $table->string('color')->after('odometer')->nullable();
            $table->string('fuel_type')->after('color')->nullable();
        });
    }

    public function down()
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->dropColumn(['vin', 'engine_number', 'odometer', 'color', 'fuel_type']);
        });
    }
}