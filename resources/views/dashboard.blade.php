<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Bem-vindo(a), ') . Auth::user()->name }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-6">
                
                {{-- VISÃO GERAL RÁPIDA --}}
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    
                    {{-- 1. Créditos Disponíveis --}}
                    <div class="bg-indigo-600 text-white p-6 rounded-lg shadow-xl">
                        <p class="text-xs uppercase opacity-80 font-semibold">{{ __('Créditos de Vistoria') }}</p>
                        <p class="text-4xl font-extrabold mt-1">{{ Auth::user()->inspection_credits ?? 0 }}</p>
                        <p class="text-sm mt-2">
                            @if (Auth::user()->inspection_credits > 0)
                                {{ __('Você pode enviar uma nova vistoria agora.') }}
                            @else
                                {{ __('Adquira mais créditos para continuar.') }}
                            @endif
                        </p>
                    </div>

                    {{-- 2. Status do Último Laudo --}}
                    <div class="bg-white p-6 rounded-lg shadow-xl">
                        @php
                            $lastInspection = $inspections->first();
                        @endphp

                        <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Último Status') }}</p>

                        @if ($lastInspection)
                            <p class="text-3xl font-extrabold mt-1 @if($lastInspection->status == 'approved') text-green-600 @elseif($lastInspection->status == 'disapproved') text-red-600 @else text-yellow-600 @endif">
                                {{-- TRADUÇÃO DE STATUS --}}
                                @if($lastInspection->status == 'approved')
                                    {{ __('Aprovado') }}
                                @elseif($lastInspection->status == 'disapproved')
                                    {{ __('Reprovado') }}
                                @else
                                    {{ __('Pendente') }}
                                @endif
                            </p>
                            <p class="text-sm text-gray-600 mt-2">
                                {{ __('Placa:') . ' ' . $lastInspection->vehicle->license_plate . ' - ' . $lastInspection->created_at->diffForHumans() }}
                            </p>
                        @else
                            <p class="text-3xl font-extrabold mt-1 text-gray-400">{{ __('Novo por aqui') }}</p>
                            <p class="text-sm text-gray-600 mt-2">{{ __('Nenhuma vistoria enviada ainda.') }}</p>
                        @endif
                    </div>
                    
                    {{-- 3. Chamada para Ação --}}
                    <div class="bg-white p-6 rounded-lg shadow-xl flex items-center justify-center border border-indigo-200 hover:bg-indigo-50 transition-colors duration-200">
                        @if (Auth::user()->inspection_credits > 0)
                            <a href="{{ route('inspections.create') }}" class="text-center font-bold text-indigo-600 text-lg">
                                <span class="text-2xl block mb-1">🚀</span>
                                {{ __('Iniciar Nova Vistoria') }}
                            </a>
                        @else
                            <a href="{{ route('payment.form') }}" class="text-center font-bold text-red-500 text-lg">
                                <span class="text-2xl block mb-1">🔒</span>
                                {{ __('Adquirir Crédito Agora') }}
                            </a>
                        @endif
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <h3 class="text-lg font-bold mb-4">{{ __('Histórico de Laudos') }}</h3>
                        
                        @if($inspections->isEmpty())
                            <p>{{ __('Você ainda não enviou nenhuma vistoria.') }}</p>
                        @else
                            <ul>
                                @foreach($inspections as $inspection)
                                    <li class="mb-4 p-4 border rounded-md">
                                        <p><strong>Placa:</strong> {{ $inspection->vehicle->license_plate }}</p>
                                        <p><strong>Status:</strong>
                                            {{-- TRADUÇÃO DE STATUS NA LISTA DE HISTÓRICO --}}
                                            @if($inspection->status === 'approved')
                                                <span class="text-green-600">{{ __('Aprovado') }}</span>
                                            @elseif($inspection->status === 'disapproved')
                                                <span class="text-red-600">{{ __('Reprovado') }}</span>
                                            @else
                                                <span class="text-yellow-600">{{ __('Pendente') }}</span>
                                            @endif
                                        </p>
                                        <p><strong>Enviado em:</strong> {{ $inspection->created_at->format('d/m/Y H:i') }}</p>
                                        @if($inspection->notes)
                                            <p><strong>Anotações do Analista:</strong> {{ $inspection->notes }}</p>
                                        @endif
                                    </li>
                                @endforeach
                            </ul>
                        @endif
                        <a href="{{ route('inspections.history') }}" class="text-blue-500 hover:underline mt-4 inline-block">{{ __('Ver todos os laudos') }}</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>