<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    ⚙️ Painel de Administrador
                </h2>
                <p class="text-gray-600 font-bold mt-2">Gerencie usuários, inspetores e inspeções</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-gray-50 min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                {{-- CARDS DE RESUMO --}}
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {{-- Card 1: Total de Usuários --}}
                    <div class="group bg-white rounded-3xl shadow-lg border border-gray-200 p-8 hover:shadow-2xl transition-all hover:-translate-y-1">
                        <div class="flex items-center justify-between mb-4">
                            <div>
                                <p class="text-sm text-gray-500 font-bold uppercase tracking-wider">Total de Usuários</p>
                                <p class="text-5xl font-black text-blue-600 mt-3">{{ $user_count }}</p>
                            </div>
                            <span class="text-6xl group-hover:scale-110 transition">👥</span>
                        </div>
                        <p class="text-gray-600 font-semibold">Usuários registrados no sistema</p>
                    </div>

                    {{-- Card 2: Total de Analistas --}}
                    <div class="group bg-white rounded-3xl shadow-lg border border-gray-200 p-8 hover:shadow-2xl transition-all hover:-translate-y-1">
                        <div class="flex items-center justify-between mb-4">
                            <div>
                                <p class="text-sm text-gray-500 font-bold uppercase tracking-wider">Analistas</p>
                                <p class="text-5xl font-black text-purple-600 mt-3">{{ $analyst_count }}</p>
                            </div>
                            <span class="text-6xl group-hover:scale-110 transition">👨‍💼</span>
                        </div>
                        <p class="text-gray-600 font-semibold">Profissionais registrados</p>
                    </div>

                    {{-- Card 3: Criar Novo Usuário --}}
                    <a href="{{ route('admin.users.create') }}" class="group bg-white rounded-3xl shadow-lg border border-gray-200 p-8 hover:shadow-2xl transition-all hover:-translate-y-1">
                        <div class="flex items-center justify-between mb-4">
                            <div>
                                <p class="text-sm text-gray-500 font-bold uppercase tracking-wider">Nova Ação</p>
                                <p class="text-5xl font-black text-green-600 mt-3">Adicionar</p>
                            </div>
                            <span class="text-6xl group-hover:scale-110 transition">➕</span>
                        </div>
                        <p class="text-gray-600 font-semibold">Criar novo usuário no sistema</p>
                    </a>
                </div>

                {{-- FILTROS AVANÇADOS --}}
                <div class="bg-white rounded-3xl shadow-lg border border-gray-200 p-8">
                    <h3 class="text-2xl font-black text-gray-900 mb-6 flex items-center gap-3">
                        🔍 Filtros Avançados
                    </h3>
                    <form method="GET" action="{{ route('admin.dashboard') }}" class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        
                        <div>
                            <label for="plate" class="block text-sm font-bold text-gray-700 mb-3 uppercase tracking-wider">Buscar por Placa</label>
                            <input id="plate" name="plate" type="text" value="{{ request('plate') }}" placeholder="Ex: ABC1234" class="w-full px-5 py-3 rounded-2xl border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition font-semibold text-gray-900" />
                        </div>
                        
                        <div>
                            <label for="date" class="block text-sm font-bold text-gray-700 mb-3 uppercase tracking-wider">Filtrar por Data</label>
                            <input id="date" name="date" type="date" value="{{ request('date') }}" class="w-full px-5 py-3 rounded-2xl border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition font-semibold text-gray-900" />
                        </div>

                        <div class="flex items-end gap-3">
                            <button type="submit" class="flex-1 px-6 py-3 bg-blue-600 text-white rounded-2xl hover:bg-blue-700 transition font-bold text-lg shadow-md hover:shadow-lg">
                                🔎 Buscar
                            </button>
                            @if(request()->filled('plate') || request()->filled('date'))
                                <a href="{{ route('admin.dashboard') }}" class="px-6 py-3 bg-gray-200 text-gray-700 rounded-2xl hover:bg-gray-300 transition font-bold text-lg shadow-md hover:shadow-lg">
                                    ✕ Limpar
                                </a>
                            @endif
                        </div>
                    </form>
                </div>

                {{-- TABELA DE RESULTADOS --}}
                <div class="bg-white rounded-3xl shadow-lg border border-gray-200 overflow-hidden">
                    <div class="px-8 py-6 border-b border-gray-200 bg-gray-50">
                        <h3 class="text-2xl font-black text-gray-900">📋 Resultados da Busca</h3>
                        <p class="text-gray-600 font-semibold mt-2">Todos os laudos no sistema</p>
                    </div>
                    
                    <div class="p-8">
                        @if($inspections->isEmpty())
                            <div class="text-center py-16">
                                <p class="text-7xl mb-4">📭</p>
                                <p class="text-gray-700 text-2xl font-black">Nenhum laudo encontrado</p>
                                <p class="text-gray-600 font-semibold mt-2">Tente ajustar seus critérios de busca</p>
                            </div>
                        @else
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead>
                                        <tr class="border-b border-gray-200 bg-gray-50">
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">ID</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Placa</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Cliente</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Status</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Data</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Ação</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200">
                                        @foreach($inspections as $inspection)
                                            <tr class="hover:bg-gray-50 transition">
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <span class="text-sm font-bold text-gray-900 bg-gray-100 px-4 py-2 rounded-full">#{{ $inspection->id }}</span>
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <span class="font-black text-gray-900 text-lg">{{ $inspection->vehicle->license_plate }}</span>
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-gray-700 font-semibold">
                                                    {{ $inspection->vehicle->user->name }}
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    @if($inspection->status === 'approved')
                                                        <span class="px-4 py-2 bg-green-100 text-green-800 rounded-full text-xs font-bold border border-green-300">✅ Aprovado</span>
                                                    @elseif($inspection->status === 'disapproved')
                                                        <span class="px-4 py-2 bg-red-100 text-red-800 rounded-full text-xs font-bold border border-red-300">❌ Reprovado</span>
                                                    @else
                                                        <span class="px-4 py-2 bg-amber-100 text-amber-800 rounded-full text-xs font-bold border border-amber-300">⏳ Pendente</span>
                                                    @endif
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap text-gray-700 font-semibold">
                                                    {{ $inspection->created_at->format('d/m/Y H:i') }}
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="px-5 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition text-xs font-bold shadow-md hover:shadow-lg inline-block">
                                                        Ver Detalhes →
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