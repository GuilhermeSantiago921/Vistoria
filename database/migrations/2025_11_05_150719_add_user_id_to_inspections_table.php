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
        Schema::table('inspections', function (Blueprint $table) {
            // Adiciona a coluna 'user_id' (ID do Cliente)
            $table->foreignId('user_id')
                  ->nullable()
                  ->after('vehicle_id') // Posição (opcional, mas organiza)
                  ->constrained('users') // Cria a chave estrangeira para a tabela 'users'
                  ->onDelete('set null'); // Se o usuário for deletado, seta para NULL
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('inspections', function (Blueprint $table) {
            // Remove a chave estrangeira e a coluna
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });
    }
};