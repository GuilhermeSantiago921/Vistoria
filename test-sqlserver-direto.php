<?php
/**
 * TESTE DIRETO DE CONEXÃO SQL SERVER
 * Execute: php test-sqlserver-direto.php
 * 
 * Este script testa a conexão FORA do Laravel
 * para identificar se o problema é do framework ou do driver.
 */

echo "\n";
echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║         TESTE DIRETO SQL SERVER (SEM LARAVEL)                  ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

// Configurações - MESMAS DO .env
$host = '189.113.13.114';
$port = '1433';
$database = 'VeiculosAgregados';
$username = 'rodrigo';
$password = 'Prime@2024#';

echo "Configurações:\n";
echo "  Host: $host\n";
echo "  Port: $port\n";
echo "  Database: $database\n";
echo "  Username: $username\n";
echo "  Password: " . str_repeat('*', strlen($password)) . "\n\n";

// TESTE 1: Connection String padrão
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 1: Connection String Padrão\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn1 = "sqlsrv:Server=$host,$port;Database=$database";
echo "DSN: $dsn1\n\n";

try {
    $pdo = new PDO($dsn1, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n";
    $result = $pdo->query("SELECT @@VERSION as version")->fetch();
    echo "SQL Server: " . substr($result['version'], 0, 60) . "...\n\n";
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

// TESTE 2: Com TrustServerCertificate
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 2: Com TrustServerCertificate=1\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn2 = "sqlsrv:Server=$host,$port;Database=$database;TrustServerCertificate=1";
echo "DSN: $dsn2\n\n";

try {
    $pdo = new PDO($dsn2, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n";
    $result = $pdo->query("SELECT 1 as test")->fetch();
    echo "Query OK: test = " . $result['test'] . "\n\n";
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

// TESTE 3: Com Encrypt=no
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 3: Com Encrypt=no\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn3 = "sqlsrv:Server=$host,$port;Database=$database;Encrypt=no";
echo "DSN: $dsn3\n\n";

try {
    $pdo = new PDO($dsn3, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n";
    $result = $pdo->query("SELECT 1 as test")->fetch();
    echo "Query OK: test = " . $result['test'] . "\n\n";
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

// TESTE 4: Com Encrypt=no e TrustServerCertificate=1
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 4: Com Encrypt=no e TrustServerCertificate=1\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn4 = "sqlsrv:Server=$host,$port;Database=$database;Encrypt=no;TrustServerCertificate=1";
echo "DSN: $dsn4\n\n";

try {
    $pdo = new PDO($dsn4, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n";
    $result = $pdo->query("SELECT 1 as test")->fetch();
    echo "Query OK: test = " . $result['test'] . "\n\n";
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

// TESTE 5: Com LoginTimeout
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 5: Com LoginTimeout=30\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn5 = "sqlsrv:Server=$host,$port;Database=$database;LoginTimeout=30;Encrypt=no;TrustServerCertificate=1";
echo "DSN: $dsn5\n\n";

try {
    $pdo = new PDO($dsn5, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n";
    
    // Testar query real
    echo "\nTestando query na tabela Agregados2020...\n";
    $stmt = $pdo->prepare("SELECT TOP 1 NR_Chassi, NR_Motor FROM VeiculosAgregados.dbo.Agregados2020 WHERE NR_Chassi IS NOT NULL");
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($row) {
        echo "✓ Query OK!\n";
        echo "  Chassi: " . ($row['NR_Chassi'] ?? 'N/A') . "\n";
        echo "  Motor: " . ($row['NR_Motor'] ?? 'N/A') . "\n";
    } else {
        echo "Nenhum resultado encontrado.\n";
    }
    
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

// TESTE 6: Usando IP,porta separados
echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE 6: Formato alternativo (Server=IP,porta)\n";
echo "═══════════════════════════════════════════════════════════════\n";

$dsn6 = "sqlsrv:Server={$host},{$port};Database={$database};Encrypt=0;TrustServerCertificate=1";
echo "DSN: $dsn6\n\n";

try {
    $pdo = new PDO($dsn6, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ SUCESSO! Conexão estabelecida.\n\n";
    $pdo = null;
} catch (PDOException $e) {
    echo "✗ ERRO: " . $e->getMessage() . "\n\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo "TESTE CONCLUÍDO\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

echo "Se algum teste funcionou, anote o DSN que funcionou e me informe!\n";
echo "Usaremos esse formato no Laravel.\n\n";
