<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-bold text-3xl text-gray-900">
                    ⚙️ Painel de Administrador
                </h2>
                <p class="text-gray-600 mt-1">Gerencie usuários, inspetores e inspeções</p>
            </div>
        </div>
    </x-slot>

    <div class="py-8">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                {{-- CARDS DE RESUMO --}}
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {{-- Card 1: Total de Usuários --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-600 to-blue-800 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-4">
                                <p class="text-xs uppercase opacity-80 font-bold tracking-widest">Total de Usuários</p>
                                <span class="text-2xl">👥</span>
                            </div>
                            <p class="text-4xl font-extrabold">{{ $user_count }}</p>
                            <p class="text-sm text-blue-100 mt-2">Usuários registrados no sistema</p>
                        </div>
                    </div>

                    {{-- Card 2: Total de Analistas --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-purple-600 to-pink-600 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-4">
                                <p class="text-xs uppercase opacity-80 font-bold tracking-widest">Analistas</p>
                                <span class="text-2xl">👨‍💼</span>
                            </div>
                            <p class="text-4xl font-extrabold">{{ $analyst_count }}</p>
                            <p class="text-sm text-pink-100 mt-2">Profissionais registrados</p>
                        </div>
                    </div>

                    {{-- Card 3: Criar Novo Usuário --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-green-500 to-emerald-600 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1 cursor-pointer">
                        <a href="{{ route('admin.users.create') }}" class="flex flex-col items-center justify-center h-full">
                            <span class="text-4xl mb-3">➕</span>
                            <p class="font-bold text-center">Criar Novo Usuário</p>
                        </a>
                    </div>
                </div>

                {{-- FILTROS AVANÇADOS --}}
                <div class="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
                    <h3 class="text-xl font-bold mb-4 flex items-center gap-2">
                        🔍 Filtros Avançados
                    </h3>
                    <form method="GET" action="{{ route('admin.dashboard') }}" class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        
                        <div>
                            <label for="plate" class="block text-sm font-semibold text-gray-700 mb-2">Buscar por Placa</label>
                            <input id="plate" name="plate" type="text" value="{{ request('plate') }}" placeholder="Ex: ABC1234" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition" />
                        </div>
                        
                        <div>
                            <label for="date" class="block text-sm font-semibold text-gray-700 mb-2">Filtrar por Data</label>
                            <input id="date" name="date" type="date" value="{{ request('date') }}" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-transparent transition" />
                        </div>

                        <div class="flex items-end gap-2">
                            <button type="submit" class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold">
                                🔎 Buscar
                            </button>
                            @if(request()->filled('plate') || request()->filled('date'))
                                <a href="{{ route('admin.dashboard') }}" class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition font-semibold">
                                    ✕ Limpar
                                </a>
                            @endif
                        </div>
                    </form>
                </div>

                {{-- TABELA DE RESULTADOS --}}
                <div class="bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
                    <div class="px-6 py-6 border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white">
                        <h3 class="text-2xl font-bold text-gray-900">📋 Resultados da Busca</h3>
                        <p class="text-sm text-gray-600 mt-1">Todos os laudos no sistema</p>
                    </div>
                    
                    <div class="p-6">
                        @if($inspections->isEmpty())
                            <div class="text-center py-12">
                                <p class="text-5xl mb-4">📭</p>
                                <p class="text-gray-600 text-lg">Nenhum laudo encontrado com os filtros aplicados.</p>
                            </div>
                        @else
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead>
                                        <tr class="border-b-2 border-gray-200">
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">ID</th>
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">Placa</th>
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">Cliente</th>
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">Status</th>
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">Data</th>
                                            <th class="px-4 py-3 text-left text-xs font-bold text-gray-700 uppercase tracking-wider">Ação</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200">
                                        @foreach($inspections as $inspection)
                                            <tr class="hover:bg-gray-50 transition">
                                                <td class="px-4 py-4 whitespace-nowrap">
                                                    <span class="text-sm font-semibold text-gray-900">#{{ $inspection->id }}</span>
                                                </td>
                                                <td class="px-4 py-4 whitespace-nowrap">
                                                    <span class="font-bold text-gray-900">{{ $inspection->vehicle->license_plate }}</span>
                                                </td>
                                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-600">
                                                    {{ $inspection->vehicle->user->name }}
                                                </td>
                                                <td class="px-4 py-4 whitespace-nowrap">
                                                    @if($inspection->status === 'approved')
                                                        <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-bold">✅ Aprovado</span>
                                                    @elseif($inspection->status === 'disapproved')
                                                        <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-xs font-bold">❌ Reprovado</span>
                                                    @else
                                                        <span class="px-3 py-1 bg-amber-100 text-amber-800 rounded-full text-xs font-bold">⏳ Pendente</span>
                                                    @endif
                                                </td>
                                                <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-600">
                                                    {{ $inspection->created_at->format('d/m/Y H:i') }}
                                                </td>
                                                <td class="px-4 py-4 whitespace-nowrap">
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="px-3 py-1 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition text-xs font-semibold inline-block">
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