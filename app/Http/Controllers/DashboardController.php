<?php

namespace App\Http\Controllers;

use App\Models\Inspection; // Importe o modelo Inspection
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    /**
     * Redireciona o usuário para o dashboard apropriado e carrega as vistorias.
     */
    public function index()
    {
        $user = Auth::user();

        // 1. Redirecionamento para Admin e Analista
        if ($user->role === 'admin') {
            return redirect()->route('admin.dashboard');
        } 
        
        if ($user->role === 'analyst') {
            return redirect()->route('analyst.dashboard');
        } 
        
        // 2. Lógica para o Cliente (Cliente e outros)
        // Busca todas as vistorias do cliente logado
        $inspections = Inspection::whereHas('vehicle', function ($query) {
            $query->where('user_id', Auth::id());
        })->with('vehicle', 'analyst')->latest()->get();

        // Passa as vistorias para a view
        return view('dashboard', compact('inspections'));
    }
}