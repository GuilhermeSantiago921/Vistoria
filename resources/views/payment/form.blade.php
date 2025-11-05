<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Pagamento da Vistoria') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-md mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 bg-white border-b border-gray-200 text-center">
                    <p class="text-lg font-bold mb-4">Valor: R$ 59,90</p>
                    <p class="mb-4">Confirme o pagamento para liberar o envio da vistoria.</p>
                    
                    <form method="POST" action="{{ route('payment.process') }}">
                        @csrf
                        <button type="submit" class="w-full bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline">
                            Confirmar Pagamento (Simulado)
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>