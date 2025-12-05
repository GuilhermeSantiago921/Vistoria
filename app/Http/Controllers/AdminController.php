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

    /**
     * Exibe o formulário para gerenciar créditos dos clientes.
     *
     * @return \Illuminate\View\View
     */
    public function manageCredits()
    {
        $clients = User::where('role', 'client')
                      ->orderBy('name')
                      ->get();

        return view('admin.credits.manage', compact('clients'));
    }

    /**
     * Adiciona créditos para um cliente específico.
     * 
     * PATCH 6: Melhorado tratamento de erros com try-catch e validação de role
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function addCredits(Request $request)
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'credits' => 'required|integer|min:1|max:100',
                'reason' => 'nullable|string|max:255'
            ]);

            $user = User::findOrFail($request->user_id);
            
            // Verifica se é um cliente
            if ($user->role !== 'client') {
                return back()->with('error', 'Créditos só podem ser adicionados para clientes.');
            }

            $previousCredits = $user->inspection_credits;
            $user->inspection_credits += $request->credits;
            $user->save();

            // Log da operação para auditoria
            \Log::info('Créditos adicionados pelo admin', [
                'admin_id' => auth()->id(),
                'admin_name' => auth()->user()->name,
                'client_id' => $user->id,
                'client_name' => $user->name,
                'credits_added' => $request->credits,
                'previous_credits' => $previousCredits,
                'new_credits' => $user->inspection_credits,
                'reason' => $request->reason
            ]);

            $addedValue = User::formatMoney($request->credits * config('inspection.credit_price'));
            $totalValue = $user->getFormattedCreditsValue();
            
            return back()->with('success', "✅ {$request->credits} créditos ({$addedValue}) adicionados para {$user->name}. Total atual: {$user->inspection_credits} créditos ({$totalValue}).");
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return back()->with('error', 'Usuário não encontrado.');
        } catch (\Exception $e) {
            \Log::error('Erro ao adicionar créditos', [
                'error' => $e->getMessage(),
                'admin_id' => auth()->id(),
                'request_data' => $request->all()
            ]);
            return back()->with('error', 'Erro ao adicionar créditos. Tente novamente.');
        }
    }

    /**
     * Define créditos para um cliente específico (substitui o valor atual).
     * 
     * PATCH 6: Melhorado tratamento de erros com try-catch e validação de role
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function setCredits(Request $request)
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'credits' => 'required|integer|min:0|max:1000',
                'reason' => 'nullable|string|max:255'
            ]);

            $user = User::findOrFail($request->user_id);
            
            // Verifica se é um cliente
            if ($user->role !== 'client') {
                return back()->with('error', 'Créditos só podem ser definidos para clientes.');
            }

            $previousCredits = $user->inspection_credits;
            $user->inspection_credits = $request->credits;
            $user->save();

            // Log da operação para auditoria
            \Log::info('Créditos definidos pelo admin', [
                'admin_id' => auth()->id(),
                'admin_name' => auth()->user()->name,
                'client_id' => $user->id,
                'client_name' => $user->name,
                'previous_credits' => $previousCredits,
                'new_credits' => $user->inspection_credits,
                'reason' => $request->reason
            ]);

            $totalValue = $user->getFormattedCreditsValue();
            
            return back()->with('success', "✅ Créditos de {$user->name} definidos para {$request->credits} ({$totalValue}).");
            
        } catch (\Illuminate\Validation\ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return back()->with('error', 'Usuário não encontrado.');
        } catch (\Exception $e) {
            \Log::error('Erro ao definir créditos', [
                'error' => $e->getMessage(),
                'admin_id' => auth()->id(),
                'request_data' => $request->all()
            ]);
            return back()->with('error', 'Erro ao definir créditos. Tente novamente.');
        }
    }

    /**
     * Exibe o histórico de créditos e transações dos clientes.
     *
     * @return \Illuminate\View\View
     */
    public function creditsHistory()
    {
        $clients = User::where('role', 'client')
                      ->with(['vehicles.inspections' => function($query) {
                          $query->orderBy('created_at', 'desc');
                      }])
                      ->orderBy('name')
                      ->get();

        return view('admin.credits.history', compact('clients'));
    }
}