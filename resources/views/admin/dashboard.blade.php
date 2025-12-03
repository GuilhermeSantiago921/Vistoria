<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    ⚙️ Painel de Administrador
                </h2>
                <p class="text-gray-600 font-semibold mt-2">Gerencie o sistema com facilidade</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                {{-- CARDS DE RESUMO --}}
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                    {{-- Card 1: Total de Usuários --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Total de Usuários</p>
                                <p class="text-4xl font-black text-blue-600 mt-2">{{ $user_count }}</p>
                                <p class="text-gray-600 text-sm mt-1">Usuários ativos</p>
                            </div>
                            <span class="text-5xl">👥</span>
                        </div>
                    </div>

                    {{-- Card 2: Total de Analistas --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Total de Analistas</p>
                                <p class="text-4xl font-black text-purple-600 mt-2">{{ $analyst_count }}</p>
                                <p class="text-gray-600 text-sm mt-1">Profissionais</p>
                            </div>
                            <span class="text-5xl">👨‍💼</span>
                        </div>
                    </div>

                    {{-- Card 3: Gerenciar Créditos --}}
                    <a href="{{ route('admin.credits.manage') }}" class="group bg-green-50 rounded-2xl shadow-md border border-green-200 p-6 hover:shadow-lg transition-all hover:bg-green-100">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-green-700 text-sm font-semibold">Gerenciar Créditos</p>
                                <p class="text-3xl font-black text-green-600 mt-2">💳</p>
                                <p class="text-green-600 text-sm mt-1 font-medium">Controle de créditos</p>
                            </div>
                            <span class="text-4xl opacity-30">→</span>
                        </div>
                    </a>

                    {{-- Card 4: Criar Usuário --}}
                    <a href="{{ route('admin.users.create') }}" class="group bg-blue-50 rounded-2xl shadow-md border border-blue-200 p-6 hover:shadow-lg transition-all hover:bg-blue-100">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-blue-700 text-sm font-semibold">Ações Rápidas</p>
                                <p class="text-3xl font-black text-blue-600 mt-2">➕</p>
                                <p class="text-blue-600 text-sm mt-1 font-medium">Criar usuário</p>
                            </div>
                            <span class="text-4xl opacity-30">→</span>
                        </div>
                    </a>
                </div>

                {{-- NAVEGAÇÃO RÁPIDA --}}
                <div class="bg-white rounded-2xl shadow-md border border-gray-100 p-6">
                    <h3 class="text-lg font-black text-gray-900 mb-4">🚀 Navegação Rápida</h3>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <a href="{{ route('admin.users.index') }}" class="flex items-center space-x-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition">
                            <span class="text-2xl">👥</span>
                            <span class="text-sm font-semibold text-gray-700">Ver Usuários</span>
                        </a>
                        <a href="{{ route('admin.credits.manage') }}" class="flex items-center space-x-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition">
                            <span class="text-2xl">💳</span>
                            <span class="text-sm font-semibold text-gray-700">Gerenciar Créditos</span>
                        </a>
                        <a href="{{ route('admin.credits.history') }}" class="flex items-center space-x-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition">
                            <span class="text-2xl">📋</span>
                            <span class="text-sm font-semibold text-gray-700">Histó. Créditos</span>
                        </a>
                        <a href="{{ route('analyst.dashboard') }}" class="flex items-center space-x-3 p-3 rounded-lg border border-gray-200 hover:bg-gray-50 transition">
                            <span class="text-2xl">🔍</span>
                            <span class="text-sm font-semibold text-gray-700">Painel Analista</span>
                        </a>
                    </div>
                </div>

                {{-- FILTROS AVANÇADOS --}}
                <div class="bg-white rounded-2xl shadow-md border border-gray-100 p-6">
                    <h3 class="text-lg font-black text-gray-900 mb-4">🔍 Filtrar Resultados</h3>
                    <form method="GET" action="{{ route('admin.dashboard') }}" class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        
                        <div>
                            <label for="plate" class="block text-xs font-bold text-gray-700 mb-2 uppercase tracking-wider">Placa</label>
                            <input id="plate" name="plate" type="text" value="{{ request('plate') }}" placeholder="ABC1234" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm" />
                        </div>
                        
                        <div>
                            <label for="date" class="block text-xs font-bold text-gray-700 mb-2 uppercase tracking-wider">Data</label>
                            <input id="date" name="date" type="date" value="{{ request('date') }}" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition text-sm" />
                        </div>

                        <div class="flex items-end gap-2">
                            <button type="submit" class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-bold text-sm">
                                Buscar
                            </button>
                            @if(request()->filled('plate') || request()->filled('date'))
                                <a href="{{ route('admin.dashboard') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition font-bold text-sm">
                                    Limpar
                                </a>
                            @endif
                        </div>
                    </form>
                </div>

                {{-- TABELA DE RESULTADOS --}}
                <div class="bg-white rounded-2xl shadow-md border border-gray-100 overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-100 bg-white">
                        <h3 class="text-lg font-black text-gray-900">📋 Laudos</h3>
                    </div>
                    
                    <div class="p-6">
                        @if($inspections->isEmpty())
                            <div class="text-center py-12">
                                <p class="text-5xl mb-3 opacity-50">📭</p>
                                <p class="text-gray-600 font-semibold">Nenhum laudo encontrado</p>
                            </div>
                        @else
                            <div class="overflow-x-auto">
                                <table class="w-full text-sm">
                                    <thead>
                                        <tr class="border-b border-gray-200">
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">ID</th>
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">Placa</th>
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">Cliente</th>
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">Status</th>
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">Data</th>
                                            <th class="px-4 py-3 text-left font-bold text-gray-700 text-xs">Ação</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200">
                                        @foreach($inspections as $inspection)
                                            <tr class="hover:bg-gray-50 transition">
                                                <td class="px-4 py-3">
                                                    <span class="text-xs font-bold text-gray-500">#{{ $inspection->id }}</span>
                                                </td>
                                                <td class="px-4 py-3">
                                                    <span class="font-bold text-gray-900">{{ $inspection->vehicle->license_plate }}</span>
                                                </td>
                                                <td class="px-4 py-3 text-gray-700 text-sm">
                                                    {{ $inspection->vehicle->user->name }}
                                                </td>
                                                <td class="px-4 py-3">
                                                    @if($inspection->status === 'approved')
                                                        <span class="px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-bold">✅ Aprovado</span>
                                                    @elseif($inspection->status === 'disapproved')
                                                        <span class="px-2 py-1 bg-red-100 text-red-700 rounded text-xs font-bold">❌ Reprovado</span>
                                                    @else
                                                        <span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded text-xs font-bold">⏳ Pendente</span>
                                                    @endif
                                                </td>
                                                <td class="px-4 py-3 text-gray-700 text-sm">
                                                    {{ $inspection->created_at->format('d/m/Y') }}
                                                </td>
                                                <td class="px-4 py-3">
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="px-3 py-1 bg-blue-600 text-white rounded text-xs font-bold hover:bg-blue-700 transition inline-block">
                                                        Ver
                                                    </a>
                                                </td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>