<x-app-layout>
    <x-slot name="header">
        <div class="flex justify-between items-center">
            <div>
                <h2 class="font-black text-4xl text-gray-900">
                    👋 Bem-vindo(a), {{ Auth::user()->name }}!
                </h2>
                <p class="text-gray-600 font-semibold mt-2">Sistema de Inspeção Veicular</p>
            </div>
            <div class="text-right">
                <p class="text-gray-700 text-sm">{{ now()->format('d/m/Y') }}</p>
            </div>
        </div>
    </x-slot>

    <div class="py-12 bg-white min-h-screen">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-8">
                
                {{-- RESUMO RÁPIDO --}}
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    
                    {{-- Card 1: Créditos Disponíveis --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Créditos Disponíveis</p>
                                <p class="text-4xl font-black text-blue-600 mt-2">{{ Auth::user()->inspection_credits ?? 0 }}</p>
                                <p class="text-gray-600 text-sm mt-1">
                                    @if (Auth::user()->inspection_credits > 0)
                                        ✅ Pronto para enviar
                                    @else
                                        ❌ Adquira créditos
                                    @endif
                                </p>
                            </div>
                            <span class="text-5xl">💳</span>
                        </div>
                    </div>

                    {{-- Card 2: Último Laudo --}}
                    <div class="group bg-white rounded-2xl shadow-md border border-gray-100 p-6 hover:shadow-lg transition-all">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                <p class="text-gray-500 text-sm font-semibold">Último Status</p>
                                @php $lastInspection = $inspections->first(); @endphp
                                @if ($lastInspection)
                                    <p class="text-3xl font-black mt-2 @if($lastInspection->status == 'approved') text-green-600 @elseif($lastInspection->status == 'disapproved') text-red-600 @else text-amber-600 @endif">
                                        @if($lastInspection->status == 'approved') ✅ Aprovado @elseif($lastInspection->status == 'disapproved') ❌ Reprovado @else ⏳ Pendente @endif
                                    </p>
                                    <p class="text-gray-600 text-sm mt-1">{{ $lastInspection->vehicle->license_plate }} • {{ $lastInspection->created_at->format('d/m') }}</p>
                                @else
                                    <p class="text-2xl font-black text-gray-600 mt-2">🆕 Novo</p>
                                    <p class="text-gray-600 text-sm mt-1">Nenhuma vistoria ainda</p>
                                @endif
                            </div>
                            <span class="text-5xl">📋</span>
                        </div>
                    </div>

                    {{-- Card 3: CTA --}}
                    <a href="@if (Auth::user()->inspection_credits > 0) {{ route('inspections.create') }} @else {{ route('payment.form') }} @endif" class="group bg-blue-50 rounded-2xl shadow-md border border-blue-200 p-6 hover:shadow-lg transition-all hover:bg-blue-100">
                        <div class="flex items-start justify-between">
                            <div class="flex-1">
                                @if (Auth::user()->inspection_credits > 0)
                                    <p class="text-blue-700 text-sm font-semibold">Ação Rápida</p>
                                    <p class="text-3xl font-black text-blue-600 mt-2">Iniciar</p>
                                    <p class="text-blue-600 text-sm mt-1 font-medium">Nova Vistoria</p>
                                @else
                                    <p class="text-blue-700 text-sm font-semibold">Ação Rápida</p>
                                    <p class="text-3xl font-black text-blue-600 mt-2">Comprar</p>
                                    <p class="text-blue-600 text-sm mt-1 font-medium">Créditos</p>
                                @endif
                            </div>
                            <span class="text-4xl opacity-30">→</span>
                        </div>
                    </a>
                </div>

                {{-- HISTÓRICO DE LAUDOS --}}
                <div class="bg-white rounded-2xl shadow-md border border-gray-100 overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-100 bg-white flex items-center justify-between">
                        <h3 class="text-lg font-black text-gray-900">📋 Histórico</h3>
                        <a href="{{ route('inspections.history') }}" class="text-xs font-bold text-blue-600 hover:text-blue-700">Ver Todos →</a>
                    </div>
                    
                    <div class="p-6">
                        @if($inspections->isEmpty())
                            <div class="text-center py-12">
                                <p class="text-5xl mb-3 opacity-50">📭</p>
                                <p class="text-gray-600 font-semibold">Nenhuma vistoria enviada</p>
                            </div>
                        @else
                            <div class="space-y-3">
                                @foreach($inspections->take(5) as $inspection)
                                    <div class="p-4 rounded-lg border border-gray-200 hover:border-blue-400 hover:bg-blue-50 transition">
                                        <div class="flex items-start justify-between">
                                            <div class="flex-1">
                                                <p class="font-bold text-gray-900">🚗 {{ $inspection->vehicle->license_plate }}</p>
                                                <p class="text-sm text-gray-600 mt-1">{{ $inspection->vehicle->brand }} / {{ $inspection->vehicle->model }}</p>
                                                <p class="text-xs text-gray-500 mt-1">{{ $inspection->created_at->format('d/m/Y H:i') }}</p>
                                            </div>
                                            <div>
                                                @if($inspection->status === 'approved')
                                                    <span class="px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-bold">✅ Aprovado</span>
                                                @elseif($inspection->status === 'disapproved')
                                                    <span class="px-2 py-1 bg-red-100 text-red-700 rounded text-xs font-bold">❌ Reprovado</span>
                                                @else
                                                    <span class="px-2 py-1 bg-yellow-100 text-yellow-700 rounded text-xs font-bold">⏳ Pendente</span>
                                                @endif
                                            </div>
                                        </div>
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