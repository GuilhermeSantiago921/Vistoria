<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Dashboard do Analista - Centro de Controle') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                
                {{-- 1. KPI CARDS (Métricas Chave) --}}
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                    
                    {{-- Total de Vistorias --}}
                    <div class="bg-white p-6 rounded-lg shadow-lg border-l-4 border-indigo-500">
                        <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Total de Laudos') }}</p>
                        <p class="text-3xl font-extrabold mt-1 text-indigo-600">{{ $totalInspections }}</p>
                    </div>

                    {{-- Pendentes (Ação Imediata) --}}
                    <div class="bg-white p-6 rounded-lg shadow-lg border-l-4 border-yellow-500">
                        <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Pendentes de Análise') }}</p>
                        <p class="text-3xl font-extrabold mt-1 text-yellow-600">{{ $pendingInspections }}</p>
                    </div>

                    {{-- Aprovados --}}
                    <div class="bg-white p-6 rounded-lg shadow-lg border-l-4 border-green-500">
                        <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Laudos Aprovados') }}</p>
                        <p class="text-3xl font-extrabold mt-1 text-green-600">{{ $approvedInspections }}</p>
                    </div>

                    {{-- Reprovados --}}
                    <div class="bg-white p-6 rounded-lg shadow-lg border-l-4 border-red-500">
                        <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Laudos Reprovados') }}</p>
                        <p class="text-3xl font-extrabold mt-1 text-red-600">{{ $disapprovedInspections }}</p>
                    </div>
                </div>

                
                {{-- 2. LISTA DE AÇÃO RÁPIDA (Pendentes Recentes) --}}
                <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <h3 class="text-lg font-bold mb-4">{{ __('Ação Imediata: Vistorias Mais Recentes') }}</h3>
                        
                        @if($recentPending->isEmpty())
                            <p class="text-green-600 font-semibold">Nenhuma vistoria pendente no momento. Ótimo trabalho!</p>
                        @else
                            <ul class="divide-y divide-gray-200">
                                @foreach($recentPending as $inspection)
                                    <li class="py-3 flex justify-between items-center">
                                        <div>
                                            <p class="text-sm font-medium text-gray-900">
                                                Placa: {{ $inspection->vehicle->license_plate }} 
                                                <span class="text-gray-500 text-xs ml-2">({{ $inspection->vehicle->brand }} {{ $inspection->vehicle->model }})</span>
                                            </p>
                                            <p class="text-xs text-gray-500 mt-1">
                                                Enviado por: {{ $inspection->vehicle->user->name }} - {{ $inspection->created_at->diffForHumans() }}
                                            </p>
                                        </div>
                                        <a href="{{ route('analyst.inspections.show', $inspection) }}" class="text-white bg-indigo-500 hover:bg-indigo-600 text-xs font-bold py-1 px-3 rounded-full">
                                            Analisar
                                        </a>
                                    </li>
                                @endforeach
                            </ul>
                            <div class="mt-4 text-right">
                                <a href="{{ route('analyst.inspections.all') }}" class="text-blue-500 hover:underline text-sm font-medium">Ver todas as {{ $pendingInspections }} Vistorias Pendentes →</a>
                            </div>
                        @endif
                    </div>
                </div>

            </div>
        </div>
    </div>
</x-app-layout>