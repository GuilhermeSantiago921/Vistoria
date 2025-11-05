<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Todas as Vistorias') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <h3 class="text-lg font-bold mb-4">Lista Completa de Vistorias</h3>
                    
                    @if($inspections->isEmpty())
                        <p>Nenhuma vistoria encontrada.</p>
                    @else
                        <div class="overflow-x-auto">
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead>
                                    <tr>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Placa</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Analista</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ação</th> {{-- Coluna de Ação --}}
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    @foreach($inspections as $inspection)
                                        <tr>
                                            <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->id }}</td>
                                            <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->vehicle->license_plate }}</td>
                                            <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->vehicle->user->name }}</td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                @if($inspection->status === 'approved')
                                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Aprovado</span>
                                                @elseif($inspection->status === 'disapproved')
                                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Reprovado</span>
                                                @else
                                                    <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">Pendente</span>
                                                @endif
                                            </td>
                                            <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->analyst->name ?? 'N/A' }}</td>
                                            <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->created_at->format('d/m/Y H:i') }}</td>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                {{-- LÓGICA DE BOTÃO --}}
                                                @if($inspection->status === 'pending')
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="inline-flex items-center justify-center text-white bg-indigo-500 hover:bg-indigo-600 text-xs font-bold py-1 px-3 rounded-full">
                                                        Analisar
                                                    </a>
                                                @else
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="text-gray-500 hover:text-gray-700 text-xs font-bold py-1 px-3">
                                                        Ver Detalhes
                                                    </a>
                                                @endif
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
</x-app-layout>