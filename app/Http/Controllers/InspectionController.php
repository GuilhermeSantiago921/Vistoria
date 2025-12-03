<?php

namespace App\Http\Controllers;

use App\Models\Inspection;
use App\Models\InspectionDetail; // <-- ADICIONADO
use App\Models\InspectionPhoto;
use App\Models\Vehicle;
use App\Models\User;
use App\Notifications\InspectionSubmitted;
use App\Notifications\InspectionApproved;
use App\Notifications\InspectionDisapproved;
use App\Notifications\NewInspectionReceived;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB; // <-- ADICIONADO
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;

class InspectionController extends Controller
{
    /**
     * Exibe o formulário para o cliente enviar uma nova vistoria.
     *
     * @return \Illuminate\View\View
     */
    public function create()
    {
        return view('inspections.create');
    }

    /**
     * Processa o formulário de vistoria, auto-preenche com dados externos e armazena.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(Request $request)
    {
        \Log::info('=== INÍCIO STORE INSPECTION ===');
        \Log::info('Dados recebidos:', [
            'license_plate' => $request->input('license_plate'),
            'has_files' => $request->hasFile('front_photo'),
            'all_inputs' => array_keys($request->all()),
            'files' => array_keys($request->allFiles()),
        ]);
        
        // VERIFICAR SE O USUÁRIO TEM CRÉDITOS
        if (!Auth::user()->hasCredits()) {
            \Log::warning('Usuário sem créditos', ['user_id' => Auth::id()]);
            return redirect()->back()->with('error', 'Você não possui créditos suficientes. Entre em contato com o administrador.');
        }
        
        \Log::info('Usuário tem créditos', ['user_id' => Auth::id(), 'credits' => Auth::user()->inspection_credits]);
        
        // 1. VALIDAÇÃO DOS DADOS (SOMENTE PLACA E 10 FOTOS)
        try {
            $request->validate([
                'license_plate' => 'required|string|max:20|regex:/^[A-Z]{3}-?[0-9][A-Z0-9][0-9]{2}$/',
                'front_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'back_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'right_side_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'left_side_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'right_window_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'left_window_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'chassis_engraving_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'eta_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'odometer_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
                'engine_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',
            ], [
                'license_plate.regex' => 'Formato de placa inválido. Use o formato ABC1D23 ou ABC-1234.',
                'license_plate.required' => 'A placa do veículo é obrigatória.',
                '*.required' => 'Todas as 10 fotos são obrigatórias.',
                '*.mimes' => 'Apenas arquivos JPG, JPEG e PNG são permitidos.',
                '*.max' => 'O tamanho máximo permitido é 5MB por foto.',
                '*.image' => 'O arquivo deve ser uma imagem válida.',
            ]);
            \Log::info('Validação passou com sucesso');
        } catch (\Illuminate\Validation\ValidationException $e) {
            \Log::error('Erro de validação:', ['errors' => $e->errors()]);
            throw $e;
        }

        // 2. BUSCA DE INFORMAÇÕES DO VEÍCULO NA BIN EXTERNA (SQL Server)
        $placa = strtoupper($request->license_plate);
        $placa = str_replace('-', '', $placa); // Remove hífens da placa
        $dados_agregados = null;

        try {
            // Verifica se a conexão SQL Server está configurada
            if (config('database.connections.sqlsrv_agregados')) {
                // Lógica de busca externa (Query atualizada para incluir Renavam, Cilindradas, etc.)
                $query = "
                    SELECT TOP 1
                        A.NR_Chassi, A.NR_Motor, A.NR_AnoFabricacao, A.NR_AnoModelo, C.NM_MarcaModelo,
                        I.NM_CorVeiculo, D.NM_Combustivel,
                        A.NR_Renavam, A.NR_Cilindradas, A.NR_PesoBrutoTotal
                    FROM VeiculosAgregados.dbo.Agregados2020 A
                    LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C ON TRY_CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
                    LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D ON TRY_CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
                    LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I ON TRY_CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
                    WHERE (NR_PlacaModeloAntigo = ? OR NR_PlacaModeloNovo = ?)
                    AND A.NR_AnoFabricacao IS NOT NULL
                ";
                
                $resultado = DB::connection('sqlsrv_agregados')->select($query, [$placa, $placa]);
                
                if (!empty($resultado)) {
                    $dados_agregados = (array) $resultado[0];
                }
            }

        } catch (\Exception $e) {
            \Log::warning('Erro ao buscar dados agregados (não crítico): ' . $e->getMessage());
            // Continua sem dados agregados
        }

                // 3. TRANSAÇÃO DE SALVAMENTO LOCAL E DEDUÇÃO DE CRÉDITO
        try {
            \Log::info('Iniciando transação de salvamento');
            
            DB::transaction(function () use ($request, $dados_agregados) {
                \Log::info('Dentro da transação');
                
                $vehicleData = [];
                
                // Auto-Preenchimento com os dados agregados
                if ($dados_agregados) {
                    \Log::info('Usando dados agregados');
                    $vehicleData['vin'] = $dados_agregados['NR_Chassi'] ?? null;
                    $vehicleData['engine_number'] = $dados_agregados['NR_Motor'] ?? null;
                    $vehicleData['brand'] = $dados_agregados['NM_MarcaModelo'] ?? null;
                    $vehicleData['model'] = $dados_agregados['NM_MarcaModelo'] ?? null;
                    $vehicleData['color'] = $dados_agregados['NM_CorVeiculo'] ?? null;
                    $vehicleData['fuel_type'] = $dados_agregados['NM_Combustivel'] ?? null;
                    $vehicleData['year'] = $dados_agregados['NR_AnoFabricacao'] ?? null;
                } else {
                    \Log::info('Sem dados agregados, usando valores padrão');
                }
                
                // Garante valores de fallback para colunas obrigatórias
                $finalVehicleData = [
                    'brand' => $vehicleData['brand'] ?? 'NAO_INFORMADO',
                    'model' => $vehicleData['model'] ?? 'NAO_INFORMADO',
                    'year' => $vehicleData['year'] ?? 0,
                    'vin' => $vehicleData['vin'] ?? null,
                    'engine_number' => $vehicleData['engine_number'] ?? null,
                    'color' => $vehicleData['color'] ?? null,
                    'fuel_type' => $vehicleData['fuel_type'] ?? null,
                ];

                \Log::info('Criando/atualizando veículo');
                // Criação/Atualização do Veículo Local (com os dados preenchidos)
                $vehicle = Vehicle::firstOrCreate(
                    ['user_id' => Auth::id(), 'license_plate' => $request->license_plate],
                    $finalVehicleData
                );
                \Log::info('Veículo criado/atualizado', ['vehicle_id' => $vehicle->id]);

                \Log::info('Criando inspeção');
                $inspection = Inspection::create([
                    'vehicle_id' => $vehicle->id,
                    'user_id' => Auth::id(), // <-- Adicionado (assumindo que o usuário logado é o cliente)
                    'status' => 'pending',
                ]);
                \Log::info('Inspeção criada', ['inspection_id' => $inspection->id]);

                // Mapeamento e Salvamento das 10 fotos
                $photoFields = [
                    'front_photo' => 'Frente do Veiculo',
                    'back_photo' => 'Traseira do Veiculo',
                    'right_side_photo' => 'Lateral Direita',
                    'left_side_photo' => 'Lateral Esquerda',
                    'right_window_engraving_photo' => 'Vidro Lateral Direita Gravacao',
                    'left_window_engraving_photo' => 'Vidro Lateral Esquerda Gravacao',
                    'chassis_engraving_photo' => 'Gravacao do Chassi',
                    'eta_photo' => 'Etiqueta de Identificacao', // <-- Label da Etiqueta
                    'odometer_photo' => 'Hodometro',
                    'engine_photo' => 'Motor do Carro',
                ];

                \Log::info('Salvando fotos');
                foreach ($photoFields as $field => $label) {
                    if ($request->hasFile($field)) {
                        \Log::info("Salvando foto: $field");
                        $path = $request->file($field)->storeAs(
                            'inspections/' . $inspection->id,
                            Str::slug($label) . '.' . $request->file($field)->extension(),
                            'public'
                        );
        
                        InspectionPhoto::create([
                            'inspection_id' => $inspection->id,
                            'path' => $path,
                            'label' => $label, // <-- [ATUALIZADO] Salva o label no banco
                        ]);
                        \Log::info("Foto salva: $field -> $path");
                    } else {
                        \Log::warning("Foto não encontrada: $field");
                    }
                }
                
                \Log::info('Consumindo crédito');
                // Dedução de Crédito
                $user = Auth::user();
                $user->consumeCredit();
                \Log::info('Crédito consumido', ['credits_remaining' => $user->inspection_credits]);

                \Log::info('Enviando notificações');
                // Enviar notificação para o cliente confirmando o envio
                $user->notify(new InspectionSubmitted($inspection));

                // Enviar notificação para todos os mesários sobre nova vistoria
                $analysts = User::where('role', 'analyst')->get();
                Notification::send($analysts, new NewInspectionReceived($inspection));
                \Log::info('Notificações enviadas');
            });

            \Log::info('=== STORE CONCLUÍDO COM SUCESSO ===');
            return redirect()->route('dashboard')->with('success', 'Vistoria enviada com sucesso! Um mesário irá revisar em breve.');
            
        } catch (\Exception $e) {
            \Log::error('=== ERRO NO STORE ===');
            \Log::error('Erro ao salvar vistoria: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            return redirect()->back()->with('error', 'Erro ao enviar vistoria: ' . $e->getMessage())->withInput();
        }
    }

    /**
     * Exibe o dashboard do mesário com métricas e lista de ação rápida.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $totalInspections = Inspection::count();
        $pendingInspections = Inspection::where('status', 'pending')->count();
        $approvedInspections = Inspection::where('status', 'approved')->count();
        $disapprovedInspections = Inspection::where('status', 'disapproved')->count();
        
        $recentPending = Inspection::with('vehicle')->where('status', 'pending')->latest()->limit(5)->get();

        return view('analyst.dashboard', compact(
            'recentPending', 
            'totalInspections', 
            'pendingInspections', 
            'approvedInspections', 
            'disapprovedInspections'
        ));
    }

    /**
     * Exibe a lista de todas as vistorias (pendentes, aprovadas e reprovadas).
     *
     * @return \Illuminate\View\View
     */
    public function all()
    {
        $inspections = Inspection::with('vehicle.user', 'analyst')->latest()->get();

        return view('analyst.inspections.all', compact('inspections'));
    }

    /**
     * Exibe os detalhes de uma vistoria específica para análise (analyst.inspections.show).
     *
     * @param  \App\Models\Inspection  $inspection
     * @return \Illuminate\View\View
     */
    public function show(Inspection $inspection)
    {
        // Carrega os relacionamentos, incluindo os 'details' já salvos
        $inspection->load(['vehicle.user', 'photos', 'details']);

        // Lista de ITENS DE IDENTIFICAÇÃO (baseado no seu PDF de exemplo)
        $identificationItems = [
            'Numeração do Chassi',
            'Numeração do Motor',
            'Numeração do Câmbio',
            'Etiqueta VIS (Compartimento Motor)',
            'Etiqueta VIS (Batente da Porta)', // <-- A "Etiqueta ETA" que você pediu
            'Vidro Dianteiro (Para-brisa)',
            'Vidro Porta Esquerda Dianteira',
            'Vidro Porta Esquerda Traseira',
            'Vidro Porta Direita Dianteira',
            'Vidro Porta Direita Traseira',
            'Vidro Traseiro (Vigia)',
        ];

        // Lista de ITENS ESTRUTURAIS (como discutido)
        $structuralItems = [
            'Longarina Dianteira Direita',
            'Longarina Dianteira Esquerda',
            'Painel Dianteiro',
            'Painel Traseiro',
            'Caixa de Roda Dianteira Direita',
            'Caixa de Roda Dianteira Esquerda',
            'Coluna Dianteira Direita',
            'Coluna Dianteira Esquerda',
            'Coluna Central Direita',
            'Coluna Central Esquerda',
            'Coluna Traseira Direita',
            'Coluna Traseira Esquerda',
            'Teto',
        ];

        // Mapeia os detalhes já salvos para preencher o formulário
        $savedDetails = $inspection->details->keyBy('item_name');

        return view('analyst.inspections.show', compact(
            'inspection',
            'identificationItems',
            'structuralItems',
            'savedDetails'
        ));
    }

    /**
     * Rota de diagnóstico: testa a conexão com a base sqlsrv_agregados (para depuração).
     */
    public function testConnection()
    {
        try {
            // tenta obter o PDO da conexão nomeada
            DB::connection('sqlsrv_agregados')->getPdo();
            return response()->json(['ok' => true, 'message' => 'Conexão com sqlsrv_agregados estabelecida com sucesso.']);
        } catch (\Exception $e) {
            \Log::error('testConnection: ' . $e->getMessage());
            return response()->json(['ok' => false, 'message' => 'Falha ao conectar: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Puxa dados do veículo da BIN Agregados e atualiza o registro local (Ação Manual do Mesário).
     * Atualizado: usa bindings para evitar injeção, corrige precedência do WHERE e adiciona logs.
     *
     * @param  \App\Models\Inspection  $inspection
     * @return \Illuminate\Http\RedirectResponse
     */
    public function pullAggregates(Inspection $inspection)
    {
        $placa = strtoupper($inspection->vehicle->license_plate ?? '');
        $placa = str_replace('-', '', $placa);

        try {
            \Log::info('=== INÍCIO PULL AGGREGATES ===', [
                'inspection_id' => $inspection->id, 
                'placa' => $placa,
                'vehicle_id' => $inspection->vehicle->id ?? null
            ]);

            // Testar conexão primeiro
            try {
                DB::connection('sqlsrv_agregados')->getPdo();
                \Log::info('pullAggregates: conexão estabelecida com sucesso');
            } catch (\Exception $connError) {
                \Log::error('pullAggregates: falha ao conectar', [
                    'error' => $connError->getMessage(),
                    'code' => $connError->getCode()
                ]);
                return back()->with('error', 'Erro ao conectar com a base de agregados. Por favor, contate o suporte técnico.');
            }

            // Consulta reduzida e segura (somente colunas que existem na tabela)
            $query = "
                SELECT TOP 1
                    A.NR_Chassi, A.NR_Motor, A.NR_AnoFabricacao, A.NR_AnoModelo,
                    C.NM_MarcaModelo,
                    I.NM_CorVeiculo,
                    D.NM_Combustivel
                FROM VeiculosAgregados.dbo.Agregados2020 A
                LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C ON TRY_CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
                LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D ON TRY_CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
                LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I ON TRY_CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
                WHERE (A.NR_PlacaModeloAntigo = ? OR A.NR_PlacaModeloNovo = ?)
                AND A.NR_AnoFabricacao IS NOT NULL
            ";

            \Log::info('pullAggregates: executando query', ['placa' => $placa]);
            
            $resultado = DB::connection('sqlsrv_agregados')->select($query, [$placa, $placa]);

            \Log::info('pullAggregates: query executada', [
                'count' => count($resultado ?? []),
                'has_results' => !empty($resultado)
            ]);

            if (!empty($resultado)) {
                $dados = (array) $resultado[0];

                \Log::info('pullAggregates: dados encontrados', ['dados' => $dados]);

                $vehicleData = [
                    'vin' => $dados['NR_Chassi'] ?? null,
                    'engine_number' => $dados['NR_Motor'] ?? null,
                    'brand' => $dados['NM_MarcaModelo'] ?? $inspection->vehicle->brand,
                    'model' => $dados['NM_MarcaModelo'] ?? $inspection->vehicle->model,
                    'color' => $dados['NM_CorVeiculo'] ?? $inspection->vehicle->color,
                    'fuel_type' => $dados['NM_Combustivel'] ?? $inspection->vehicle->fuel_type,
                    'year' => isset($dados['NR_AnoFabricacao']) ? (int) $dados['NR_AnoFabricacao'] : $inspection->vehicle->year,
                ];

                \Log::info('pullAggregates: atualizando veículo', ['vehicle_data' => $vehicleData]);

                $inspection->vehicle->update($vehicleData);

                \Log::info('=== PULL AGGREGATES CONCLUÍDO COM SUCESSO ===');

                return back()->with('success', 'Dados do veículo atualizados com sucesso! Chassi: ' . ($vehicleData['vin'] ?? 'N/A') . ', Motor: ' . ($vehicleData['engine_number'] ?? 'N/A'));
            }

            \Log::warning('pullAggregates: nenhum resultado encontrado', ['placa' => $placa]);
            return back()->with('warning', 'Nenhuma informação encontrada na base de agregados para a placa ' . $placa . '. Verifique se a placa está correta.');

        } catch (\Illuminate\Database\QueryException $e) {
            \Log::error('pullAggregates: erro de query SQL', [
                'inspection_id' => $inspection->id ?? null,
                'error' => $e->getMessage(),
                'code' => $e->getCode(),
                'sql' => $e->getSql() ?? 'N/A'
            ]);
            
            // Mensagem mais específica para o usuário
            $errorMsg = 'Erro ao consultar a base de agregados: ' . $e->getMessage();
            if (strpos($e->getMessage(), 'could not find driver') !== false) {
                $errorMsg = 'Driver SQL Server não está instalado no servidor. Contate o suporte técnico.';
            } elseif (strpos($e->getMessage(), 'Login failed') !== false) {
                $errorMsg = 'Falha na autenticação com a base de agregados. Verifique as credenciais.';
            } elseif (strpos($e->getMessage(), 'Connection refused') !== false) {
                $errorMsg = 'Não foi possível conectar ao servidor SQL. Verifique firewall e permissões.';
            }
            
            return back()->with('error', $errorMsg);
            
        } catch (\Exception $e) {
            \Log::error('pullAggregates: erro inesperado', [
                'inspection_id' => $inspection->id ?? null,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return back()->with('error', 'Erro inesperado ao buscar dados de agregados: ' . $e->getMessage());
        }
    }

    /**
     * Função privada para salvar os detalhes do checklist.
     * Esta função será chamada pelos métodos approve e disapprove.
     */
    private function saveInspectionDetails(Request $request, Inspection $inspection)
    {
        // Validação básica dos dados do checklist
        $request->validate([
            'details' => 'nullable|array',
            'details.*.item_name' => 'required|string',
            // aceitar qualquer string aqui e normalizar abaixo para evitar problemas de case/acentuação
            'details.*.status' => 'required|string',
            'details.*.observation' => 'nullable|string|max:255',
        ]);

        // Se o array 'details' não foi enviado, não faz nada
        if (!$request->has('details')) {
            return;
        }

        // Normalização de status aceitos (entrada -> valor padronizado salvo no banco)
        $statusMap = [
            'conforme' => 'Conforme',
            'conform' => 'Conforme',
            'não conforme' => 'Não Conforme',
            'nao conforme' => 'Não Conforme',
            'não_conforme' => 'Não Conforme',
            'nao_conforme' => 'Não Conforme',
            'n/a' => 'N/A',
            'na' => 'N/A',
            'n/a' => 'N/A',
        ];

        // Itera e salva cada item do checklist
        foreach ($request->details as $detailData) {
            $rawStatus = (string) ($detailData['status'] ?? '');
            $normalizedKey = mb_strtolower(trim(str_replace(['_', '-'], ' ', $rawStatus)));
            $savedStatus = $statusMap[$normalizedKey] ?? $detailData['status'];

            // Log when the incoming status wasn't mapped so we can track unexpected values from the UI
            if (!array_key_exists($normalizedKey, $statusMap)) {
                \Log::warning(sprintf(
                    'saveInspectionDetails: unmapped status for inspection=%s item="%s" raw="%s" normalized="%s" saving="%s"',
                    $inspection->id ?? 'unknown',
                    $detailData['item_name'] ?? 'unknown',
                    $rawStatus,
                    $normalizedKey,
                    $savedStatus
                ));
            }

            InspectionDetail::updateOrCreate(
                [
                    // Condições para encontrar o registro
                    'inspection_id' => $inspection->id,
                    'item_name' => $detailData['item_name'],
                ],
                [
                    // Dados para atualizar ou criar
                    'status' => $savedStatus,
                    'observation' => $detailData['observation'],
                ]
            );
        }
    }


    /**
     * Aprova uma vistoria. (ATUALIZADO)
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Inspection  $inspection
     * @return \Illuminate\Http\RedirectResponse
     */
    public function approve(Request $request, Inspection $inspection)
    {
        $request->validate(['notes' => 'nullable|string']);

        try {
            DB::transaction(function () use ($request, $inspection) {
                // 1. Salva os dados do Checklist
                $this->saveInspectionDetails($request, $inspection);

                // 2. Atualiza o status da Vistoria
                $inspection->update([
                    'analyst_id' => Auth::id(),
                    'notes' => $request->notes,
                    'status' => 'approved',
                ]);

                // 3. Enviar notificação para o cliente sobre aprovação
                $inspection->load('client');
                $inspection->client->notify(new InspectionApproved($inspection));
            });

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Erro ao aprovar vistoria: ' . $e->getMessage());
            return back()->with('error', 'Ocorreu um erro ao salvar a análise. Tente novamente.');
        }

        return redirect()->route('analyst.dashboard')->with('success', 'Vistoria aprovada com sucesso!');
    }

    /**
     * Reprova uma vistoria. (ATUALIZADO)
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Inspection  $inspection
     * @return \Illuminate\Http\RedirectResponse
     */
    public function disapprove(Request $request, Inspection $inspection)
    {
        $request->validate(['notes' => 'nullable|string']);

        try {
            DB::transaction(function () use ($request, $inspection) {
                // 1. Salva os dados do Checklist
                $this->saveInspectionDetails($request, $inspection);

                // 2. Atualiza o status da Vistoria
                $inspection->update([
                    'analyst_id' => Auth::id(),
                    'notes' => $request->notes,
                    'status' => 'disapproved',
                ]);

                // 3. Enviar notificação para o cliente sobre reprovação
                $inspection->load('client');
                $inspection->client->notify(new InspectionDisapproved($inspection));
            });

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Erro ao reprovar vistoria: ' . $e->getMessage());
            return back()->with('error', 'Ocorreu um erro ao salvar a análise. Tente novamente.');
        }

        return redirect()->route('analyst.dashboard')->with('success', 'Vistoria reprovada com sucesso!');
    }

    /**
     * Exibe o histórico de vistorias do cliente.
     *
     * @return \Illuminate\View\View
     */
    public function history()
    {
        $inspections = Inspection::whereHas('vehicle', function ($query) {
            $query->where('user_id', Auth::id());
        })->with('vehicle', 'analyst')->latest()->get();

        return view('inspections.history', compact('inspections'));
    }
}