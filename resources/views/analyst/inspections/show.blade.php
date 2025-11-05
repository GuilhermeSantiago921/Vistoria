<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Análise de Vistoria: ') . $inspection->vehicle->license_plate }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="space-y-6">

                {{-- Bloco de Mensagens de Feedback --}}
                @if (session('success'))
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
                        <span class="block sm:inline">{{ session('success') }}</span>
                    </div>
                @endif
                @if (session('error') || session('warning'))
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                        <span class="block sm:inline">{{ session('error') ?? session('warning') }}</span>
                    </div>
                @endif
                @if ($errors->any())
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                        <strong class="font-bold">Opa!</strong>
                        <span class="block sm:inline">Houve alguns problemas com os dados enviados.</span>
                        <ul>
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif


                {{-- Bloco de Informações do Veículo --}}
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ __('Informações do Veículo') }}</h3>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-gray-700 text-sm">
                        
                        <p><strong>Placa:</strong> {{ $inspection->vehicle->license_plate }}</p>
                        <p><strong>Marca:</strong> {{ $inspection->vehicle->brand }}</p>
                        <p><strong>Modelo:</strong> {{ $inspection->vehicle->model }}</p>
                        <p><strong>Ano:</strong> {{ $inspection->vehicle->year }}</p>
                        
                        <p class="col-span-2"><strong>Chassi (VIN):</strong> {{ $inspection->vehicle->vin ?? 'N/A' }}</p>
                        <p class="col-span-2"><strong>Motor:</strong> {{ $inspection->vehicle->engine_number ?? 'N/A' }}</p>

                        <p class="col-span-4"><strong>Cliente:</strong> {{ $inspection->vehicle->user->name }} ({{ $inspection->vehicle->user->email }})</p>
                    </div>

                    {{-- Botão para Puxar Dados da BIN --}}
                    <div class="mt-6 pt-4 border-t">
                        <form method="POST" action="{{ route('analyst.inspections.pull_data', $inspection) }}" class="inline-block">
                            @csrf
                            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition duration-300 shadow-lg">
                                Puxar/Atualizar Dados da BIN Agregados
                            </button>
                        </form>
                        <p class="mt-2 text-xs text-gray-500">Use este botão para forçar o preenchimento dos dados do Chassi/Motor se estiverem faltando.</p>
                    </div>
                </div>

                {{-- Bloco de Imagens --}}
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ __('Imagens Enviadas') }} ({{ $inspection->photos->count() }})</h3>
                    
                    @if($inspection->photos->isEmpty())
                        <p class="text-red-500">Nenhuma imagem encontrada para esta vistoria.</p>
                    @else
                        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                            @foreach($inspection->photos as $photo)
                                <div class="relative overflow-hidden rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300">
                                    <a href="{{ asset('storage/' . $photo->path) }}" target="_blank" class="block">
                                        <img 
                                            src="{{ asset('storage/' . $photo->path) }}" 
                                            alt="{{ $photo->label ?? 'Foto' }}" 
                                            class="w-full h-32 object-cover cursor-pointer"
                                            loading="lazy"
                                        >
                                    </a>
                                    <p class="text-xs text-gray-600 mt-1 px-2 py-1 text-center bg-gray-50 border-t">
                                        {{-- USA O LABEL SALVO NO BANCO --}}
                                        {{ $photo->label ?? 'Foto da Vistoria' }}
                                    </p>
                                </div>
                            @endforeach
                        </div>
                    @endif
                </div>

                {{-- ========================================================== --}}
                {{-- [BLOCO ATUALIZADO] Ação do Analista e Checklist --}}
                {{-- ========================================================== --}}
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                    <h3 class="text-xl font-bold mb-4 border-b pb-2">{{ __('Ação do Analista') }}</h3>
                    
                    @if($inspection->status === 'pending')
                        {{-- O formulário agora aponta para a rota 'approve' por padrão,
                             mas os botões usarão 'formaction' para decidir o destino.
                             Tudo o que está dentro deste form será enviado. --}}
                        <form method="POST" action="{{ route('analyst.inspections.approve', $inspection) }}" class="space-y-6">
                            @csrf

                            {{-- 
                            Helper para renderizar a tabela do checklist.
                            Isso evita repetir o código HTML.
                            --}}
                            @php
                            // ================== [ A CORREÇÃO ESTÁ AQUI ] ==================
                            // Adicionamos `use ($__env)` para passar o ambiente do Blade
                            // para dentro do escopo desta função anônima.
                            $renderChecklistTable = function ($items, $title, $savedDetails, $startIndex = 0) use ($__env) {
                            // ==============================================================
                            @endphp
                                <h4 class="text-lg font-semibold mt-4 text-gray-800">{{ $title }}</h4>
                                <div class="overflow-x-auto">
                                    <table class="min-w-full divide-y divide-gray-200 border">
                                        <thead class="bg-gray-50">
                                            <tr>
                                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Item</th>
                                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider" style="width: 150px;">Status</th>
                                                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Observação (Opcional)</th>
                                            </tr>
                                        </thead>
                                        <tbody class="bg-white divide-y divide-gray-200">
                                            @foreach($items as $index => $itemName)
                                                @php
                                                    $detail = $savedDetails->get($itemName);
                                                    $currentIndex = $startIndex + $index;
                                                @endphp
                                                <tr>
                                                    <td class="px-4 py-2 whitespace-nowrap text-sm text-gray-700">{{ $itemName }}</td>
                                                    <td class="px-4 py-2">
                                                        <input type="hidden" name="details[{{ $currentIndex }}][item_name]" value="{{ $itemName }}">
                                                        <select name="details[{{ $currentIndex }}][status]" class="block w-full rounded-md border-gray-300 shadow-sm text-sm">
                                                            <option value="Conforme" @if($detail && $detail->status == 'Conforme') selected @endif>Conforme</option>
                                                            <option value="Não Conforme" @if($detail && $detail->status == 'Não Conforme') selected @endif>Não Conforme</option>
                                                            <option value="N/A" @if(($detail && $detail->status == 'N/A') || !$detail) selected @endif>N/A</option>
                                                        </select>
                                                    </td>
                                                    <td class="px-4 py-2">
                                                        <input type="text" name="details[{{ $currentIndex }}][observation]" value="{{ $detail->observation ?? '' }}" class="block w-full rounded-md border-gray-300 shadow-sm text-sm" placeholder="Ex: Risco profundo">
                                                    </td>
                                                </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            @php
                            };
                            @endphp

                            {{-- Renderiza a Tabela de Itens de Identificação --}}
                            {{ $renderChecklistTable($identificationItems, 'Checklist de Identificação', $savedDetails, 0) }}

                            {{-- Renderiza a Tabela de Itens Estruturais --}}
                            {{ $renderChecklistTable($structuralItems, 'Checklist Estrutural', $savedDetails, count($identificationItems)) }}


                            {{-- Campo de Anotações Finais --}}
                            <div class="pt-6 border-t mt-6">
                                <label for="notes" class="block text-sm font-medium text-gray-700">{{ __('Parecer Técnico / Observações Finais') }}</label>
                                <p class="text-xs text-gray-500 mb-2">Este campo é o parecer final que aparecerá em destaque no laudo (ex: "Reprovado por avaria na longarina").</p>
                                <textarea name="notes" id="notes" rows="4" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">{{ $inspection->notes ?? '' }}</textarea>
                            </div>

                            {{-- Botões de Ação --}}
                            <div class="flex space-x-4">
                                {{-- Botão Aprovar (usando a rota approve) --}}
                                <button type="submit" formaction="{{ route('analyst.inspections.approve', $inspection) }}" class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500">
                                    {{ __('Aprovar Vistoria') }}
                                </button>
                                
                                {{-- Botão Reprovar (usando a rota disapprove) --}}
                                <button type="submit" formaction="{{ route('analyst.inspections.disapprove', $inspection) }}" class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500" onclick="return confirm('Tem certeza que deseja reprovar esta vistoria? O cliente receberá a notificação.')">
                                    {{ __('Reprovar Vistoria') }}
                                </button>
                            </div>
                        </form>
                    @else
                        {{-- Se a vistoria já foi finalizada --}}
                        <div class="p-4 bg-gray-100 rounded-md">
                            <p class="font-bold text-lg mb-2">Vistoria Finalizada</p>
                            <p>Status: <span class="font-semibold @if($inspection->status == 'approved') text-green-600 @else text-red-600 @endif">{{ ucfirst($inspection->status) }}</span></p>
                            @if($inspection->analyst)
                                <p>Analisado por: {{ $inspection->analyst->name }}</p>
                            @endif
                            <p>Anotações: {{ $inspection->notes ?? 'Nenhuma anotação.' }}</p>
                        </div>
                        
                        {{-- (Opcional) Mostrar o checklist preenchido --}}
                        @if($inspection->details->isNotEmpty())
                            <h4 class="text-lg font-semibold mt-6 text-gray-800">Resumo do Checklist Submetido</h4>
                            <div class="overflow-x-auto mt-2">
                                <table class="min-w-full divide-y divide-gray-200 border">
                                    <thead class="bg-gray-50">
                                        <tr>
                                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Item</th>
                                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                            <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Observação</th>
                                        </tr>
                                    </thead>
                                    <tbody class="bg-white divide-y divide-gray-200">
                                        @foreach($inspection->details as $detail)
                                            <tr>
                                                <td class="px-4 py-2 text-sm text-gray-700">{{ $detail->item_name }}</td>
                                                <td class="px-4 py-2 text-sm @if($detail->status == 'Conforme') text-green-600 @elseif($detail->status == 'Não Conforme') text-red-600 @endif">
                                                    {{ $detail->status }}
                                                </td>
                                                <td class="px-4 py-2 text-sm text-gray-500">{{ $detail->observation ?? 'N/A' }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        @endif
                    @endif
                </div>

            </div>
        </div>
    </div>
</x-app-layout>