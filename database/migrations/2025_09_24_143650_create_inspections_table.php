<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateInspectionsTable extends Migration
{
    public function up()
    {
        Schema::create('inspections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_id')->constrained()->onDelete('cascade'); // Relaciona com o veículo
            $table->foreignId('analyst_id')->nullable()->constrained('users')->onDelete('set null'); // Relaciona com o analista
            $table->text('notes')->nullable();
            $table->enum('status', ['pending', 'approved', 'disapproved'])->default('pending'); // Status do laudo
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('inspections');
    }
}