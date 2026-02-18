<div class="bg-white overflow-hidden shadow-sm sm:rounded-lg mt-6">
    <div class="p-6 bg-white border-b border-gray-200">
        <h3 class="text-xl font-bold mb-4">{{ $roleTitle }} ({{ $users->count() }})</h3>

        @if($users->isEmpty())
            <p class="text-gray-500">Nenhum {{ strtolower($roleTitle) }} registrado no sistema.</p>
        @else
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead>
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">E-mail</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status de Crédito</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Registro</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        @foreach($users as $user)
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap">{{ $user->name }}</td>
                                <td class="px-6 py-4 whitespace-nowrap">{{ $user->email }}</td>
                                <td class="px-6 py-4 whitespace-nowrap">
                                    {{-- Se for cliente, mostre os créditos de vistoria --}}
                                    @if($user->role === 'client')
                                        <span class="font-semibold @if($user->inspection_credits > 0) text-green-600 @else text-red-600 @endif">
                                            {{ $user->inspection_credits }} Crédito(s)
                                        </span>
                                    @else
                                        {{ __('N/A') }}
                                    @endif
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap">{{ $user->created_at->format('d/m/Y') }}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-3">
                                    <a href="{{ route('admin.users.show', $user->id) }}" class="text-indigo-600 hover:text-indigo-900">
                                        Ver Perfil
                                    </a>
                                    
                                    @if($user->id !== auth()->id())
                                        <form action="{{ route('admin.users.destroy', $user->id) }}" method="POST" class="inline-block" onsubmit="return confirm('⚠️ Tem certeza que deseja excluir o usuário {{ $user->name }}?\n\nEsta ação não pode ser desfeita e irá remover:\n• Todos os veículos cadastrados\n• Todas as vistorias realizadas\n• Todas as fotos e documentos\n\nDeseja continuar?');">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="text-red-600 hover:text-red-900 font-medium">
                                                Excluir
                                            </button>
                                        </form>
                                    @else
                                        <span class="text-gray-400 italic text-xs">(Você)</span>
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