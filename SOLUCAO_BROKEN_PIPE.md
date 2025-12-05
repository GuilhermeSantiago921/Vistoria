# Solução: Erro "Broken pipe" no Laravel

## 🔍 Problema

```
Notice: file_put_contents(): Write of 72 bytes failed with errno=32 Broken pipe
in vendor/laravel/framework/src/Illuminate/Foundation/resources/server.php on line 21
```

## 📋 Causas Comuns

Este erro geralmente ocorre quando:

1. **Cliente HTTP desconecta antes da resposta** (navegador fecha, timeout, etc)
2. **Upload de arquivos grandes** (suas 10 fotos)
3. **Servidor de desenvolvimento do Laravel** (`php artisan serve`) tem limitações
4. **Problemas de buffer/memória**

## ✅ Soluções

### Solução 1: Usar Servidor de Desenvolvimento Melhorado

Em vez de usar `php artisan serve`, use uma das opções abaixo:

#### **Opção A: Laravel Valet (macOS)** ⭐ RECOMENDADO

```bash
# Instalar Valet
composer global require laravel/valet

# Adicionar ao PATH (se necessário)
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Instalar Valet
valet install

# No diretório do projeto
cd /Users/guilherme/Documents/vistoria
valet link vistoria

# Acessar via: http://vistoria.test
```

#### **Opção B: Docker** (Multiplataforma)

Se você já tem o `docker-compose.yml`:

```bash
cd /Users/guilherme/Documents/vistoria

# Iniciar containers
docker-compose up -d

# Acessar via: http://localhost:8000
```

#### **Opção C: PHP Built-in Server Configurado**

Crie um script otimizado:

```bash
# Criar arquivo
nano start-dev-server.sh
```

Adicione:

```bash
#!/bin/bash

# Aumentar limites do PHP
export PHP_CLI_SERVER_WORKERS=4

# Iniciar servidor com configurações otimizadas
php -d upload_max_filesize=50M \
    -d post_max_size=50M \
    -d memory_limit=256M \
    -d max_execution_time=300 \
    -S localhost:8000 \
    -t public \
    public/index.php
```

```bash
chmod +x start-dev-server.sh
./start-dev-server.sh
```

### Solução 2: Configurar PHP para Ignorar Erros de Cliente Desconectado

```bash
# Editar php.ini
php --ini  # Ver localização do php.ini

# Adicionar estas linhas
ignore_user_abort = On
output_buffering = 4096
```

### Solução 3: Aumentar Timeouts (macOS)

Crie arquivo `php-dev.ini`:

```bash
nano /Users/guilherme/Documents/vistoria/php-dev.ini
```

Adicione:

```ini
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 300
max_input_time = 300
memory_limit = 256M
ignore_user_abort = On
output_buffering = 4096
default_socket_timeout = 300
```

Use ao iniciar o servidor:

```bash
php -c php-dev.ini -S localhost:8000 -t public
```

### Solução 4: Usar Nginx + PHP-FPM Localmente

#### **Instalar Homebrew (se não tiver)**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### **Instalar Nginx e PHP-FPM**

```bash
# Instalar
brew install nginx php@8.2

# Iniciar serviços
brew services start nginx
brew services start php@8.2
```

#### **Configurar Nginx**

```bash
nano /opt/homebrew/etc/nginx/servers/vistoria.conf
```

Adicione:

```nginx
server {
    listen 8000;
    server_name localhost;
    root /Users/guilherme/Documents/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    client_max_body_size 50M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
        fastcgi_send_timeout 300;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

```bash
# Testar configuração
nginx -t

# Reiniciar Nginx
brew services restart nginx

# Acessar: http://localhost:8000
```

### Solução 5: Workaround Rápido (Temporário)

Se você só precisa que funcione agora:

```bash
# Iniciar servidor em background ignorando erros
php artisan serve --host=0.0.0.0 --port=8000 2>/dev/null &

# Ou usar nohup
nohup php artisan serve > /dev/null 2>&1 &
```

## 🔧 Configurações Específicas para Upload de Fotos

Se o erro ocorre durante upload das 10 fotos, ajuste o `.env`:

```env
# Adicionar ao .env
UPLOAD_MAX_SIZE=52428800
POST_MAX_SIZE=52428800
MAX_EXECUTION_TIME=300
```

E crie um arquivo `config/upload.php`:

```php
<?php

return [
    'max_file_size' => env('UPLOAD_MAX_SIZE', 5242880), // 5MB padrão
    'max_total_size' => env('POST_MAX_SIZE', 31457280), // 30MB padrão
    'allowed_mimes' => ['jpeg', 'png', 'jpg'],
];
```

## 🐛 Debug: Verificar o que está causando

```bash
# Ver logs do Laravel em tempo real
tail -f storage/logs/laravel.log

# Verificar permissões de storage
ls -la storage/logs/

# Limpar cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Recriar link de storage
php artisan storage:link
```

## 📊 Monitorar Upload

Adicione logs temporários no `InspectionController.php`:

```php
// No método store(), após validação
\Log::info('=== UPLOAD DEBUG ===', [
    'total_files' => count($request->allFiles()),
    'memory_usage' => memory_get_usage(true) / 1024 / 1024 . ' MB',
    'memory_limit' => ini_get('memory_limit'),
    'max_execution_time' => ini_get('max_execution_time'),
]);
```

## ✅ Solução Recomendada para Produção

Para produção (Rocky Linux), o guia já inclui Nginx + PHP-FPM, que não tem esse problema.

Para desenvolvimento local (macOS), use:

1. **Laravel Valet** (mais fácil) ⭐
2. **Docker** (mais próximo da produção)
3. **Nginx + PHP-FPM local** (profissional)

## 🚀 Quick Fix

Execute agora:

```bash
cd /Users/guilherme/Documents/vistoria

# Opção 1: Com configuração inline
php -d upload_max_filesize=50M -d post_max_size=50M -d memory_limit=256M -d max_execution_time=300 -S localhost:8000 -t public

# OU Opção 2: Instalar Valet (uma vez)
composer global require laravel/valet
valet install
valet link vistoria
# Agora acesse: http://vistoria.test
```

## 📝 Notas Importantes

- ⚠️ O erro "Broken pipe" **NÃO é crítico** - geralmente o upload ainda funciona
- ⚠️ É um problema do servidor de desenvolvimento PHP built-in
- ✅ Em produção com Nginx/PHP-FPM não ocorre
- ✅ Laravel Valet resolve completamente o problema
- ✅ Docker também resolve

## 🎯 Resumo

| Método | Dificuldade | Recomendado | Resolve Problema |
|--------|-------------|-------------|------------------|
| Laravel Valet | Fácil | ⭐⭐⭐⭐⭐ | ✅ Sim |
| Docker | Média | ⭐⭐⭐⭐ | ✅ Sim |
| Nginx Local | Média | ⭐⭐⭐ | ✅ Sim |
| PHP Configurado | Fácil | ⭐⭐ | ⚠️ Parcial |
| `php artisan serve` | Muito Fácil | ⭐ | ❌ Não |

**Recomendação final:** Use Laravel Valet no macOS para desenvolvimento. É instalação única e funciona perfeitamente.
