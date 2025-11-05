<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Nova Vistoria') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200">
                    <form method="POST" action="{{ route('inspections.store') }}" enctype="multipart/form-data">
                        @csrf

                        <h4 class="text-lg font-bold mb-4">Dados do Veículo</h4>
                        
                        <div class="mt-4">
                            <x-text-input 
    id="license_plate" 
    class="block mt-1 w-full" 
    type="text" 
    name="license_plate" 
    required 
    autofocus
    style="text-transform: uppercase" 
    oninput="this.value = this.value.toUpperCase()"
/>
                        </div>
                        
                        <div class="mt-8">
                            <h4 class="text-lg font-bold mb-2">Envio de Fotos (10 Pontos de Checagem)</h4>
                            <p class="text-sm text-gray-500 mb-4">Clique no campo para abrir a câmera e tire a foto diretamente.</p>
                        </div>
                        
                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="front_photo">1. Frente do Veículo</label>
                            <x-text-input id="front_photo" class="block mt-1 w-full" type="file" name="front_photo" accept="image/*" capture="camera" required />
                        </div>
                        
                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="back_photo">2. Traseira do Veículo</label>
                            <x-text-input id="back_photo" class="block mt-1 w-full" type="file" name="back_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="right_side_photo">3. Lateral Direita</label>
                            <x-text-input id="right_side_photo" class="block mt-1 w-full" type="file" name="right_side_photo" accept="image/*" capture="camera" required />
                        </div>
                        
                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="left_side_photo">4. Lateral Esquerda</label>
                            <x-text-input id="left_side_photo" class="block mt-1 w-full" type="file" name="left_side_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="right_window_engraving_photo">5. Vidro Lateral Direita (Gravação)</label>
                            <x-text-input id="right_window_engraving_photo" class="block mt-1 w-full" type="file" name="right_window_engraving_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="left_window_engraving_photo">6. Vidro Lateral Esquerda (Gravação)</label>
                            <x-text-input id="left_window_engraving_photo" class="block mt-1 w-full" type="file" name="left_window_engraving_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="chassis_engraving_photo">7. Gravação do Chassi</label>
                            <x-text-input id="chassis_engraving_photo" class="block mt-1 w-full" type="file" name="chassis_engraving_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="eta_photo">8. ETA (Etiqueta de Identificação)</label>
                            <x-text-input id="eta_photo" class="block mt-1 w-full" type="file" name="eta_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="odometer_photo">9. Hodômetro (Quilometragem)</label>
                            <x-text-input id="odometer_photo" class="block mt-1 w-full" type="file" name="odometer_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="mt-4">
                            <label class="block font-medium text-sm text-gray-700" for="engine_photo">10. Motor do Carro</label>
                            <x-text-input id="engine_photo" class="block mt-1 w-full" type="file" name="engine_photo" accept="image/*" capture="camera" required />
                        </div>

                        <div class="flex items-center justify-end mt-4">
                            <x-primary-button>
                                {{ __('Enviar Vistoria') }}
                            </x-primary-button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>