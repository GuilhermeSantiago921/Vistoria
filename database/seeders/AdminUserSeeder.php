<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User; // Certifique-se de importar o modelo User

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Verifica se o usuário já existe para evitar duplicatas
        if (! User::where('email', 'admin@vistoria.com.br')->exists()) {
            User::create([
                'name' => 'Administrador Central',
                'email' => 'admin@vistoria.com.br',
                'password' => Hash::make('password'), // Senha: password
                'role' => 'admin',
            ]);
        }
    }
}