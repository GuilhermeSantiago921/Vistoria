<?php
/**
 * TESTE DE CONEXÃO VIA LARAVEL
 * Execute: php artisan tinker --execute="require 'test-laravel-sqlserver.php'"
 * Ou: php test-laravel-sqlserver.php (com bootstrap do Laravel)
 */

// Bootstrap do Laravel
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "\n";
echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║         TESTE SQL SERVER VIA LARAVEL                           ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// Mostrar configuração atual
$config = config('database.connections.sqlsrv_agregados');
echo "Configuração Laravel:\n";
echo "  Driver: " . ($config['driver'] ?? 'N/A') . "\n";
echo "  Host: " . ($config['host'] ?? 'N/A') . "\n";
echo "  Port: " . ($config['port'] ?? 'N/A') . "\n";
echo "  Database: " . ($config['database'] ?? 'N/A') . "\n";
echo "  Username: " . ($config['username'] ?? 'N/A') . "\n";
echo "  Encrypt: " . ($config['encrypt'] ?? 'N/A') . "\n";
echo "  Trust Certificate: " . ($config['trust_server_certificate'] ? 'true' : 'false') . "\n\n";

echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 1: Conexão via DB::connection()\n";
echo "═══════════════════════════════════════════════════════════════\n";

try {
    $pdo = DB::connection('sqlsrv_agregados')->getPdo();
    echo "✓ SUCESSO! Conexão estabelecida via Laravel.\n";
    
    $result = DB::connection('sqlsrv_agregados')
        ->select("SELECT @@VERSION as version");
    echo "SQL Server: " . substr($result[0]->version, 0, 60) . "...\n\n";
} catch (Exception $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 2: Query na tabela Agregados2020\n";
echo "═══════════════════════════════════════════════════════════════\n";

try {
    $results = DB::connection('sqlsrv_agregados')
        ->table('Agregados2020')
        ->select('NR_Chassi', 'NR_Motor', 'NR_Placa')
        ->whereNotNull('NR_Chassi')
        ->limit(3)
        ->get();
    
    echo "✓ SUCESSO! Query executada.\n";
    echo "Resultados:\n";
    foreach ($results as $row) {
        echo "  Chassi: " . ($row->NR_Chassi ?? 'N/A');
        echo " | Motor: " . ($row->NR_Motor ?? 'N/A');
        echo " | Placa: " . ($row->NR_Placa ?? 'N/A') . "\n";
    }
    echo "\n";
} catch (Exception $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 3: Busca por placa específica\n";
echo "═══════════════════════════════════════════════════════════════\n";

try {
    // Buscar uma placa qualquer primeiro
    $sample = DB::connection('sqlsrv_agregados')
        ->table('Agregados2020')
        ->select('NR_Placa')
        ->whereNotNull('NR_Placa')
        ->where('NR_Placa', '!=', '')
        ->first();
    
    if ($sample) {
        echo "Testando busca pela placa: " . $sample->NR_Placa . "\n";
        
        $result = DB::connection('sqlsrv_agregados')
            ->table('Agregados2020')
            ->where('NR_Placa', $sample->NR_Placa)
            ->first();
        
        if ($result) {
            echo "✓ SUCESSO! Veículo encontrado.\n";
            echo "  Placa: " . ($result->NR_Placa ?? 'N/A') . "\n";
            echo "  Chassi: " . ($result->NR_Chassi ?? 'N/A') . "\n";
            echo "  Motor: " . ($result->NR_Motor ?? 'N/A') . "\n";
        }
    } else {
        echo "Nenhuma placa encontrada para teste.\n";
    }
} catch (Exception $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

echo "\n═══════════════════════════════════════════════════════════════\n";
echo "TESTE CONCLUÍDO\n";
echo "═══════════════════════════════════════════════════════════════\n\n";
