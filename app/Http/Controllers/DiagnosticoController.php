<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use PDO;

/**
 * Controller para diagnóstico de conexão SQL Server
 * Rota de teste para verificar conectividade com Agregados
 */
class DiagnosticoController extends Controller
{
    /**
     * Testa conexão com SQL Server Agregados
     * GET /test-db-connection
     */
    public function testConnection()
    {
        $resultado = [
            'timestamp' => now()->toDateTimeString(),
            'servidor' => gethostname(),
            'php_version' => phpversion(),
            'extensoes' => [],
            'configuracao' => [],
            'teste_conexao' => [],
            'teste_query' => [],
            'recomendacoes' => []
        ];

        try {
            // 1. Verificar extensões PHP
            $resultado['extensoes'] = [
                'pdo' => extension_loaded('pdo'),
                'pdo_sqlsrv' => extension_loaded('pdo_sqlsrv'),
                'sqlsrv' => extension_loaded('sqlsrv'),
                'todas_extensoes' => get_loaded_extensions()
            ];

            // 2. Verificar configuração
            $resultado['configuracao'] = [
                'host' => config('database.connections.sqlsrv_agregados.host'),
                'port' => config('database.connections.sqlsrv_agregados.port'),
                'database' => config('database.connections.sqlsrv_agregados.database'),
                'username' => config('database.connections.sqlsrv_agregados.username'),
                'password_configurado' => !empty(config('database.connections.sqlsrv_agregados.password')),
                'charset' => config('database.connections.sqlsrv_agregados.charset'),
                'trust_server_certificate' => config('database.connections.sqlsrv_agregados.trust_server_certificate'),
                'integracao_habilitada' => config('database.enable_aggregados_integration')
            ];

            // 3. Testar conexão
            if (!$resultado['extensoes']['pdo_sqlsrv']) {
                $resultado['teste_conexao'] = [
                    'sucesso' => false,
                    'erro' => 'Extensão pdo_sqlsrv não está instalada',
                    'codigo_erro' => 'EXTENSAO_AUSENTE'
                ];
                $resultado['recomendacoes'][] = 'Instalar extensão: sudo apt-get install php8.2-sqlsrv php8.2-pdo-sqlsrv';
            } else {
                try {
                    $pdo = DB::connection('sqlsrv_agregados')->getPdo();
                    
                    $resultado['teste_conexao'] = [
                        'sucesso' => true,
                        'driver' => $pdo->getAttribute(PDO::ATTR_DRIVER_NAME),
                        'server_info' => $pdo->getAttribute(PDO::ATTR_SERVER_INFO),
                        'client_version' => $pdo->getAttribute(PDO::ATTR_CLIENT_VERSION),
                        'connection_status' => $pdo->getAttribute(PDO::ATTR_CONNECTION_STATUS)
                    ];

                    // 4. Testar query simples
                    try {
                        $query_test = DB::connection('sqlsrv_agregados')->select('SELECT 1 as test');
                        $resultado['teste_query']['query_simples'] = [
                            'sucesso' => true,
                            'resultado' => $query_test
                        ];

                        // 5. Testar query real na tabela Agregados
                        try {
                            $query_agregados = DB::connection('sqlsrv_agregados')->select(
                                'SELECT TOP 5 NR_PlacaModeloNovo, NR_Chassi FROM VeiculosAgregados.dbo.Agregados2020 WHERE NR_Chassi IS NOT NULL'
                            );
                            
                            $resultado['teste_query']['query_agregados'] = [
                                'sucesso' => true,
                                'total_registros' => count($query_agregados),
                                'exemplo' => $query_agregados
                            ];
                        } catch (\Exception $e) {
                            $resultado['teste_query']['query_agregados'] = [
                                'sucesso' => false,
                                'erro' => $e->getMessage(),
                                'codigo' => $e->getCode(),
                                'arquivo' => $e->getFile() . ':' . $e->getLine()
                            ];
                            $resultado['recomendacoes'][] = 'Verificar permissões na tabela VeiculosAgregados.dbo.Agregados2020';
                        }

                    } catch (\Exception $e) {
                        $resultado['teste_query']['query_simples'] = [
                            'sucesso' => false,
                            'erro' => $e->getMessage(),
                            'codigo' => $e->getCode()
                        ];
                    }

                } catch (\Exception $e) {
                    $resultado['teste_conexao'] = [
                        'sucesso' => false,
                        'erro' => $e->getMessage(),
                        'codigo_erro' => $e->getCode(),
                        'arquivo' => $e->getFile() . ':' . $e->getLine(),
                        'trace' => $e->getTraceAsString()
                    ];

                    // Diagnosticar tipo de erro
                    $erro_msg = strtolower($e->getMessage());
                    
                    if (str_contains($erro_msg, 'could not find driver')) {
                        $resultado['recomendacoes'][] = 'Driver não encontrado. Instalar: sudo apt-get install php-sqlsrv';
                    }
                    
                    if (str_contains($erro_msg, 'login failed') || str_contains($erro_msg, 'authentication')) {
                        $resultado['recomendacoes'][] = 'Erro de autenticação. Verificar credenciais no .env';
                    }
                    
                    if (str_contains($erro_msg, 'connection refused') || str_contains($erro_msg, 'timeout')) {
                        $resultado['recomendacoes'][] = 'Servidor inacessível. Verificar firewall e conectividade de rede';
                    }
                    
                    if (str_contains($erro_msg, 'certificate')) {
                        $resultado['recomendacoes'][] = 'Erro de certificado SSL. Configurar TrustServerCertificate=true';
                    }
                }
            }

            // 6. Verificar logs recentes
            $log_file = storage_path('logs/laravel.log');
            if (file_exists($log_file)) {
                $logs = file($log_file);
                $ultimas_linhas = array_slice($logs, -50);
                $erros_sqlserver = array_filter($ultimas_linhas, function($linha) {
                    return stripos($linha, 'sqlsrv') !== false 
                        || stripos($linha, 'agregados') !== false
                        || stripos($linha, 'sql server') !== false;
                });
                
                $resultado['logs_recentes'] = [
                    'total_linhas' => count($logs),
                    'erros_sqlserver' => array_values($erros_sqlserver)
                ];
            }

            // Log do teste
            Log::info('Diagnóstico SQL Server executado', [
                'conexao_ok' => $resultado['teste_conexao']['sucesso'] ?? false,
                'extensao_ok' => $resultado['extensoes']['pdo_sqlsrv'] ?? false
            ]);

        } catch (\Exception $e) {
            $resultado['erro_geral'] = [
                'mensagem' => $e->getMessage(),
                'arquivo' => $e->getFile() . ':' . $e->getLine(),
                'trace' => $e->getTraceAsString()
            ];
        }

        return response()->json($resultado, 200, [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }

    /**
     * Testa consulta de placa específica
     * GET /test-placa/{placa}
     */
    public function testPlaca($placa)
    {
        $placa = strtoupper(str_replace('-', '', $placa));
        
        $resultado = [
            'placa_consultada' => $placa,
            'timestamp' => now()->toDateTimeString(),
            'resultado' => null,
            'erro' => null
        ];

        try {
            if (!config('database.enable_aggregados_integration')) {
                return response()->json([
                    'erro' => 'Integração com Agregados está DESABILITADA no .env',
                    'solucao' => 'Definir ENABLE_AGGREGADOS_INTEGRATION=true no .env'
                ], 400);
            }

            $query = "
                SELECT TOP 1
                    A.NR_Chassi,
                    A.NR_Motor,
                    A.NR_AnoFabricacao,
                    A.NR_AnoModelo,
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

            $dados = DB::connection('sqlsrv_agregados')->select($query, [$placa, $placa]);

            if (!empty($dados)) {
                $resultado['resultado'] = [
                    'encontrado' => true,
                    'dados' => $dados[0]
                ];
                
                Log::info('Consulta de placa bem-sucedida', ['placa' => $placa]);
            } else {
                $resultado['resultado'] = [
                    'encontrado' => false,
                    'mensagem' => 'Nenhum dado encontrado para esta placa no banco Agregados'
                ];
            }

        } catch (\Exception $e) {
            $resultado['erro'] = [
                'mensagem' => $e->getMessage(),
                'codigo' => $e->getCode(),
                'arquivo' => $e->getFile() . ':' . $e->getLine()
            ];

            Log::error('Erro ao consultar placa', [
                'placa' => $placa,
                'erro' => $e->getMessage()
            ]);
        }

        return response()->json($resultado, 200, [], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
}
