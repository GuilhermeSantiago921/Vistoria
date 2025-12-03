# 🔧 Solução: Erro ao Consultar Base de Agregados

## 🔍 Problema
O botão "Puxar/Atualizar Dados da BIN Agregados" retorna erro ao tentar consultar o SQL Server.

## 🎯 Causa Provável
1. **Extensões PHP não instaladas** - HostGator pode não ter `pdo_sqlsrv` ou `sqlsrv`
2. **Firewall bloqueando conexão** - IP do HostGator não tem permissão no SQL Server
3. **Configuração incorreta** - Arquivo `.env` no servidor está diferente
4. **Cache do Laravel** - Configurações antigas em cache

---

## ✅ PASSO 1: Diagnóstico (OBRIGATÓRIO)

### 1.1 Enviar arquivo de teste
Envie o arquivo **`test-agregados.php`** para a pasta `public/` no HostGator

### 1.2 Executar teste
Acesse no navegador:
```
https://grupoautocredcar.com.br/test-agregados.php
```

### 1.3 Interpretar resultado

#### ✅ Caso A: "Conexão OK"
Se aparecer **"✅ CONEXÃO OK!"** e dados da consulta:
- **Problema**: Cache do Laravel
- **Solução**: Ir para PASSO 2

#### ❌ Caso B: "Extensões Faltando"
Se aparecer **"❌ pdo_sqlsrv: NÃO ENCONTRADA"**:
- **Problema**: Driver SQL Server não instalado
- **Solução**: Ir para PASSO 3

#### ❌ Caso C: "Erro de Conexão"
Se aparecer **"❌ ERRO DE CONEXÃO PDO"**:
- **Problema**: Firewall ou credenciais
- **Solução**: Ir para PASSO 4

---

## ✅ PASSO 2: Limpar Cache do Laravel

Se o teste passou, mas o Laravel ainda dá erro:

### Via Terminal SSH (cPanel)
```bash
cd /home1/sist5700/grupoautocredcar.com.br/vistoria

# Limpar todos os caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Recriar cache otimizado
php artisan config:cache
php artisan route:cache
```

### Via Script PHP (Alternativa)
Crie arquivo `clear-cache-agregados.php` em `public/`:
```php
<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

echo "<h1>🧹 Limpando Cache do Laravel</h1>";

$commands = [
    'config:clear',
    'cache:clear',
    'route:clear',
    'view:clear',
];

foreach ($commands as $cmd) {
    echo "<p>Executando: <code>{$cmd}</code>... ";
    try {
        $kernel->call($cmd);
        echo "<strong style='color: green;'>✅ OK</strong></p>";
    } catch (Exception $e) {
        echo "<strong style='color: red;'>❌ Erro: {$e->getMessage()}</strong></p>";
    }
}

echo "<hr>";
echo "<p style='color: green;'><strong>✅ Cache limpo! Teste o botão novamente.</strong></p>";
echo "<p style='color: red;'><strong>⚠️ APAGUE ESTE ARQUIVO APÓS USAR!</strong></p>";
?>
```

Execute: `https://grupoautocredcar.com.br/clear-cache-agregados.php`

---

## ✅ PASSO 3: Instalar Extensões PHP (Se faltarem)

### 3.1 Contato com Suporte HostGator
Abra um ticket solicitando:

```
Assunto: Instalação de extensões PHP para SQL Server

Mensagem:
Olá,

Preciso que instalem as seguintes extensões PHP no meu plano de hospedagem:
- pdo_sqlsrv
- sqlsrv

Estas extensões são necessárias para conectar ao Microsoft SQL Server.
Minha conta é: grupoautocredcar.com.br
PHP Version: 8.3.24

Agradeço!
```

### 3.2 Verificar após instalação
Execute novamente: `https://grupoautocredcar.com.br/test-agregados.php`

---

## ✅ PASSO 4: Liberar IP no Firewall do SQL Server

Se o teste mostra erro de conexão:

### 4.1 Descobrir IP do servidor HostGator
Crie arquivo `get-server-ip.php` em `public/`:
```php
<?php
echo "<h1>🌐 IP do Servidor HostGator</h1>";
echo "<p><strong>IP Público:</strong> " . $_SERVER['SERVER_ADDR'] . "</p>";
echo "<p><strong>IP via file_get_contents:</strong> " . file_get_contents('https://api.ipify.org') . "</p>";
echo "<hr>";
echo "<p>Envie este IP para o administrador do SQL Server liberar no firewall.</p>";
?>
```

Execute: `https://grupoautocredcar.com.br/get-server-ip.php`

### 4.2 Liberar IP no SQL Server
No servidor SQL (189.113.13.114):
1. Abrir **SQL Server Management Studio**
2. Security → Logins → `rodrigo` → Properties
3. **User Mapping** → Verificar acesso ao banco `VeiculosAgregados`
4. **Firewall Windows**: Adicionar regra permitindo o IP do HostGator na porta 1433

### 4.3 Testar novamente
Execute: `https://grupoautocredcar.com.br/test-agregados.php`

---

## ✅ PASSO 5: Verificar Configuração .env

### 5.1 Verificar arquivo .env no servidor
Via **cPanel → File Manager**, abra o arquivo `.env` e confirme:

```env
DB_AGREGADOS_CONNECTION=sqlsrv
DB_AGREGADOS_HOST=189.113.13.114
DB_AGREGADOS_PORT=1433
DB_AGREGADOS_DATABASE=VeiculosAgregados
DB_AGREGADOS_USERNAME=rodrigo
DB_AGREGADOS_PASSWORD=Prime@2024#
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
```

⚠️ **IMPORTANTE**: Adicione as linhas de ENCRYPT e TRUST se não existirem!

### 5.2 Limpar cache após alterar .env
```bash
php artisan config:clear
php artisan config:cache
```

---

## ✅ PASSO 6: Verificar Logs do Laravel

### Via cPanel File Manager
Abra o arquivo:
```
storage/logs/laravel.log
```

Procure por linhas com:
- `pullAggregates: erro`
- `ERRO DE CONEXÃO`
- `QueryException`

### Via Terminal SSH
```bash
tail -100 storage/logs/laravel.log | grep -i "pullAggregates"
```

---

## 🧪 Como Testar se Funcionou

### 1. Após cada solução, teste:
1. Login como **analista**
2. Ir em **"Todas as Vistorias"**
3. Abrir uma vistoria existente
4. Clicar em **"Puxar/Atualizar Dados da BIN Agregados"**

### 2. Resultado esperado:
```
✅ Dados do veículo atualizados com sucesso!
Chassi: ABC123456789, Motor: XYZ987654
```

### 3. Se ainda der erro:
- Verificar `storage/logs/laravel.log` - logs detalhados foram adicionados
- Executar `test-agregados.php` novamente
- Verificar se o cache foi limpo

---

## 📋 Checklist Completo

- [ ] Executado `test-agregados.php` - verificar extensões PHP
- [ ] Conexão OK no teste? → Limpar cache Laravel
- [ ] Extensões faltando? → Contatar suporte HostGator
- [ ] Erro de conexão? → Liberar IP do HostGator no firewall SQL Server
- [ ] Arquivo `.env` correto no servidor
- [ ] Linhas `DB_AGREGADOS_ENCRYPT` e `TRUST_SERVER_CERTIFICATE` adicionadas
- [ ] Cache limpo: `php artisan config:clear && config:cache`
- [ ] Logs verificados em `storage/logs/laravel.log`
- [ ] Botão testado - dados atualizados com sucesso
- [ ] Arquivos de teste apagados

---

## 🆘 Se Nada Funcionar

### Solução Alternativa: Desabilitar integração

Edite `resources/views/analyst/inspections/show.blade.php`:

**Comentar o botão:**
```blade
{{-- Temporariamente desabilitado
<div class="mt-6 pt-4 border-t">
    <form method="POST" action="{{ route('analyst.inspections.pull_data', $inspection) }}">
        @csrf
        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Puxar/Atualizar Dados da BIN Agregados
        </button>
    </form>
</div>
--}}
```

O sistema continua funcionando normalmente, mas sem puxar dados automáticos do SQL Server.

---

## 📁 Arquivos Criados

1. **`test-agregados.php`** - Diagnóstico completo da conexão
2. **`clear-cache-agregados.php`** - Limpa cache via web
3. **`get-server-ip.php`** - Descobre IP do servidor

**⚠️ APAGUE TODOS APÓS RESOLUÇÃO!**

---

## 🎯 Resumo das Causas Mais Comuns

| Erro | Causa | Solução |
|------|-------|---------|
| "Erro ao consultar base de agregados" | Cache antigo | Limpar cache Laravel |
| "could not find driver" | Extensão PHP não instalada | Instalar pdo_sqlsrv via suporte |
| "Connection refused" | Firewall bloqueando | Liberar IP no SQL Server |
| "Login failed" | Credenciais erradas | Verificar .env no servidor |
| Funciona no teste mas não no Laravel | Cache de config | config:clear + config:cache |

---

**Boa sorte! 🚀**
