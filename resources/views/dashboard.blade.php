<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-bold text-3xl text-gray-900">
                    👋 Bem-vindo(a), {{ Auth::user()->name }}!
                </h2>
                <p class="text-gray-600 mt-1">Sistema de Inspeção Veicular Professional</p>
            </div>
            <div class="text-right">
                <p class="text-sm text-gray-500">{{ now()->format('d \\d\\e F \\d\\e Y') }}</p>
            </div>
        </div>
    </x-slot>

    <div class="py-8">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                
                {{-- VISÃO GERAL RÁPIDA - Cards Com Gradient --}}
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    
                    {{-- Card 1: Créditos Disponíveis --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-600 to-blue-800 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                        <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity"></div>
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-4">
                                <p class="text-xs uppercase opacity-80 font-bold tracking-widest">Créditos</p>
                                <span class="text-2xl">💳</span>
                            </div>
                            <p class="text-4xl font-extrabold mb-2">{{ Auth::user()->inspection_credits ?? 0 }}</p>
                            <p class="text-sm text-blue-100">
                                @if (Auth::user()->inspection_credits > 0)
                                    ✅ Você pode enviar uma vistoria agora
                                @else
                                    ❌ Adquira créditos para continuar
                                @endif
                            </p>
                        </div>
                    </div>

                    {{-- Card 2: Status Último Laudo --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1 border border-gray-200">
                        <div class="relative z-10">
                            @php
                                $lastInspection = $inspections->first();
                            @endphp
                            <div class="flex items-center justify-between mb-4">
                                <p class="text-xs uppercase text-gray-600 font-bold tracking-widest">Último Status</p>
                                <span class="text-2xl">📋</span>
                            </div>

                            @if ($lastInspection)
                                <p class="text-3xl font-extrabold mb-2 @if($lastInspection->status == 'approved') text-green-600 @elseif($lastInspection->status == 'disapproved') text-red-600 @else text-amber-600 @endif">
                                    @if($lastInspection->status == 'approved')
                                        ✅ Aprovado
                                    @elseif($lastInspection->status == 'disapproved')
                                        ❌ Reprovado
                                    @else
                                        ⏳ Pendente
                                    @endif
                                </p>
                                <p class="text-sm text-gray-600">
                                    <strong>{{ $lastInspection->vehicle->license_plate }}</strong> - {{ $lastInspection->created_at->diffForHumans() }}
                                </p>
                            @else
                                <p class="text-3xl font-extrabold mb-2 text-gray-400">🆕 Novo</p>
                                <p class="text-sm text-gray-600">Nenhuma vistoria enviada ainda</p>
                            @endif
                        </div>
                    </div>

                    {{-- Card 3: Total de Vistorias --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-purple-600 to-pink-600 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1">
                        <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity"></div>
                        <div class="relative z-10">
                            <div class="flex items-center justify-between mb-4">
                                <p class="text-xs uppercase opacity-80 font-bold tracking-widest">Totalizadas</p>
                                <span class="text-2xl">📊</span>
                            </div>
                            <p class="text-4xl font-extrabold mb-2">{{ $inspections->count() }}</p>
                            <p class="text-sm text-pink-100">Vistorias realizadas</p>
                        </div>
                    </div>

                    {{-- Card 4: CTA Button --}}
                    <div class="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-green-500 to-emerald-600 text-white p-6 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1 cursor-pointer">
                        @if (Auth::user()->inspection_credits > 0)
                            <a href="{{ route('inspections.create') }}" class="flex flex-col items-center justify-center h-full">
                                <span class="text-4xl mb-3">🚀</span>
                                <p class="font-bold text-center">Iniciar Nova Vistoria</p>
                            </a>
                        @else
                            <a href="{{ route('payment.form') }}" class="flex flex-col items-center justify-center h-full">
                                <span class="text-4xl mb-3">�</span>
                                <p class="font-bold text-center">Adquirir Créditos</p>
                            </a>
                        @endif
                    </div>
                </div>

                {{-- SEÇÃO DE HISTÓRICO --}}
                <div class="bg-white rounded-2xl shadow-lg border border-gray-200 overflow-hidden">
                    <div class="px-6 py-6 border-b border-gray-200 bg-gradient-to-r from-gray-50 to-white">
                        <div class="flex items-center justify-between">
                            <div>
                                <h3 class="text-2xl font-bold text-gray-900">📋 Histórico de Laudos</h3>
                                <p class="text-sm text-gray-600 mt-1">Suas inspeções recentes</p>
                            </div>
                            <a href="{{ route('inspections.history') }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold">
                                Ver Todos →
                            </a>
                        </div>
                    </div>
                    
                    <div class="p-6">
                        @if($inspections->isEmpty())
                            <div class="text-center py-12">
                                <p class="text-5xl mb-4">📭</p>
                                <p class="text-gray-600 text-lg">Você ainda não enviou nenhuma vistoria.</p>
                            </div>
                        @else
                            <div class="space-y-3">
                                @foreach($inspections->take(5) as $inspection)
                                    <div class="p-4 rounded-xl border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition group cursor-pointer">
                                        <div class="flex items-start justify-between">
                                            <div class="flex-1">
                                                <p class="font-bold text-gray-900 text-lg">
                                                    🚗 {{ $inspection->vehicle->license_plate }}
                                                </p>
                                                <p class="text-sm text-gray-600 mt-1">
                                                    <span>{{ $inspection->vehicle->brand }} / {{ $inspection->vehicle->model }}</span> 
                                                    • <span>{{ $inspection->created_at->format('d/m/Y H:i') }}</span>
                                                </p>
                                            </div>
                                            <div class="text-right">
                                                @if($inspection->status === 'approved')
                                                    <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-semibold">✅ Aprovado</span>
                                                @elseif($inspection->status === 'disapproved')
                                                    <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-sm font-semibold">❌ Reprovado</span>
                                                @else
                                                    <span class="px-3 py-1 bg-amber-100 text-amber-800 rounded-full text-sm font-semibold">⏳ Pendente</span>
                                                @endif
                                            </div>
                                        </div>
                                        @if($inspection->notes)
                                            <p class="text-sm text-gray-700 mt-3 border-t border-gray-200 pt-3">
                                                <strong>📝 Anotações:</strong> {{ Str::limit($inspection->notes, 100) }}
                                            </p>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @endif
                    </div>
                </div>

            </div>
        </div>
    </div>
</x-app-layout>