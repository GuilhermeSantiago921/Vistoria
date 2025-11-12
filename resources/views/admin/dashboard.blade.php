<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    ⚙️ Painel de Administrador
                </h2>
                <p class="text-gray-700 font-bold mt-2">Gerencie usuários, inspetores e inspeções com facilidade</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-gradient-to-br from-gray-50 via-blue-50 to-indigo-50 min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-10">
                {{-- CARDS DE RESUMO --}}
                <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {{-- Card 1: Total de Usuários --}}
                    <div class="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-blue-500 to-blue-700 text-white p-8 shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:-translate-y-2 border-2 border-blue-300">
                        <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity"></div>
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-6">
                                <p class="text-sm uppercase opacity-90 font-black tracking-widest">Total de Usuários</p>
                                <span class="text-5xl group-hover:scale-125 transition transform">👥</span>
                            </div>
                            <p class="text-6xl font-black mb-3">{{ $user_count }}</p>
                            <p class="text-blue-100 font-bold text-lg">Usuários registrados no sistema</p>
                        </div>
                    </div>

                    {{-- Card 2: Total de Analistas --}}
                    <div class="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-purple-500 to-pink-600 text-white p-8 shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:-translate-y-2 border-2 border-pink-300">
                        <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity"></div>
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-6">
                                <p class="text-sm uppercase opacity-90 font-black tracking-widest">Analistas</p>
                                <span class="text-5xl group-hover:scale-125 transition transform">👨‍💼</span>
                            </div>
                            <p class="text-6xl font-black mb-3">{{ $analyst_count }}</p>
                            <p class="text-pink-100 font-bold text-lg">Profissionais registrados</p>
                        </div>
                    </div>

                    {{-- Card 3: Criar Novo Usuário --}}
                    <div class="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-green-500 to-emerald-600 text-white p-8 shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:-translate-y-2 cursor-pointer border-2 border-green-300">
                        <a href="{{ route('admin.users.create') }}" class="flex flex-col items-center justify-center h-full gap-4">
                            <span class="text-6xl group-hover:scale-125 transition transform">➕</span>
                            <p class="font-black text-center text-xl">Criar Novo Usuário</p>
                        </a>
                    </div>
                </div>

                {{-- FILTROS AVANÇADOS --}}
                <div class="bg-white rounded-3xl shadow-xl border-2 border-gray-200 p-8 backdrop-blur-sm bg-opacity-95">
                    <h3 class="text-2xl font-black mb-6 flex items-center gap-3 text-gray-900">
                        🔍 Filtros Avançados
                    </h3>
                    <form method="GET" action="{{ route('admin.dashboard') }}" class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        
                        <div>
                            <label for="plate" class="block text-sm font-black text-gray-900 mb-3 uppercase tracking-wider">Buscar por Placa</label>
                            <input id="plate" name="plate" type="text" value="{{ request('plate') }}" placeholder="Ex: ABC1234" class="w-full px-4 py-3 rounded-xl border-2 border-gray-300 focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition font-bold text-gray-900 placeholder-gray-500" />
                        </div>
                        
                        <div>
                            <label for="date" class="block text-sm font-black text-gray-900 mb-3 uppercase tracking-wider">Filtrar por Data</label>
                            <input id="date" name="date" type="date" value="{{ request('date') }}" class="w-full px-4 py-3 rounded-xl border-2 border-gray-300 focus:ring-2 focus:ring-blue-600 focus:border-blue-600 transition font-bold text-gray-900" />
                        </div>

                        <div class="flex items-end gap-3">
                            <button type="submit" class="flex-1 px-6 py-3 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 transition font-black text-lg shadow-lg hover:shadow-xl">
                                🔎 Buscar
                            </button>
                            @if(request()->filled('plate') || request()->filled('date'))
                                <a href="{{ route('admin.dashboard') }}" class="px-6 py-3 bg-gray-300 text-gray-900 rounded-xl hover:bg-gray-400 transition font-black text-lg shadow-lg hover:shadow-xl">
                                    ✕ Limpar
                                </a>
                            @endif
                        </div>
                    </form>
                </div>

                {{-- TABELA DE RESULTADOS --}}
                <div class="bg-white rounded-3xl shadow-xl border-2 border-gray-200 overflow-hidden backdrop-blur-sm bg-opacity-95">
                    <div class="px-8 py-8 border-b-2 border-gray-200 bg-gradient-to-r from-gray-50 to-blue-50">
                        <h3 class="text-3xl font-black text-gray-900">📋 Resultados da Busca</h3>
                        <p class="text-gray-700 font-bold mt-2 text-lg">Todos os laudos no sistema</p>
                    </div>
                    
                    <div class="p-8">
                        @if($inspections->isEmpty())
                            <div class="text-center py-16">
                                <p class="text-7xl mb-6 animate-bounce">📭</p>
                                <p class="text-gray-700 text-2xl font-black">Nenhum laudo encontrado com os filtros aplicados.</p>
                                <p class="text-gray-600 text-lg font-bold mt-3">Tente ajustar seus critérios de busca</p>
                            </div>
                        @else
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead>
                                        <tr class="border-b-2 border-gray-300 bg-gradient-to-r from-gray-100 to-gray-50">
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">ID</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Placa</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Cliente</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Status</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Data</th>
                                            <th class="px-6 py-4 text-left text-xs font-black text-gray-900 uppercase tracking-wider">Ação</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y-2 divide-gray-200">
                                        @foreach($inspections as $inspection)
                                            <tr class="hover:bg-blue-50 transition duration-200 border-gray-200">
                                                <td class="px-6 py-5 whitespace-nowrap">
                                                    <span class="text-sm font-black text-gray-900 bg-gray-100 px-4 py-2 rounded-full">#{{ $inspection->id }}</span>
                                                </td>
                                                <td class="px-6 py-5 whitespace-nowrap">
                                                    <span class="font-black text-gray-900 text-lg">{{ $inspection->vehicle->license_plate }}</span>
                                                </td>
                                                <td class="px-6 py-5 whitespace-nowrap">
                                                    <p class="text-gray-700 font-bold text-lg">{{ $inspection->vehicle->user->name }}</p>
                                                </td>
                                                <td class="px-6 py-5 whitespace-nowrap">
                                                    @if($inspection->status === 'approved')
                                                        <span class="px-4 py-2 bg-green-100 text-green-900 rounded-full text-sm font-black border-2 border-green-400">✅ Aprovado</span>
                                                    @elseif($inspection->status === 'disapproved')
                                                        <span class="px-4 py-2 bg-red-100 text-red-900 rounded-full text-sm font-black border-2 border-red-400">❌ Reprovado</span>
                                                    @else
                                                        <span class="px-4 py-2 bg-amber-100 text-amber-900 rounded-full text-sm font-black border-2 border-amber-400">⏳ Pendente</span>
                                                    @endif
                                                </td>
                                                <td class="px-6 py-5 whitespace-nowrap text-gray-700 font-bold text-lg">
                                                    {{ $inspection->created_at->format('d/m/Y H:i') }}
                                                </td>
                                                <td class="px-6 py-5 whitespace-nowrap">
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="px-4 py-2 bg-gradient-to-r from-blue-600 to-blue-700 text-white rounded-xl hover:from-blue-700 hover:to-blue-800 transition text-xs font-black inline-block shadow-lg hover:shadow-xl border-2 border-blue-400">
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