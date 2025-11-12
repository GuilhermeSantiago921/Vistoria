<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Laudo de Vistoria - ID #{{ $inspection->id }}</title>
    <style>
        /* Reset e Fontes */
        body { font-family: 'Helvetica', Arial, sans-serif; margin: 0; padding: 0; font-size: 10px; line-height: 1.35; color: #222; }
        .container { width: 100%; margin: 0 auto; padding: 22px 28px; box-sizing: border-box; }
        .page-break { page-break-before: always; }

        /* Marca d'água discreta */
        .watermark {
            position: fixed;
            top: 35%;
            left: 50%;
            width: 80%;
            text-align: center;
            z-index: 9999;
            opacity: 0.22; /* increased from 0.12 */
            transform: translateX(-50%) rotate(-18deg);
            pointer-events: none;
        }

        /* Cabeçalho em duas colunas */
        .header { display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #0b5db3; padding-bottom: 10px; margin-bottom: 12px; z-index: 1; }
        .header-left { display:flex; align-items:center; gap:12px; }
        .logo { max-width: 110px; height: auto; }
        .company { text-align: left; }
        .company h1 { margin: 0; font-size: 18px; color: #0b5db3; }
        .company p { margin: 2px 0 0; font-size: 11px; color: #444; }
        .header-right { text-align: right; font-size: 11px; }
        .meta { font-size: 11px; color: #444; }

        /* Veredito */
        .verdict-section { text-align: center; margin: 14px 0; }
        .verdict-box { display: inline-block; padding: 8px 18px; font-size: 15px; font-weight: 700; color: #fff; border-radius: 4px; }
        .status-approved { background-color: #059669; }
        .status-disapproved { background-color: #ef4444; }
        .status-pending { background-color: #f59e0b; color: #111; }

        /* Seções */
        .section { margin-bottom: 14px; border: 1px solid #e6e6e6; border-radius: 4px; overflow: hidden; background: #fff; }
        .section h2 { background: #f6f9ff; color: #0b5db3; font-size: 13px; margin: 0; padding: 8px 12px; border-bottom: 1px solid #e6eef8; }
        .section-content { padding: 10px 12px; }

        /* Dados veiculo */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table td { padding: 6px 8px; font-size: 11px; vertical-align: top; }
        .label { font-weight: 700; width: 22%; color: #334; background: #fafafa; }
        .value { width: 28%; }

        /* Checklist */
        .checklist-table { width: 100%; border-collapse: collapse; margin-top: 6px; }
        .checklist-table th, .checklist-table td { border: 1px solid #e8eef6; padding: 6px 8px; text-align: left; font-size: 10px; }
        .checklist-table th { background: #f7fbff; font-weight: 700; color: #0b5db3; }
        .status-ok { color: #059669; font-weight: 700; }
        .status-nok { color: #dc2626; font-weight: 700; }
        .status-na { color: #6b7280; font-weight: 700; }
        .obs { font-size: 9px; color: #444; }

        /* Notas/parecer */
        .notes-text { padding: 10px; border: 1px solid #f0f0f0; background: #ffffff; border-radius: 4px; min-height: 36px; font-size: 11px; }

        /* Fotos - grid responsivo para PDF */
        .photos-grid { display: table; width: 100%; border-collapse: collapse; margin-top: 8px; }
        .photo-cell { display: table-cell; width: 50%; padding: 6px; vertical-align: top; text-align: center; }
        .photos-grid img { max-width: 100%; height: auto; border: 1px solid #e2e8f0; border-radius: 4px; object-fit: contain; max-height: 260px; }
        .photo-caption { display:block; margin-top:6px; font-weight:600; font-size:10px; }
        .photo-placeholder { height:160px; display:flex; align-items:center; justify-content:center; border:1px dashed #ccc; color:#777; font-size:10px; }

        /* Assinatura e rodapé */
        .signature { margin-top: 18px; display:flex; justify-content:space-between; gap:20px; }
        .signature .block { width: 48%; text-align:left; }
        .signature .line { border-top:1px solid #bbb; margin-top:42px; width:80%; }

        footer { position: fixed; bottom: 12px; left: 0; right: 0; text-align: center; font-size: 10px; color: #666; }
        .page-number { float: right; font-size: 10px; color: #666; }

        /* Forçar quebras apropriadas */
        .section { page-break-inside: avoid; -webkit-region-break-inside: avoid; }
        .checklist-table tr { page-break-inside: avoid; }

    </style>
</head>
<body>

    <div class="container">

        {{-- Cabeçalho em duas colunas --}}
        <div class="header">
            <div class="header-left">
                <img src="{{ public_path('logo.png') }}" alt="Logo" class="logo">
                <div class="company">
                    <h1>LAUDO DE VISTORIA VEICULAR</h1>
                    <p class="meta">Laudo ID: #{{ $inspection->id }} &nbsp;|&nbsp; Solicitado: {{ optional($inspection->created_at)->format('d/m/Y H:i') ?? 'N/A' }}</p>
                </div>
            </div>
            <div class="header-right">
                <p class="meta"><strong>Solicitante:</strong> {{ optional($inspection->client)->name ?? optional(optional($inspection->vehicle)->user)->name ?? 'N/A' }}</p>
                <p class="meta"><strong>Analista:</strong> {{ optional($inspection->analyst)->name ?? 'Aguardando' }}</p>
                <p class="meta"><strong>Data Emissão:</strong> {{ now()->format('d/m/Y') }}</p>
            </div>
        </div>

        {{-- Veredito --}}
        <div class="verdict-section">
            @php $status = strtolower(trim($inspection->status ?? ''));
                $isApproved = in_array($status, ['approved', 'aprovado', 'conforme', 'ok']);
                $isDisapproved = in_array($status, ['disapproved', 'reprovado', 'reprovada', 'não conforme', 'nao conforme', 'nok']);
            @endphp

            @if($isApproved)
                <div class="verdict-box status-approved">EM CONFORMIDADE</div>
            @elseif($isDisapproved)
                <div class="verdict-box status-disapproved">NÃO CONFORME</div>
            @else
                <div class="verdict-box status-pending">PENDENTE DE ANÁLISE</div>
            @endif
        </div>

        {{-- Dados de Identificação --}}
        <div class="section">
            <h2>DADOS DE IDENTIFICAÇÃO DO VEÍCULO</h2>
            <div class="section-content">
                <table class="data-table">
                    <tr>
                        <td class="label">PLACA</td>
                        <td class="value">{{ optional($inspection->vehicle)->license_plate ?? 'N/A' }}</td>
                        <td class="label">MARCA / MODELO</td>
                        <td class="value">{{ optional($inspection->vehicle)->brand ?? 'N/A' }} / {{ optional($inspection->vehicle)->model ?? 'N/A' }}</td>
                    </tr>
                    <tr>
                        <td class="label">ANO FAB / MODELO</td>
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
                        <td class="label">HODÔMETRO</td>
                        <td class="value">{{ optional($inspection->vehicle)->odometer ? number_format(optional($inspection->vehicle)->odometer, 0, ',', '.') . ' km' : 'N/A' }}</td>
                        <td class="label">LOCAL DA VISTORIA</td>
                        <td class="value">{{ $inspection->location ?? 'N/A' }}</td>
                    </tr>
                </table>
            </div>
        </div>

        {{-- Parecer técnico --}}
        <div class="section">
            <h2>PARECER TÉCNICO FINAL</h2>
            <div class="section-content">
                <p><strong>Analista Responsável:</strong> {{ optional($inspection->analyst)->name ?? 'Aguardando Análise' }}</p>
                <div class="notes-text">{{ $inspection->notes ?? 'Nenhuma observação final registrada.' }}</div>
            </div>
        </div>

        {{-- Checklist --}}
        @if($inspection->details->isNotEmpty())
            <div class="section">
                <h2>DETALHAMENTO DA ANÁLISE</h2>
                <div class="section-content" style="padding:6px 10px;">
                    <table class="checklist-table">
                        <thead>
                            <tr>
                                <th>Item Analisado</th>
                                <th style="width:18%;">Veredito</th>
                                <th>Observações do Analista</th>
                            </tr>
                        </thead>
                        <tbody>
                            @php
                                $identificationItemsList = [
                                    'Numeração do Chassi', 'Numeração do Motor', 'Numeração do Câmbio',
                                    'Etiqueta VIS (Compartimento Motor)', 'Etiqueta VIS (Batente da Porta)',
                                ];
                                $structuralItemsList = [
                                    'Longarina Dianteira Direita','Longarina Dianteira Esquerda','Painel Dianteiro','Painel Traseiro','Teto'
                                ];
                                $identificationDetails = $inspection->details->whereIn('item_name', $identificationItemsList);
                                $structuralDetails = $inspection->details->whereIn('item_name', $structuralItemsList);
                            @endphp

                            @if($identificationDetails->isNotEmpty())
                                <tr><td colspan="3" style="background:#eef6ff;font-weight:700;">ITENS DE IDENTIFICAÇÃO</td></tr>
                                @foreach($identificationDetails as $detail)
                                    @php $s = mb_strtolower(trim($detail->status ?? '')); $cls = 'status-na'; if(in_array($s, ['conforme','ok','aprovado','approved'])) { $cls = 'status-ok'; } elseif(\Illuminate\Support\Str::contains($s, ['não','nao','reprovado','disapproved','nok'])) { $cls = 'status-nok'; } @endphp
                                    <tr>
                                        <td>{{ $detail->item_name }}</td>
                                        <td class="{{ $cls }}">{{ $detail->status ?? '---' }}</td>
                                        <td class="obs">{{ $detail->observation ?? '---' }}</td>
                                    </tr>
                                @endforeach
                            @endif

                            @if($structuralDetails->isNotEmpty())
                                <tr><td colspan="3" style="background:#eef6ff;font-weight:700;">ITENS ESTRUTURAIS</td></tr>
                                @foreach($structuralDetails as $detail)
                                    @php $s = mb_strtolower(trim($detail->status ?? '')); $cls = 'status-na'; if(in_array($s, ['conforme','ok','aprovado','approved'])) { $cls = 'status-ok'; } elseif(\Illuminate\Support\Str::contains($s, ['não','nao','reprovado','disapproved','nok'])) { $cls = 'status-nok'; } @endphp
                                    <tr>
                                        <td>{{ $detail->item_name }}</td>
                                        <td class="{{ $cls }}">{{ $detail->status ?? '---' }}</td>
                                        <td class="obs">{{ $detail->observation ?? '---' }}</td>
                                    </tr>
                                @endforeach
                            @endif
                        </tbody>
                    </table>
                </div>
            </div>
        @endif

        {{-- Fotos --}}
        <div class="section page-break">
            <h2>REGISTROS FOTOGRÁFICOS</h2>
            <div class="section-content">
                <div class="photos-grid">
                    @php $photos = $inspection->photos; @endphp
                    @foreach($photos->chunk(2) as $chunk)
                        <div style="display:table-row;">
                            @foreach($chunk as $photo)
                                <div class="photo-cell">
                                    @php $photoPath = public_path('storage/' . ($photo->path ?? '')); @endphp
                                    @if($photo->path && file_exists($photoPath))
                                        <img src="{{ $photoPath }}" alt="{{ $photo->label }}">
                                    @else
                                        <div class="photo-placeholder">Imagem não disponível</div>
                                    @endif
                                    <span class="photo-caption">{{ $photo->label ?? 'Foto' }}</span>
                                </div>
                            @endforeach
                            @if ($chunk->count() === 1)
                                <div class="photo-cell"></div>
                            @endif
                        </div>
                    @endforeach
                </div>

                {{-- Bloco de assinatura --}}
                <div class="signature">
                    <div class="block">
                        <div class="line"></div>
                        <div style="margin-top:6px; font-size:11px;">{{ optional($inspection->analyst)->name ?? 'Analista' }}</div>
                        <div style="font-size:10px;color:#666;">CRV / CREA / Identificação</div>
                    </div>

                    <div class="block" style="text-align:right;">
                        <div class="line" style="margin-left:auto"></div>
                        <div style="margin-top:6px; font-size:11px;">Assinatura do Solicitante</div>
                        <div style="font-size:10px;color:#666;">Data: ______________________</div>
                    </div>
                </div>

            </div>
        </div>

    </div>

    {{-- Watermark placed at the end so dompdf draws it above other content --}}
    <div class="watermark">
        <img src="{{ public_path('logo.png') }}" alt="Logo" style="max-width:800px; width:75%; height:auto; opacity:0.25; display:block; margin:0 auto;" />
    </div>    <footer>
        <div style="width:100%; display:flex; justify-content:space-between; align-items:center;">
            <div>Empresa XYZ - Rua Exemplo, 123 - CNPJ 00.000.000/0000-00 - contato@empresa.com</div>
            <div class="page-number">Página <span class="page">1</span></div>
        </div>
    </footer>

</body>
</html>