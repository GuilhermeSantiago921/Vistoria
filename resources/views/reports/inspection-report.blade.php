<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Laudo de Vistoria - ID #{{ $inspection->id }}</title>
    <style>
        /* Reset e Fontes */
        body { font-family: 'Helvetica', Arial, sans-serif; margin: 0; padding: 0; font-size: 10px; line-height: 1.3; color: #333; }
        
        /* Layout */
        .container { width: 100%; margin: 0 auto; padding: 25px; }
        .page-break { page-break-before: always; }
        
        /* Cabeçalho */
        .header { text-align: center; border-bottom: 2px solid #004a99; padding-bottom: 10px; }
        .header .logo { max-width: 120px; margin-bottom: 10px; }
        .header h1 { font-size: 20px; color: #004a99; margin: 0; }
        .header p { font-size: 11px; margin: 5px 0 0 0; }
        
        /* Veredito (Status) */
        .verdict-section { text-align: center; margin-top: 15px; margin-bottom: 15px; }
        .verdict-box { display: inline-block; padding: 10px 20px; font-size: 18px; font-weight: bold; color: #fff; border-radius: 5px; }
        .status-approved { background-color: #10b981; }
        .status-disapproved { background-color: #ef4444; }
        .status-pending { background-color: #f59e0b; }

        /* Seções */
        .section { margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; overflow: hidden; }
        .section h2 { background-color: #f4f4f4; color: #004a99; font-size: 13px; margin: 0; padding: 8px 12px; border-bottom: 1px solid #ddd; }
        .section-content { padding: 12px; }
        
        /* Tabela de Dados do Veículo (2 colunas) */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table td { padding: 6px 8px; border-bottom: 1px solid #eee; font-size: 10px; }
        .data-table .label { font-weight: bold; width: 20%; background-color: #f9f9f9; }
        .data-table .value { width: 30%; }

        /* Tabela do Checklist (3 colunas) */
        .checklist-table { width: 100%; border-collapse: collapse; margin-top: 5px; }
        .checklist-table th, .checklist-table td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; }
        .checklist-table th { background-color: #f4f4f4; font-size: 10px; font-weight: bold; }
        .checklist-table .status { font-weight: bold; }
        .checklist-table .status-ok { color: #059669; }
        .checklist-table .status-nok { color: #dc2626; }
        .checklist-table .status-na { color: #6b7280; }
        .checklist-table .obs { font-size: 9px; color: #555; }
        
        /* Parecer Técnico (Notas) */
        .notes-text { padding: 10px; border: 1px solid #eee; background: #fdfdfd; border-radius: 4px; min-height: 30px; }
        
        /* Seção de Fotos */
        .photos-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .photos-table td { padding: 5px; vertical-align: top; width: 50%; text-align: center; }
        .photos-table img { max-width: 100%; height: auto; border: 1px solid #ddd; border-radius: 3px; }
        .photo-caption { font-weight: bold; font-size: 10px; margin-top: 5px; display: block; }

        /* Melhorias para geração de PDF e prevenção de quebras */
        .section { page-break-inside: avoid; -webkit-region-break-inside: avoid; }
        .checklist-table tr { page-break-inside: avoid; }
        .photos-table img { max-height: 220px; object-fit: contain; }
        .photo-placeholder { height:120px; display:flex; align-items:center; justify-content:center; border:1px dashed #ccc; color:#777; font-size:10px; }

    </style>
</head>
<body>
    <div class="container">
        
        {{-- ============================== CABEÇALHO ============================== --}}
        <div class="header">
            <img src="{{ public_path('logo.png') }}" alt="Logo" class="logo">
            <h1>LAUDO DE VISTORIA VEICULAR</h1>
            <p>Laudo ID: #{{ $inspection->id }} | Data da Solicitação: {{ optional($inspection->created_at)->format('d/m/Y H:i') ?? 'N/A' }}</p>
        </div>

        {{-- ============================== VEREDITO FINAL [ATUALIZADO] ============================== --}}
        <div class="verdict-section">
            @php $status = strtolower(trim($inspection->status ?? ''));
                // aceita valores em inglês e português
                $isApproved = in_array($status, ['approved', 'aprovado', 'conforme', 'ok']);
                $isDisapproved = in_array($status, ['disapproved', 'reprovado', 'reprovada', 'não conforme', 'nao conforme', 'reprovado', 'reprovada', 'nok']);
            @endphp

            @if($isApproved)
                <div class="verdict-box status-approved">EM CONFORMIDADE</div>
            @elseif($isDisapproved)
                <div class="verdict-box status-disapproved">NÃO CONFORME</div>
            @else
                <div class="verdict-box status-pending">PENDENTE DE ANÁLISE</div>
            @endif
        </div>

        {{-- ============================== DADOS DE IDENTIFICAÇÃO ============================== --}}
        <div class="section">
            <h2>DADOS DE IDENTIFICAÇÃO DO VEÍCULO</h2>
            <div class="section-content">
                <table class="data-table">
                    <tr>
                        <td class="label">PLACA</td>
                        <td class="value">{{ optional($inspection->vehicle)->license_plate ?? 'N/A' }}</td>
                        <td class="label">MARCA/MODELO</td>
                        <td class="value">{{ optional($inspection->vehicle)->brand ?? 'N/A' }} / {{ optional($inspection->vehicle)->model ?? 'N/A' }}</td>
                    </tr>
                    <tr>
                        <td class="label">ANO FAB/MODELO</td>
                        <td class="value">{{ optional($inspection->vehicle)->year ?? 'N/A' }}</td>
                        <td class="label">COR / COMB.</td>
                        <td class="value">{{ optional($inspection->vehicle)->color ?? 'N/A' }} / {{ optional($inspection->vehicle)->fuel_type ?? 'N/A' }}</td>
                    </tr>
                    <tr>
                        <td class="label">CHASSI (VIN)</td>
                        <td class="value">{{ optional($inspection->vehicle)->vin ?? 'Não Informado' }}</td>
                        <td class="label">MOTOR</td>
                        <td class="value">{{ optional($inspection->vehicle)->engine_number ?? 'Não Informado' }}</td>
                    </tr>
                     <tr>
                        <td class="label">SOLICITANTE</td>
                        <td class="value">{{ optional($inspection->client)->name ?? optional(optional($inspection->vehicle)->user)->name ?? 'N/A' }}</td>
                        <td class="label">HODÔMETRO</td>
                        <td class="value">{{ optional($inspection->vehicle)->odometer ? number_format(optional($inspection->vehicle)->odometer, 0, ',', '.') . ' km' : 'N/A' }}</td>
                    </tr>
                </table>
            </div>
        </div>

        {{-- ============================== PARECER TÉCNICO (NOTAS DO ANALISTA) ============================== --}}
        <div class="section">
            <h2>PARECER TÉCNICO FINAL</h2>
            <div class="section-content">
                <p><strong>Analista Responsável:</strong> {{ optional($inspection->analyst)->name ?? 'Aguardando Análise' }}</p>
                <div class="notes-text">
                    {{ $inspection->notes ?? 'Nenhuma observação final registrada.' }}
                </div>
            </div>
        </div>

        {{-- ============================== CHECKLIST DE ITENS ============================== --}}
        @if($inspection->details->isNotEmpty())
            <div class="section">
                <h2>DETALHAMENTO DA ANÁLISE</h2>
                <div class="section-content" style="padding: 0;">
                    <table class="checklist-table">
                        <thead>
                            <tr>
                                <th>Item Analisado</th>
                                <th style="width: 18%;">Veredito</th>
                                <th>Observações do Analista</th>
                            </tr>
                        </thead>
                        <tbody>
                            {{-- Separa os itens em grupos para exibição --}}
                            @php
                                // Define as listas aqui para garantir que existam
                                $identificationItemsList = [
                                    'Numeração do Chassi', 'Numeração do Motor', 'Numeração do Câmbio',
                                    'Etiqueta VIS (Compartimento Motor)', 'Etiqueta VIS (Batente da Porta)',
                                    'Vidro Dianteiro (Para-brisa)', 'Vidro Porta Esquerda Dianteira',
                                    'Vidro Porta Esquerda Traseira', 'Vidro Porta Direita Dianteira',
                                    'Vidro Porta Direita Traseira', 'Vidro Traseiro (Vigia)',
                                ];
                                $structuralItemsList = [
                                    'Longarina Dianteira Direita', 'Longarina Dianteira Esquerda',
                                    'Painel Dianteiro', 'Painel Traseiro', 'Caixa de Roda Dianteira Direita',
                                    'Caixa de Roda Dianteira Esquerda', 'Coluna Dianteira Direita',
                                    'Coluna Dianteira Esquerda', 'Coluna Central Direita', 'Coluna Central Esquerda',
                                    'Coluna Traseira Direita', 'Coluna Traseira Esquerda', 'Teto',
                                ];

                                $identificationDetails = $inspection->details->whereIn('item_name', $identificationItemsList);
                                $structuralDetails = $inspection->details->whereIn('item_name', $structuralItemsList);
                            @endphp

                            {{-- Itens de Identificação --}}
                            @if($identificationDetails->isNotEmpty())
                                <tr><td colspan="3" style="background: #eef; font-weight: bold;">ITENS DE IDENTIFICAÇÃO</td></tr>
                                @foreach($identificationDetails as $detail)
                                    @php
                                        $s = mb_strtolower(trim($detail->status ?? ''));
                                        $cls = 'status-na';
                                        if(in_array($s, ['conforme','ok','aprovado','approved'])) { $cls = 'status-ok'; }
                                        elseif(\Illuminate\Support\Str::contains($s, ['não','nao','não conforme','nao conforme','reprovado','disapproved','nok'])) { $cls = 'status-nok'; }
                                    @endphp
                                    <tr>
                                        <td>{{ $detail->item_name }}</td>
                                        <td class="status {{ $cls }}">{{ $detail->status ?? '---' }}</td>
                                        <td class="obs">{{ $detail->observation ?? '---' }}</td>
                                    </tr>
                                @endforeach
                            @endif

                            {{-- Itens Estruturais --}}
                            @if($structuralDetails->isNotEmpty())
                                <tr><td colspan="3" style="background: #eef; font-weight: bold;">ITENS ESTRUTURAIS</td></tr>
                                @foreach($structuralDetails as $detail)
                                    @php
                                        $s = mb_strtolower(trim($detail->status ?? ''));
                                        $cls = 'status-na';
                                        if(in_array($s, ['conforme','ok','aprovado','approved'])) { $cls = 'status-ok'; }
                                        elseif(\Illuminate\Support\Str::contains($s, ['não','nao','não conforme','nao conforme','reprovado','disapproved','nok'])) { $cls = 'status-nok'; }
                                    @endphp
                                    <tr>
                                        <td>{{ $detail->item_name }}</td>
                                        <td class="status {{ $cls }}">{{ $detail->status ?? '---' }}</td>
                                        <td class="obs">{{ $detail->observation ?? '---' }}</td>
                                    </tr>
                                @endforeach
                            @endif
                        </tbody>
                    </table>
                </div>
            </div>
        @endif

        {{-- ============================== REGISTROS FOTOGRÁFICOS [ATUALIZADO] ============================== --}}
        <div class="section page-break">
            <h2>REGISTROS FOTOGRÁFICOS</h2>
            <div class="section-content">
                <table class="photos-table">
                    @php
                        // Carrega todas as fotos e as divide em pares
                        $photos = $inspection->photos;
                    @endphp
                    
                    {{-- Mostra TODAS as fotos em pares --}}
                    @foreach($photos->chunk(2) as $chunk)
                        <tr>
                            @foreach($chunk as $photo)
                                <td class="photo-cell">
                                    @php $photoPath = public_path('storage/' . ($photo->path ?? '')); @endphp
                                    @if($photo->path && file_exists($photoPath))
                                        <img src="{{ $photoPath }}" alt="{{ $photo->label }}">
                                    @else
                                        <div class="photo-placeholder">Imagem não disponível</div>
                                    @endif
                                    <span class="photo-caption">{{ $photo->label ?? 'Foto' }}</span>
                                </td>
                            @endforeach
                            
                            {{-- Preenche célula vazia se o número for ímpar --}}
                            @if ($chunk->count() === 1)
                                <td></td>
                            @endif
                        </tr>
                    @endforeach
                </table>
            </div>
        </div>

    </div>
</body>
</html>