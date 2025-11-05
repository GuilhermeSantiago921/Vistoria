<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Cria a tabela 'inspection_details' já com todas as colunas
        Schema::create('inspection_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('inspection_id')->constrained()->onDelete('cascade');
            $table->string('item_name');
            $table->string('status');
            $table->string('observation')->nullable(); // <-- Coluna já incluída
            
            // $table->timestamps(); // Remova esta linha se não for usar created_at/updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inspection_details');
    }
};