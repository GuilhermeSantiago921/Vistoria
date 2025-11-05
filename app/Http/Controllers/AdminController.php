<?php

namespace App\Http\Controllers;

use App\Models\Inspection;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule; // Importado corretamente

class AdminController extends Controller
{
    /**
     * Exibe o painel principal do administrador com métricas e filtros de vistoria.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\View\View
     */
    public function index(Request $request)
    {
        $query = Inspection::with(['vehicle.user', 'analyst']);

        // 1. Filtrar por Placa (license_plate)
        if ($request->filled('plate')) {
            $plate = $request->input('plate');
            $query->whereHas('vehicle', function ($q) use ($plate) {
                $q->where('license_plate', 'like', '%' . $plate . '%');
            });
        }

        // 2. Filtrar por Data (created_at)
        if ($request->filled('date')) {
            $date = $request->input('date');
            $query->whereDate('created_at', $date);
        }

        $inspections = $query->latest()->get();
        $user_count = User::count();
        $analyst_count = User::where('role', 'analyst')->count();
        
        return view('admin.dashboard', compact('inspections', 'user_count', 'analyst_count'));
    }

    /**
     * Exibe o formulário para criar um novo usuário.
     *
     * @return \Illuminate\View\View
     */
    public function createUser()
    {
        return view('admin.users.create');
    }

    /**
     * Armazena um novo usuário (cliente ou analista).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function storeUser(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => ['required', 'string', Rule::in(['client', 'analyst', 'admin'])],
        ]);

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        return redirect()->route('admin.dashboard')->with('success', 'Novo usuário (' . $request->role . ') criado com sucesso!');
    }

    /**
     * Exibe a lista de todos os usuários, agrupados por função.
     *
     * @return \Illuminate\View\View
     */
    public function listUsers()
    {
        // Busca todos os usuários e os agrupa pela coluna 'role'
        $users = User::all()->groupBy('role');

        return view('admin.users.index', compact('users'));
    }

    /**
     * Exibe o perfil detalhado de um usuário.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\View\View
     */
    public function showUser(User $user)
    {
        // Carrega todas as vistorias e veículos do usuário, se ele for um cliente ou analista
        if ($user->role === 'client' || $user->role === 'analyst') {
            // Carrega veículos, e para cada veículo, as vistorias e fotos
            $user->load(['vehicles.inspections.photos']);
        }
        
        return view('admin.users.show', compact('user'));
    }
}