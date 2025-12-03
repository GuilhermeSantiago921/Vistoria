<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Nova Vistoria') }}
        </h2>
    </x-slot>

    <div class="py-4 sm:py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-4 sm:p-6 bg-white border-b border-gray-200">
                    
                    {{-- Exibir mensagens de erro --}}
                    @if ($errors->any())
                        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                            <strong class="font-bold">Erro!</strong>
                            <ul class="mt-2 list-disc list-inside">
                                @foreach ($errors->all() as $error)
                                    <li>{{ $error }}</li>
                                @endforeach
                            </ul>
                        </div>
                    @endif
                    
                    @if (session('error'))
                        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                            <strong class="font-bold">Erro!</strong>
                            <span>{{ session('error') }}</span>
                        </div>
                    @endif
                    
                    @if (session('success'))
                        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                            <strong class="font-bold">Sucesso!</strong>
                            <span>{{ session('success') }}</span>
                        </div>
                    @endif
                    
                    <form method="POST" action="{{ route('inspections.store') }}" enctype="multipart/form-data" 
                          x-data="{ loading: false, photos: {} }"
                          @submit="loading = true">
                        @csrf

                        <h4 class="text-lg font-bold mb-4">Dados do Veículo</h4>
                        
                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700 mb-2" for="license_plate">Placa do Veículo</label>
                            <input 
                                id="license_plate" 
                                class="input-mobile border-gray-300 focus:border-blue-500 focus:ring-blue-500 rounded-md shadow-sm w-full" 
                                type="text" 
                                name="license_plate" 
                                value="{{ old('license_plate') }}"
                                required 
                                autofocus
                                style="text-transform: uppercase" 
                                oninput="this.value = this.value.toUpperCase()"
                                placeholder="ABC-1234 ou ABC1D23"
                            />
                            @error('license_plate')
                                <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                            @enderror
                        </div>
                        
                        <div class="mt-6 sm:mt-8">
                            <h4 class="text-lg font-bold mb-2">Fotos do Veículo</h4>
                            <p class="text-sm text-gray-600 mb-4">Toque para abrir a câmera (10 fotos obrigatórias)</p>
                        </div>
                        
                        <!-- Upload Grid -->
                        <div class="upload-grid">
                            @php
                            $photos = [
                                ['id' => 'front_photo', 'label' => '1. Frente'],
                                ['id' => 'back_photo', 'label' => '2. Traseira'],
                                ['id' => 'right_side_photo', 'label' => '3. Lateral Direita'],
                                ['id' => 'left_side_photo', 'label' => '4. Lateral Esquerda'],
                                ['id' => 'right_window_engraving_photo', 'label' => '5. Vidro Dir. (Gravação)'],
                                ['id' => 'left_window_engraving_photo', 'label' => '6. Vidro Esq. (Gravação)'],
                                ['id' => 'chassis_engraving_photo', 'label' => '7. Chassi (Gravação)'],
                                ['id' => 'eta_photo', 'label' => '8. ETA'],
                                ['id' => 'odometer_photo', 'label' => '9. Hodômetro'],
                                ['id' => 'engine_photo', 'label' => '10. Motor']
                            ];
                            @endphp
                            
                            @foreach($photos as $photo)
                            <div class="upload-item">
                                <input 
                                    type="file" 
                                    id="{{ $photo['id'] }}" 
                                    name="{{ $photo['id'] }}" 
                                    accept="image/*" 
                                    capture="environment"
                                    required
                                    class="hidden"
                                    @change="
                                        const file = $event.target.files[0];
                                        if (file) {
                                            const reader = new FileReader();
                                            reader.onload = (e) => { photos['{{ $photo['id'] }}'] = e.target.result; };
                                            reader.readAsDataURL(file);
                                        }
                                    "
                                />
                                <label for="{{ $photo['id'] }}" class="upload-label">
                                    <template x-if="photos['{{ $photo['id'] }}']">
                                        <img :src="photos['{{ $photo['id'] }}']" class="upload-preview" alt="Preview">
                                    </template>
                                    <template x-if="!photos['{{ $photo['id'] }}']">
                                        <div class="flex flex-col items-center">
                                            <svg class="w-8 h-8 sm:w-10 sm:h-10 text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"/>
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"/>
                                            </svg>
                                            <span class="text-xs sm:text-sm font-medium text-gray-700 text-center px-1">{{ $photo['label'] }}</span>
                                        </div>
                                    </template>
                                </label>
                            </div>
                            @endforeach
                        </div>

                        <div class="flex items-center justify-end mt-6 sm:mt-8">
                            <button type="submit" class="btn-mobile btn-primary-mobile" :disabled="loading">
                                <span x-show="!loading">{{ __('Enviar Vistoria') }}</span>
                                <span x-show="loading" class="flex items-center">
                                    <span class="spinner mr-2"></span>
                                    Enviando...
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>