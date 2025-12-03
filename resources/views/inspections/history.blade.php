<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            {{ __('Meus Laudos') }}
        </h2>
    </x-slot>

    <div class="py-4 sm:py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-4 sm:p-6 bg-white border-b border-gray-200">
                    <h3 class="text-lg font-bold mb-4">Histórico de Vistorias</h3>
                    
                    @if($inspections->isEmpty())
                        <div class="card-mobile text-center py-8">
                            <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                            </svg>
                            <p class="text-gray-600">Você ainda não enviou nenhuma vistoria.</p>
                            <a href="{{ route('inspections.create') }}" class="btn-mobile btn-primary-mobile mt-4 inline-flex">
                                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                                </svg>
                                Nova Vistoria
                            </a>
                        </div>
                    @else
                        <div class="space-y-4">
                            @foreach($inspections as $inspection)
                                <div class="card-mobile card-mobile-hover">
                                    <div class="flex justify-between items-start mb-3">
                                        <div>
                                            <p class="text-lg font-bold text-gray-900">{{ $inspection->vehicle->license_plate }}</p>
                                            <p class="text-xs text-gray-500 mt-1">{{ $inspection->created_at->format('d/m/Y H:i') }}</p>
                                        </div>
                                        <span class="badge-mobile 
                                            @if($inspection->status === 'approved') badge-success-mobile
                                            @elseif($inspection->status === 'disapproved') badge-danger-mobile
                                            @else badge-warning-mobile
                                            @endif">
                                            @if($inspection->status === 'approved')
                                                Aprovado
                                            @elseif($inspection->status === 'disapproved')
                                                Reprovado
                                            @else
                                                Pendente
                                            @endif
                                        </span>
                                    </div>
                                    
                                    @if($inspection->notes)
                                        <div class="bg-gray-50 p-3 rounded-lg mb-3">
                                            <p class="text-xs font-semibold text-gray-700 mb-1">Anotações do Mesário:</p>
                                            <p class="text-sm text-gray-600">{{ $inspection->notes }}</p>
                                        </div>
                                    @endif

                                    @if($inspection->status !== 'pending')
                                        <a href="{{ route('report.inspection.pdf', $inspection) }}" 
                                           class="btn-mobile btn-secondary-mobile w-full text-center inline-flex items-center justify-center touch-feedback">
                                            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                                            </svg>
                                            Gerar PDF
                                        </a>
                                    @endif
                                </div>
                            @endforeach
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</x-app-layout>