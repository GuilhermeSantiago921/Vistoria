<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Meus Laudos') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <h3 class="text-lg font-bold mb-4">Histórico de Vistorias</h3>
                    @if($inspections->isEmpty())
                        <p>Você ainda não enviou nenhuma vistoria.</p>
                    @else
                        <ul>
                            @foreach($inspections as $inspection)
                                <li class="mb-4 p-4 border rounded-md">
                                    <p><strong>Placa:</strong> {{ $inspection->vehicle->license_plate }}</p>
                                    <p><strong>Status:</strong>
                                        @if($inspection->status === 'approved')
                                            <span class="text-green-600">Aprovado</span>
                                        @elseif($inspection->status === 'disapproved')
                                            <span class="text-red-600">Reprovado</span>
                                        @else
                                            <span class="text-yellow-600">Pendente</span>
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
                </div>
            </div>
        </div>
    </div>
</x-app-layout>