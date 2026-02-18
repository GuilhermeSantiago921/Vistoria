<?php
/**
 * DIAGNÓSTICO DO DSN CONSTRUÍDO PELO LARAVEL
 */

// Bootstrap do Laravel
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "\n";
echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║         DIAGNÓSTICO DSN LARAVEL                                ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// Capturar o DSN real que o Laravel está tentando usar
try {
    // Tentar conectar e capturar o erro com detalhes
    DB::connection('sqlsrv_agregados')->getPdo();
} catch (Exception $e) {
    echo "Erro esperado: " . $e->getMessage() . "\n\n";
}

// Vamos construir manualmente o DSN para comparar
$config = config('database.connections.sqlsrv_agregados');

echo "Configuração do database.php:\n";
print_r($config);
echo "\n";

// Construir DSN manualmente como o Laravel deveria fazer
$host = $config['host'];
$port = $config['port'];
$database = $config['database'];

echo "DSN que DEVERIA ser construído:\n";
echo "sqlsrv:Server={$host},{$port};Database={$database};TrustServerCertificate=1;Encrypt=no\n\n";

// Testar com PDO direto usando a config do Laravel
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE: PDO Direto com Config do Laravel\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn = "sqlsrv:Server={$host},{$port};Database={$database};TrustServerCertificate=1;Encrypt=no";
echo "DSN: $dsn\n";
echo "Username: " . $config['username'] . "\n";
echo "Password: " . str_repeat('*', strlen($config['password'])) . "\n\n";

try {
    $pdo = new PDO(
        $dsn,
        $config['username'],
        $config['password']
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! PDO direto funciona.\n";
    
    $result = $pdo->query("SELECT @@VERSION as version")->fetch();
    echo "SQL Server: " . substr($result['version'], 0, 60) . "...\n\n";
    
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "ANÁLISE\n";
echo "═══════════════════════════════════════════════════════════════\n";
echo "Se o PDO direto funcionou mas o Laravel falhou, o problema está\n";
echo "no connector do Laravel não estar aplicando TrustServerCertificate\n";
echo "e Encrypt=no corretamente no DSN.\n\n";
