<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Painel de Administrador') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="bg-white p-6 rounded-lg shadow-md text-center">
                        <p class="text-3xl font-bold text-blue-600">{{ $user_count }}</p>
                        <p class="text-gray-500">Usuários Totais</p>
                    </div>
                    <div class="bg-white p-6 rounded-lg shadow-md text-center">
                        <p class="text-3xl font-bold text-green-600">{{ $analyst_count }}</p>
                        <p class="text-gray-500">Analistas Registrados</p>
                    </div>
                    <div class="bg-white p-6 rounded-lg shadow-md text-center flex items-center justify-center">
                        <a href="{{ route('admin.users.create') }}" class="text-white bg-indigo-600 hover:bg-indigo-700 font-bold py-2 px-4 rounded-lg transition-colors duration-200">
                            {{ __('+ Criar Novo Usuário') }}
                        </a>
                    </div>
                </div>

                <div class="bg-white p-6 rounded-lg shadow-md border-l-4 border-purple-500">
    <p class="text-xs uppercase text-gray-500 font-semibold">{{ __('Gestão Completa') }}</p>
    <p class="text-3xl font-extrabold mt-1 text-purple-600">{{ $user_count }}</p>
    <a href="{{ route('admin.users.index') }}" class="mt-2 inline-block text-sm text-blue-600 hover:underline">
        {{ __('Ver/Gerenciar Todos') }}
    </a>
</div>

                <div class="bg-white p-6 rounded-lg shadow-md">
                    <h3 class="text-lg font-bold mb-4">Filtros Avançados</h3>
                    <form method="GET" action="{{ route('admin.dashboard') }}" class="flex flex-col md:flex-row space-y-4 md:space-y-0 md:space-x-4">
                        
                        <div>
                            <label for="plate" class="block text-sm font-medium text-gray-700">Buscar por Placa</label>
                            <x-text-input id="plate" name="plate" type="text" value="{{ request('plate') }}" placeholder="Ex: ABC1234" class="mt-1 block w-full" />
                        </div>
                        
                        <div>
                            <label for="date" class="block text-sm font-medium text-gray-700">Filtrar por Data</label>
                            <x-text-input id="date" name="date" type="date" value="{{ request('date') }}" class="mt-1 block w-full" />
                        </div>

                        <div class="flex items-end space-x-2">
                            <x-primary-button type="submit" class="h-10">
                                {{ __('Buscar') }}
                            </x-primary-button>
                            @if(request()->filled('plate') || request()->filled('date'))
                                <a href="{{ route('admin.dashboard') }}" class="h-10 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 flex items-center">
                                    {{ __('Limpar') }}
                                </a>
                            @endif
                        </div>
                    </form>
                </div>

                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 bg-white border-b border-gray-200">
                        <h3 class="text-lg font-bold mb-4">Resultados da Busca (Todos os Laudos)</h3>
                        
                        @if($inspections->isEmpty())
                            <p>Nenhum laudo encontrado com os filtros aplicados.</p>
                        @else
                            <div class="overflow-x-auto">
                                <table class="min-w-full divide-y divide-gray-200">
                                    <thead>
                                        <tr>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Placa</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ação</th>
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
                                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">APROVADO</span>
                                                    @elseif($inspection->status === 'disapproved')
                                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">REPROVADO</span>
                                                    @else
                                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">PENDENTE</span>
                                                    @endif
                                                </td>
                                                <td class="px-6 py-4 whitespace-nowrap">{{ $inspection->created_at->format('d/m/Y H:i') }}</td>
                                                <td class="px-6 py-4 whitespace-nowrap">
                                                    <a href="{{ route('analyst.inspections.show', $inspection) }}" class="text-indigo-600 hover:text-indigo-900">Ver Detalhes</a>
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