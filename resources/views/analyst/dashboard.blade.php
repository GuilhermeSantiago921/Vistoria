<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    👨‍💼 Painel do Analista
                </h2>
                <p class="text-gray-600 font-semibold mt-2">Centro de controle de inspeções</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                
                {{-- MÉTRICAS CHAVE --}}
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                    
                    {{-- Total de Laudos --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Total de Laudos</p>
                                <p class="text-4xl font-black text-indigo-600 mt-2">{{ $totalInspections }}</p>
                                <p class="text-gray-600 text-sm mt-1">Processados</p>
                            </div>
                            <span class="text-5xl">📊</span>
                        </div>
                    </div>

                    {{-- Pendentes --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Pendentes</p>
                                <p class="text-4xl font-black text-amber-600 mt-2">{{ $pendingInspections }}</p>
                                <p class="text-gray-600 text-sm mt-1">Aguardando análise</p>
                            </div>
                            <span class="text-5xl">⏳</span>
                        </div>
                    </div>

                    {{-- Aprovados --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Aprovados</p>
                                <p class="text-4xl font-black text-green-600 mt-2">{{ $approvedInspections }}</p>
                                <p class="text-gray-600 text-sm mt-1">Conclusão positiva</p>
                            </div>
                            <span class="text-5xl">✅</span>
                        </div>
                    </div>

                    {{-- Reprovados --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Reprovados</p>
                                <p class="text-4xl font-black text-red-600 mt-2">{{ $disapprovedInspections }}</p>
                                <p class="text-gray-600 text-sm mt-1">Não conformidade</p>
                            </div>
                            <span class="text-5xl">❌</span>
                        </div>
                    </div>
                </div>

                
                {{-- AÇÃO RÁPIDA: PENDENTES RECENTES --}}
                <div class="bg-white rounded-2xl shadow-md border border-gray-100 overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-100 bg-white">
                        <h3 class="text-lg font-black text-gray-900">🚨 Ação Imediata</h3>
                    </div>
                    
                    <div class="p-6">
                        @if($recentPending->isEmpty())
                            <div class="text-center py-12">
                                <p class="text-5xl mb-3 opacity-50">✨</p>
                                <p class="text-gray-600 font-semibold">Nenhuma vistoria pendente</p>
                                <p class="text-gray-500 text-sm mt-1">Ótimo trabalho! Você está em dia.</p>
                            </div>
                        @else
                            <div class="space-y-3">
                                @foreach($recentPending as $inspection)
                                    <div class="p-4 rounded-lg border border-gray-200 hover:border-amber-400 hover:bg-amber-50 transition flex items-start justify-between">
                                        <div class="flex-1">
                                            <p class="font-bold text-gray-900">
                                                🚗 {{ $inspection->vehicle->license_plate }}
                                                <span class="text-gray-500 text-xs ml-2">{{ $inspection->vehicle->brand }} {{ $inspection->vehicle->model }}</span>
                                            </p>
                                            <p class="text-sm text-gray-600 mt-1">
                                                {{ $inspection->vehicle->user->name }} • {{ $inspection->created_at->diffForHumans() }}
                                            </p>
                                        </div>
                                        <a href="{{ route('analyst.inspections.show', $inspection) }}" class="ml-4 px-3 py-1 bg-indigo-600 text-white rounded text-xs font-bold hover:bg-indigo-700 transition whitespace-nowrap">
                                            Analisar
                                        </a>
                                    </div>
                                @endforeach
                            </div>
                            <div class="mt-4 text-center">
                                <a href="{{ route('analyst.inspections.all') }}" class="text-blue-600 hover:text-blue-700 text-sm font-semibold">
                                    Ver todas as {{ $pendingInspections }} pendentes →
                                </a>
                            </div>
                        @endif
                    </div>
                </div>

            </div>
        </div>
    </div>
</x-app-layout>