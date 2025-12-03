# 🚀 Guia de Deploy no HostGator - Sistema de Vistoria

## 📋 Pré-requisitos
- Plano HostGator Business ou superior (suporte ao Laravel)
- PHP 8.1 ou superior
- MySQL/MariaDB
- Acesso ao cPanel
- Cliente FTP ou File Manager

## 🔧 Passos para Deploy

### 1. **Preparar o Projeto**
```bash
# No seu computador, execute:
chmod +x deploy.sh
./deploy.sh
```

### 2. **Estrutura de Pastas no HostGator (grupoautocredcar.com.br)**
```
/home/sist5700/
├── sistema-vistoria/         # Arquivos do Laravel (FORA do domínio principal)
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   ├── vendor/
│   └── ...
└── grupoautocredcar.com.br/
    └── vistoria/             # Apenas a pasta public (DENTRO do domínio)
        ├── index.php
        ├── css/
        ├── js/
        └── ...
```

### 3. **Upload dos Arquivos**

#### Via FTP/File Manager:
1. **Crie a pasta `sistema-vistoria` FORA do domínio principal**
2. **Faça upload de todos os arquivos EXCETO a pasta `public`**
3. **Faça upload do conteúdo da pasta `public` para `/home/sist5700/grupoautocredcar.com.br/vistoria/`**

### 4. **Configurar o index.php**
Edite o arquivo `/home/sist5700/grupoautocredcar.com.br/vistoria/index.php`:

```php
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Ajuste o caminho para o arquivo de autoload
require __DIR__.'/../../sistema-vistoria/vendor/autoload.php';

// Ajuste o caminho para o bootstrap
$app = require_once __DIR__.'/../../sistema-vistoria/bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
```

### 5. **Configurar o .env**
1. Copie `.env.hostgator` para `sistema-vistoria/.env`
2. **Configure os dados do MySQL:**
   - Crie um banco de dados no cPanel
   - Atualize `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
3. **Configure o domínio:**
   - Atualize `APP_URL=https://grupoautocredcar.com.br/vistoria`

### 6. **Configurar Email**
No cPanel do HostGator:
1. Crie uma conta de email (ex: contato@grupoautocredcar.com.br)
2. Configure no `.env`:
```
MAIL_HOST=mail.grupoautocredcar.com.br
MAIL_USERNAME=contato@grupoautocredcar.com.br
MAIL_PASSWORD=senha_do_email
```

### 7. **Executar Migrações**
Via Terminal SSH (se disponível) ou cPanel Terminal:
```bash
cd sistema-vistoria
php artisan migrate --force
php artisan db:seed --force
```

### 8. **Configurar Permissões**
```bash
chmod -R 755 sistema-vistoria/
chmod -R 775 sistema-vistoria/storage/
chmod -R 775 sistema-vistoria/bootstrap/cache/
```

### 9. **Configurar .htaccess**
Crie `/home/sist5700/grupoautocredcar.com.br/vistoria/.htaccess`:
```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

## 🔒 Segurança Adicional

### 1. **Proteger pasta storage**
Crie `sistema-vistoria/storage/.htaccess`:
```apache
<Files "*">
    Order Deny,Allow
    Deny from All
</Files>
```

### 2. **Proteger arquivo .env**
Crie `sistema-vistoria/.htaccess`:
```apache
<Files ".env">
    Order Allow,Deny
    Deny from All
</Files>
```

## 🎯 URLs de Acesso

- **Site**: https://grupoautocredcar.com.br/vistoria/
- **Admin**: https://grupoautocredcar.com.br/vistoria/admin/dashboard
- **Login**: https://grupoautocredcar.com.br/vistoria/login

## 🐛 Troubleshooting

### Erro 500:
1. Verifique permissões das pastas
2. Verifique o arquivo `.env`
3. Verifique os logs em `sistema-vistoria/storage/logs/`

### Banco não conecta:
1. Verifique as credenciais no `.env`
2. Confirme que o banco foi criado no cPanel
3. Teste a conexão no cPanel > phpMyAdmin

### CSS/JS não carrega:
1. Execute `php artisan storage:link`
2. Verifique se os arquivos estão em `public_html/vistoria/`
3. Verifique a configuração `APP_URL`

## 📞 Suporte
- Documentação Laravel: https://laravel.com/docs
- Suporte HostGator: Central de ajuda do HostGator
- Logs do sistema: `sistema-vistoria/storage/logs/laravel.log`
