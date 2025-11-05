<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Detalhes do Usuário: ') . $user->name }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-8">

            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ __('Dados Cadastrais') }}</h3>
                <div class="grid grid-cols-2 gap-4 text-gray-700">
                    <p><strong>Nome:</strong> {{ $user->name }}</p>
                    <p><strong>E-mail:</strong> {{ $user->email }}</p>
                    <p><strong>ID do Usuário:</strong> {{ $user->id }}</p>
                    <p><strong>Criado em:</strong> {{ $user->created_at->format('d/m/Y') }}</p>
                    <p>
                        <strong>Função:</strong> 
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                            @if($user->role === 'admin') bg-red-100 text-red-800 
                            @elseif($user->role === 'analyst') bg-blue-100 text-blue-800 
                            @else bg-green-100 text-green-800 
                            @endif">
                            {{ ucfirst($user->role) }}
                        </span>
                    </p>
                    <p><strong>Créditos de Vistoria:</strong> {{ $user->inspection_credits ?? 'N/A' }}</p>
                </div>
            </div>

            @if(count($user->vehicles) > 0)
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ __('Histórico de Veículos e Vistorias') }}</h3>
                    
                    @foreach($user->vehicles as $vehicle)
                        <div class="border p-4 mb-4 rounded-md">
                            <p class="font-semibold text-lg mb-2">{{ $vehicle->license_plate }} - {{ $vehicle->brand }} {{ $vehicle->model }}</p>
                            
                            <ul class="list-disc ml-6 space-y-1">
                                @forelse($vehicle->inspections as $inspection)
                                    <li>
                                        Laudo #{{ $inspection->id }} - 
                                        Status: 
                                        <span class="font-medium @if($inspection->status === 'approved') text-green-600 @elseif($inspection->status === 'disapproved') text-red-600 @else text-yellow-600 @endif">
                                            {{ ucfirst($inspection->status) }}
                                        </span>
                                        em {{ $inspection->created_at->format('d/m/Y') }} 
                                        (<a href="{{ route('analyst.inspections.show', $inspection->id) }}" class="text-indigo-500 hover:underline text-sm">Ver Detalhes</a>)
                                    </li>
                                @empty
                                    <li>{{ __('Nenhuma vistoria registrada para este veículo.') }}</li>
                                @endforelse
                            </ul>
                        </div>
                    @endforeach
                </div>
            @endif

            <a href="{{ route('admin.users.index') }}" class="text-indigo-600 hover:underline block pt-4">{{ __('← Voltar ao Gerenciamento de Usuários') }}</a>
        </div>
    </div>
</x-app-layout>