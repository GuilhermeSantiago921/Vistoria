<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Gerenciamento de Usuários') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-8">
            
            <a href="{{ route('admin.users.create') }}" class="inline-flex items-center px-4 py-2 bg-indigo-600 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-indigo-700 active:bg-indigo-900 focus:outline-none focus:border-indigo-900 focus:ring ring-indigo-300 disabled:opacity-25 transition ease-in-out duration-150">
                {{ __('+ Criar Novo Usuário') }}
            </a>

            @include('admin.users.partials.user-table', ['roleTitle' => 'Administradores', 'roleKey' => 'admin', 'users' => $users['admin'] ?? collect()])

            @include('admin.users.partials.user-table', ['roleTitle' => 'Analistas', 'roleKey' => 'analyst', 'users' => $users['analyst'] ?? collect()])

            @include('admin.users.partials.user-table', ['roleTitle' => 'Clientes', 'roleKey' => 'client', 'users' => $users['client'] ?? collect()])

        </div>
    </div>
</x-app-layout>