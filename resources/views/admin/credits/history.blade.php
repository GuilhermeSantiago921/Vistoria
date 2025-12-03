<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    📋 Histórico de Créditos e Vistorias
                </h2>
                <p class="text-gray-600 font-semibold mt-2">Acompanhe o uso de créditos e vistorias realizadas pelos clientes</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">

                <!-- Navegação -->
                <div class="flex space-x-4 mb-6">
                    <a href="{{ route('admin.credits.manage') }}" 
                       class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600 transition duration-200">
                        📊 Gerenciar Créditos
                    </a>
                    <a href="{{ route('admin.credits.history') }}" 
                       class="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition duration-200">
                        📋 Histórico de Créditos
                    </a>
                    <a href="{{ route('admin.dashboard') }}" 
                       class="bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400 transition duration-200">
                        ← Voltar ao Dashboard
                    </a>
                </div>

                <!-- Histórico por Cliente -->
                <div class="space-y-6">
            @forelse($clients as $client)
                <div class="bg-white rounded-lg shadow-lg overflow-hidden">
                    <!-- Header do Cliente -->
                    <div class="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-4">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center space-x-4">
                                <div class="h-12 w-12 rounded-full bg-white bg-opacity-20 flex items-center justify-center">
                                    <span class="text-white font-bold text-lg">{{ substr($client->name, 0, 1) }}</span>
                                </div>
                                <div>
                                    <h3 class="text-xl font-semibold">{{ $client->name }}</h3>
                                    <p class="text-blue-100">{{ $client->email }}</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <div class="text-2xl font-bold">{{ $client->inspection_credits }}</div>
                                <div class="text-blue-100 text-sm">créditos restantes</div>
                                <div class="text-blue-100 text-lg font-semibold mt-1">
                                    {{ $client->getFormattedCreditsValue() }}
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Estatísticas do Cliente -->
                    <div class="bg-gray-50 px-6 py-4 border-b">
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <div class="text-center">
                                <div class="text-2xl font-bold text-gray-800">{{ $client->vehicles->count() }}</div>
                                <div class="text-sm text-gray-600">Veículos</div>
                            </div>
                            <div class="text-center">
                                <div class="text-2xl font-bold text-blue-600">{{ $client->vehicles->flatMap->inspections->count() }}</div>
                                <div class="text-sm text-gray-600">Total Vistorias</div>
                            </div>
                            <div class="text-center">
                                <div class="text-2xl font-bold text-green-600">{{ $client->vehicles->flatMap->inspections->where('status', 'approved')->count() }}</div>
                                <div class="text-sm text-gray-600">Aprovadas</div>
                            </div>
                            <div class="text-center">
                                <div class="text-2xl font-bold text-red-600">{{ $client->vehicles->flatMap->inspections->where('status', 'disapproved')->count() }}</div>
                                <div class="text-sm text-gray-600">Reprovadas</div>
                            </div>
                        </div>
                    </div>

                    <!-- Histórico de Vistorias -->
                    @php
                        $inspections = $client->vehicles->flatMap->inspections->sortByDesc('created_at');
                    @endphp

                    @if($inspections->count() > 0)
                        <div class="p-6">
                            <h4 class="text-lg font-semibold text-gray-800 mb-4">📊 Últimas Vistorias</h4>
                            <div class="overflow-x-auto">
                                <table class="w-full text-sm">
                                    <thead class="bg-gray-100">
                                        <tr>
                                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Data</th>
                                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Veículo</th>
                                            <th class="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase">Status</th>
                                            <th class="px-4 py-2 text-center text-xs font-medium text-gray-500 uppercase">Analista</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200">
                                        @foreach($inspections->take(10) as $inspection)
                                            <tr class="hover:bg-gray-50">
                                                <td class="px-4 py-3">
                                                    <div class="text-sm font-medium text-gray-900">
                                                        {{ $inspection->created_at->format('d/m/Y') }}
                                                    </div>
                                                    <div class="text-xs text-gray-500">
                                                        {{ $inspection->created_at->format('H:i') }}
                                                    </div>
                                                </td>
                                                <td class="px-4 py-3">
                                                    <div class="text-sm font-medium text-gray-900">
                                                        {{ $inspection->vehicle->license_plate }}
                                                    </div>
                                                    <div class="text-xs text-gray-500">
                                                        {{ $inspection->vehicle->brand }} {{ $inspection->vehicle->model }}
                                                    </div>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    @switch($inspection->status)
                                                        @case('pending')
                                                            <span class="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                                                                ⏳ Pendente
                                                            </span>
                                                            @break
                                                        @case('approved')
                                                            <span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                                                                ✅ Aprovada
                                                            </span>
                                                            @break
                                                        @case('disapproved')
                                                            <span class="px-2 py-1 text-xs rounded-full bg-red-100 text-red-800">
                                                                ❌ Reprovada
                                                            </span>
                                                            @break
                                                        @default
                                                            <span class="px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800">
                                                                {{ ucfirst($inspection->status) }}
                                                            </span>
                                                    @endswitch
                                                </td>
                                                <td class="px-4 py-3 text-center text-sm text-gray-900">
                                                    {{ $inspection->analyst->name ?? '-' }}
                                                </td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                            
                            @if($inspections->count() > 10)
                                <div class="mt-4 text-center">
                                    <p class="text-sm text-gray-500">
                                        Mostrando 10 de {{ $inspections->count() }} vistorias
                                    </p>
                                </div>
                            @endif
                        </div>
                    @else
                        <div class="p-6">
                            <div class="text-center text-gray-500">
                                <div class="text-4xl mb-2">📝</div>
                                <p class="text-lg">Nenhuma vistoria realizada ainda</p>
                                <p class="text-sm">Este cliente ainda não enviou nenhuma vistoria.</p>
                            </div>
                        </div>
                    @endif
                </div>
            @empty
                <div class="bg-white rounded-lg shadow-lg p-12 text-center">
                    <div class="text-6xl mb-4">😔</div>
                    <h3 class="text-xl font-semibold text-gray-800 mb-2">Nenhum cliente encontrado</h3>
                    <p class="text-gray-600">Não há clientes cadastrados no sistema ainda.</p>
                </div>
            @endforelse
        </div>

        <!-- Resumo Geral -->
        @if($clients->count() > 0)
            <div class="mt-8 bg-white rounded-lg shadow-lg p-6">
                <h3 class="text-xl font-semibold text-gray-800 mb-4">📈 Resumo Geral do Sistema</h3>
                <div class="grid grid-cols-2 md:grid-cols-6 gap-4">
                    <div class="text-center p-4 bg-blue-50 rounded-lg">
                        <div class="text-2xl font-bold text-blue-600">{{ $clients->count() }}</div>
                        <div class="text-sm text-blue-800">Clientes Ativos</div>
                    </div>
                    <div class="text-center p-4 bg-green-50 rounded-lg">
                        <div class="text-2xl font-bold text-green-600">{{ $clients->sum('inspection_credits') }}</div>
                        <div class="text-sm text-green-800">Total Créditos</div>
                    </div>
                    <div class="text-center p-4 bg-emerald-50 rounded-lg">
                        <div class="text-lg font-bold text-emerald-600">
                            {{ \App\Models\User::formatMoney($clients->sum('inspection_credits') * config('inspection.credit_price')) }}
                        </div>
                        <div class="text-sm text-emerald-800">Valor Total</div>
                    </div>
                    <div class="text-center p-4 bg-purple-50 rounded-lg">
                        <div class="text-2xl font-bold text-purple-600">{{ $clients->flatMap->vehicles->count() }}</div>
                        <div class="text-sm text-purple-800">Veículos Cadastrados</div>
                    </div>
                    <div class="text-center p-4 bg-indigo-50 rounded-lg">
                        <div class="text-2xl font-bold text-indigo-600">{{ $clients->flatMap->vehicles->flatMap->inspections->count() }}</div>
                        <div class="text-sm text-indigo-800">Total Vistorias</div>
                    </div>
                    <div class="text-center p-4 bg-yellow-50 rounded-lg">
                        <div class="text-2xl font-bold text-yellow-600">{{ $clients->flatMap->vehicles->flatMap->inspections->where('status', 'pending')->count() }}</div>
                        <div class="text-sm text-yellow-800">Pendentes</div>
                    </div>
                </div>
            </div>
            @endif
            </div>
        </div>
    </div>
</x-app-layout>
