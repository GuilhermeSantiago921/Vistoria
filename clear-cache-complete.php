<?php
echo "<h1>🧹 Limpeza de Cache - Laravel</h1>";
echo "<hr>";

$basePath = __DIR__ . '/../../sistema-vistoria';

echo "<h2>🗑️ Limpando Caches...</h2>";

// 1. Limpar cache de configuração
$configCache = $basePath . '/bootstrap/cache/config.php';
if (file_exists($configCache)) {
    unlink($configCache);
    echo "✅ Cache de configuração removido<br>";
} else {
    echo "ℹ️ Cache de configuração não existe<br>";
}

// 2. Limpar cache de rotas
$routeCache = $basePath . '/bootstrap/cache/routes-v7.php';
if (file_exists($routeCache)) {
    unlink($routeCache);
    echo "✅ Cache de rotas removido<br>";
} else {
    echo "ℹ️ Cache de rotas não existe<br>";
}

// 3. Limpar cache de serviços
$servicesCache = $basePath . '/bootstrap/cache/services.php';
if (file_exists($servicesCache)) {
    unlink($servicesCache);
    echo "✅ Cache de serviços removido<br>";
} else {
    echo "ℹ️ Cache de serviços não existe<br>";
}

// 4. Limpar cache de packages
$packagesCache = $basePath . '/bootstrap/cache/packages.php';
if (file_exists($packagesCache)) {
    unlink($packagesCache);
    echo "✅ Cache de packages removido<br>";
} else {
    echo "ℹ️ Cache de packages não existe<br>";
}

// 5. Limpar storage/framework/cache
$frameworkCache = $basePath . '/storage/framework/cache';
if (is_dir($frameworkCache)) {
    $files = glob($frameworkCache . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "✅ Storage framework cache limpo<br>";
}

// 6. Limpar storage/framework/sessions
$sessions = $basePath . '/storage/framework/sessions';
if (is_dir($sessions)) {
    $files = glob($sessions . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "✅ Sessions limpas<br>";
}

// 7. Limpar storage/framework/views
$views = $basePath . '/storage/framework/views';
if (is_dir($views)) {
    $files = glob($views . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "✅ Views compiladas limpas<br>";
}

echo "<hr>";
echo "<h2>✨ Cache Limpo!</h2>";
echo "<p>Agora substitua o arquivo index.php pelo novo e teste novamente.</p>";
echo "<p><strong>Próximos passos:</strong></p>";
echo "<ul>";
echo "<li>1. Substitua <code>index.php</code> pelo conteúdo do <code>index.php.fixed</code></li>";
echo "<li>2. Teste o acesso ao sistema</li>";
echo "<li>3. Se ainda houver erro, execute o debug novamente</li>";
echo "</ul>";
?>
