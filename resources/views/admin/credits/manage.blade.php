<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    💳 Gerenciar Créditos dos Clientes
                </h2>
                <p class="text-gray-600 font-semibold mt-2">Adicione ou defina créditos de vistoria para os clientes</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">

                <!-- Mensagens de sucesso/erro -->
                @if(session('success'))
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6">
                        {{ session('success') }}
                    </div>
                @endif

                @if(session('error'))
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6">
                        {{ session('error') }}
                    </div>
                @endif

                <!-- Navegação -->
                <div class="flex space-x-4 mb-6">
                    <a href="{{ route('admin.credits.manage') }}" 
                       class="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition duration-200">
                        📊 Gerenciar Créditos
                    </a>
                    <a href="{{ route('admin.credits.history') }}" 
                       class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition duration-200">
                        📋 Histórico de Créditos
                    </a>
                    <a href="{{ route('admin.dashboard') }}" 
                       class="bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400 transition duration-200">
                        ← Voltar ao Dashboard
                    </a>
                </div>

                <!-- Estatísticas rápidas -->
                <div class="grid md:grid-cols-4 gap-6 mb-8">
                    <div class="bg-blue-50 p-6 rounded-lg border border-blue-200">
                        <h3 class="text-lg font-semibold text-blue-800 mb-2">👥 Total de Clientes</h3>
                        <p class="text-3xl font-bold text-blue-600">{{ $clients->count() }}</p>
                    </div>
                    <div class="bg-green-50 p-6 rounded-lg border border-green-200">
                        <h3 class="text-lg font-semibold text-green-800 mb-2">� Total de Créditos</h3>
                        <p class="text-3xl font-bold text-green-600">{{ $clients->sum('inspection_credits') }}</p>
                    </div>
                    <div class="bg-purple-50 p-6 rounded-lg border border-purple-200">
                        <h3 class="text-lg font-semibold text-purple-800 mb-2">💰 Valor Total</h3>
                        <p class="text-2xl font-bold text-purple-600">
                            {{ \App\Models\User::formatMoney($clients->sum('inspection_credits') * config('inspection.credit_price')) }}
                        </p>
                    </div>
                    <div class="bg-orange-50 p-6 rounded-lg border border-orange-200">
                        <h3 class="text-lg font-semibold text-orange-800 mb-2">⚠️ Sem Créditos</h3>
                        <p class="text-3xl font-bold text-orange-600">{{ $clients->where('inspection_credits', 0)->count() }}</p>
                    </div>
                </div>

                <!-- Lista de Clientes -->
                <div class="bg-white rounded-lg shadow-lg overflow-hidden">
            <div class="bg-gray-50 px-6 py-4 border-b">
                <h2 class="text-xl font-semibold text-gray-800">Lista de Clientes</h2>
            </div>
            
            <div class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                            <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Créditos</th>
                            <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Valor Total</th>
                            <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        @forelse($clients as $client)
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4">
                                    <div class="flex items-center">
                                        <div class="flex-shrink-0 h-10 w-10">
                                            <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                                                <span class="text-white font-bold">{{ substr($client->name, 0, 1) }}</span>
                                            </div>
                                        </div>
                                        <div class="ml-4">
                                            <div class="text-sm font-medium text-gray-900">{{ $client->name }}</div>
                                            <div class="text-sm text-gray-500">{{ $client->email }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-2xl font-bold {{ $client->inspection_credits > 0 ? 'text-green-600' : 'text-red-600' }}">
                                        {{ $client->inspection_credits }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-lg font-semibold {{ $client->inspection_credits > 0 ? 'text-green-600' : 'text-gray-400' }}">
                                        {{ $client->getFormattedCreditsValue() }}
                                    </span>
                                    <br>
                                    <span class="text-xs text-gray-500">
                                        R$ {{ number_format(config('inspection.credit_price'), 2, ',', '.') }} cada
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    @if($client->inspection_credits > 5)
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                            ✅ Ativo
                                        </span>
                                    @elseif($client->inspection_credits > 0)
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                                            ⚠️ Baixo
                                        </span>
                                    @else
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                            ❌ Sem Créditos
                                        </span>
                                    @endif
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <div class="flex justify-center space-x-2">
                                        <!-- Botão Adicionar Créditos -->
                                        <button onclick="openAddCreditsModal('{{ $client->id }}', '{{ $client->name }}', {{ $client->inspection_credits }})"
                                                class="bg-green-500 text-white px-3 py-1 rounded text-sm hover:bg-green-600 transition duration-200">
                                            ➕ Adicionar
                                        </button>
                                        
                                        <!-- Botão Definir Créditos -->
                                        <button onclick="openSetCreditsModal('{{ $client->id }}', '{{ $client->name }}', {{ $client->inspection_credits }})"
                                                class="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 transition duration-200">
                                            ⚙️ Definir
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" class="px-6 py-8 text-center text-gray-500">
                                    <div class="text-lg">😔 Nenhum cliente encontrado</div>
                                    <p class="mt-2">Crie novos clientes no dashboard principal.</p>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
            </div>
        </div>
    </div>

<!-- Modal para Adicionar Créditos -->
<div id="addCreditsModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50">
    <div class="flex items-center justify-center min-h-screen">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
            <div class="bg-green-500 text-white px-6 py-4 rounded-t-lg">
                <h3 class="text-lg font-semibold">➕ Adicionar Créditos</h3>
            </div>
            
            <form method="POST" action="{{ route('admin.credits.add') }}">
                @csrf
                <div class="p-6">
                    <input type="hidden" id="addUserId" name="user_id">
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Cliente:</label>
                        <p id="addClientName" class="text-lg font-semibold text-gray-900"></p>
                        <p class="text-sm text-gray-500">Créditos atuais: <span id="addCurrentCredits" class="font-semibold"></span></p>
                    </div>
                    
                    <div class="mb-4">
                        <label for="addCreditsAmount" class="block text-sm font-medium text-gray-700 mb-2">Quantidade de Créditos:</label>
                        <input type="number" id="addCreditsAmount" name="credits" min="1" max="100" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500" 
                               placeholder="Ex: 10" required oninput="updateAddCreditsValue()">
                        <p class="text-xs text-gray-500 mt-1">Mínimo: 1, Máximo: 100 créditos por operação</p>
                        <div id="addCreditsValueDisplay" class="mt-2 p-2 bg-green-50 rounded-md hidden">
                            <p class="text-sm font-semibold text-green-800">
                                Valor: <span id="addCreditsValueAmount"></span>
                            </p>
                        </div>
                    </div>
                    
                    <div class="mb-6">
                        <label for="addReason" class="block text-sm font-medium text-gray-700 mb-2">Motivo (opcional):</label>
                        <input type="text" id="addReason" name="reason" maxlength="255"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500" 
                               placeholder="Ex: Pacote premium, promoção, etc.">
                    </div>
                </div>
                
                <div class="bg-gray-50 px-6 py-4 rounded-b-lg flex justify-end space-x-3">
                    <button type="button" onclick="closeAddCreditsModal()" 
                            class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-100 transition duration-200">
                        Cancelar
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600 transition duration-200">
                        ➕ Adicionar Créditos
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal para Definir Créditos -->
<div id="setCreditsModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50">
    <div class="flex items-center justify-center min-h-screen">
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full mx-4">
            <div class="bg-blue-500 text-white px-6 py-4 rounded-t-lg">
                <h3 class="text-lg font-semibold">⚙️ Definir Créditos</h3>
            </div>
            
            <form method="POST" action="{{ route('admin.credits.set') }}">
                @csrf
                <div class="p-6">
                    <input type="hidden" id="setUserId" name="user_id">
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Cliente:</label>
                        <p id="setClientName" class="text-lg font-semibold text-gray-900"></p>
                        <p class="text-sm text-gray-500">Créditos atuais: <span id="setCurrentCredits" class="font-semibold"></span></p>
                    </div>
                    
                    <div class="mb-4">
                        <label for="setCreditsAmount" class="block text-sm font-medium text-gray-700 mb-2">Novo Total de Créditos:</label>
                        <input type="number" id="setCreditsAmount" name="credits" min="0" max="1000" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" 
                               placeholder="Ex: 50" required oninput="updateSetCreditsValue()">
                        <p class="text-xs text-gray-500 mt-1">Máximo: 1000 créditos</p>
                        <div id="setCreditsValueDisplay" class="mt-2 p-2 bg-blue-50 rounded-md hidden">
                            <p class="text-sm font-semibold text-blue-800">
                                Valor Total: <span id="setCreditsValueAmount"></span>
                            </p>
                        </div>
                    </div>
                    
                    <div class="mb-6">
                        <label for="setReason" class="block text-sm font-medium text-gray-700 mb-2">Motivo (opcional):</label>
                        <input type="text" id="setReason" name="reason" maxlength="255"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" 
                               placeholder="Ex: Correção de saldo, pacote especial, etc.">
                    </div>
                </div>
                
                <div class="bg-gray-50 px-6 py-4 rounded-b-lg flex justify-end space-x-3">
                    <button type="button" onclick="closeSetCreditsModal()" 
                            class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-100 transition duration-200">
                        Cancelar
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition duration-200">
                        ⚙️ Definir Créditos
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const CREDIT_PRICE = {{ config('inspection.credit_price') }};

    function formatMoney(value) {
        return 'R$ ' + value.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function updateAddCreditsValue() {
        const credits = parseInt(document.getElementById('addCreditsAmount').value) || 0;
        const value = credits * CREDIT_PRICE;
        const display = document.getElementById('addCreditsValueDisplay');
        const amount = document.getElementById('addCreditsValueAmount');
        
        if (credits > 0) {
            amount.textContent = formatMoney(value);
            display.classList.remove('hidden');
        } else {
            display.classList.add('hidden');
        }
    }

    function updateSetCreditsValue() {
        const credits = parseInt(document.getElementById('setCreditsAmount').value) || 0;
        const value = credits * CREDIT_PRICE;
        const display = document.getElementById('setCreditsValueDisplay');
        const amount = document.getElementById('setCreditsValueAmount');
        
        if (credits >= 0) {
            amount.textContent = formatMoney(value);
            display.classList.remove('hidden');
        } else {
            display.classList.add('hidden');
        }
    }

    function openAddCreditsModal(userId, clientName, currentCredits) {
        document.getElementById('addUserId').value = userId;
        document.getElementById('addClientName').textContent = clientName;
        document.getElementById('addCurrentCredits').textContent = currentCredits;
        document.getElementById('addCreditsAmount').value = '';
        document.getElementById('addReason').value = '';
        document.getElementById('addCreditsValueDisplay').classList.add('hidden');
        document.getElementById('addCreditsModal').classList.remove('hidden');
    }

    function closeAddCreditsModal() {
        document.getElementById('addCreditsModal').classList.add('hidden');
    }

    function openSetCreditsModal(userId, clientName, currentCredits) {
        document.getElementById('setUserId').value = userId;
        document.getElementById('setClientName').textContent = clientName;
        document.getElementById('setCurrentCredits').textContent = currentCredits;
        document.getElementById('setCreditsAmount').value = currentCredits;
        document.getElementById('setReason').value = '';
        updateSetCreditsValue();
        document.getElementById('setCreditsModal').classList.remove('hidden');
    }

    function closeSetCreditsModal() {
        document.getElementById('setCreditsModal').classList.add('hidden');
    }

    // Fechar modais clicando fora
    document.getElementById('addCreditsModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeAddCreditsModal();
        }
    });

    document.getElementById('setCreditsModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeSetCreditsModal();
        }
    });
</script>
</x-app-layout>
