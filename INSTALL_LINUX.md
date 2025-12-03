# 🐧 Guia de Instalação - Sistema de Vistoria Linux

## 📋 Requisitos do Sistema

### Mínimo
- **OS:** Ubuntu 20.04+ / Debian 11+ / CentOS 8+ / Rocky Linux 8+
- **RAM:** 2GB
- **Disco:** 10GB livres
- **CPU:** 2 cores

### Software Necessário
- PHP 8.1+ com extensões
- Composer 2.x
- SQLite 3.x ou MySQL 8.0+
- Nginx ou Apache
- Node.js 18+ e NPM
- Git

---

## 🚀 Instalação Automática (Ubuntu/Debian)

### Método 1: Script de Instalação Completa

```bash
# Baixar e executar instalador
curl -o install.sh https://raw.githubusercontent.com/seu-repo/vistoria/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

---

## 🔧 Instalação Manual

### Passo 1: Atualizar Sistema

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/Rocky Linux
sudo dnf update -y
```

### Passo 2: Instalar PHP 8.3

```bash
# Ubuntu/Debian
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3 php8.3-cli php8.3-fpm php8.3-common \
    php8.3-mysql php8.3-sqlite3 php8.3-xml php8.3-curl \
    php8.3-mbstring php8.3-zip php8.3-gd php8.3-bcmath \
    php8.3-intl php8.3-opcache

# CentOS/Rocky Linux
sudo dnf install -y epel-release
sudo dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.3 -y
sudo dnf install -y php php-cli php-fpm php-common php-mysqlnd \
    php-pdo php-xml php-curl php-mbstring php-zip php-gd php-bcmath php-intl
```

### Passo 3: Instalar Composer

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
composer --version
```

### Passo 4: Instalar Node.js e NPM

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# CentOS/Rocky Linux
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Verificar versão
node --version
npm --version
```

### Passo 5: Instalar Nginx

```bash
# Ubuntu/Debian
sudo apt install -y nginx

# CentOS/Rocky Linux
sudo dnf install -y nginx

# Iniciar e habilitar
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Passo 6: Instalar SQLite (ou MySQL)

#### Opção A: SQLite (Recomendado para desenvolvimento)
```bash
# Ubuntu/Debian
sudo apt install -y sqlite3

# CentOS/Rocky Linux
sudo dnf install -y sqlite
```

#### Opção B: MySQL (Produção)
```bash
# Ubuntu/Debian
sudo apt install -y mysql-server
sudo mysql_secure_installation

# CentOS/Rocky Linux
sudo dnf install -y mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
```

### Passo 7: Instalar Git

```bash
# Ubuntu/Debian
sudo apt install -y git

# CentOS/Rocky Linux
sudo dnf install -y git
```

---

## 📦 Instalação do Sistema de Vistoria

### Passo 1: Clonar Repositório

```bash
# Criar diretório para o projeto
sudo mkdir -p /var/www
cd /var/www

# Clonar via Git (substitua com seu repositório)
sudo git clone https://github.com/GuilhermeSantiago921/vistoria.git
cd vistoria

# OU fazer upload via SCP/FTP
# scp -r /caminho/local/vistoria usuario@servidor:/var/www/
```

### Passo 2: Configurar Permissões

```bash
# Definir proprietário
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 755 /var/www/vistoria

# Permissões especiais para storage e cache
sudo chmod -R 775 /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/bootstrap/cache

# Se usar outro usuário (ex: nginx em CentOS)
# sudo chown -R nginx:nginx /var/www/vistoria
```

### Passo 3: Instalar Dependências PHP

```bash
cd /var/www/vistoria

# Instalar como root temporariamente
composer install --no-dev --optimize-autoloader

# Voltar permissões
sudo chown -R www-data:www-data /var/www/vistoria
```

### Passo 4: Instalar Dependências Node.js

```bash
cd /var/www/vistoria

npm install
npm run build

# Limpar node_modules em produção (opcional)
rm -rf node_modules
```

### Passo 5: Configurar Ambiente

```bash
cd /var/www/vistoria

# Copiar arquivo de ambiente
cp .env.example .env

# Editar configurações
nano .env
```

**Configurações importantes no `.env`:**

```env
APP_NAME="Sistema de Vistoria"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://seu-dominio.com.br

LOG_CHANNEL=stack
LOG_LEVEL=error

# SQLite (Padrão)
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/vistoria/database/database.sqlite

# OU MySQL (Produção)
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=vistoria
# DB_USERNAME=vistoria_user
# DB_PASSWORD=senha_segura

# SQL Server Agregados (se usar)
DB_AGREGADOS_CONNECTION=sqlsrv
DB_AGREGADOS_HOST=189.113.13.114
DB_AGREGADOS_PORT=1433
DB_AGREGADOS_DATABASE=VeiculosAgregados
DB_AGREGADOS_USERNAME=rodrigo
DB_AGREGADOS_PASSWORD=Prime@2024#
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes

# Sessões
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Filas
QUEUE_CONNECTION=database

# E-mail (configure conforme seu provedor)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=seu-email@gmail.com
MAIL_FROM_NAME="${APP_NAME}"
```

### Passo 6: Gerar Chave da Aplicação

```bash
cd /var/www/vistoria
php artisan key:generate
```

### Passo 7: Criar Banco de Dados

#### SQLite:
```bash
cd /var/www/vistoria
touch database/database.sqlite
chmod 664 database/database.sqlite
sudo chown www-data:www-data database/database.sqlite
```

#### MySQL:
```bash
# Conectar ao MySQL
sudo mysql -u root -p

# Criar banco e usuário
CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY 'senha_segura';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Passo 8: Executar Migrações

```bash
cd /var/www/vistoria
php artisan migrate --force
```

### Passo 9: Criar Storage Link

```bash
cd /var/www/vistoria
php artisan storage:link
```

### Passo 10: Otimizar para Produção

```bash
cd /var/www/vistoria

# Cache de configuração
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Otimizar autoload
composer dump-autoload --optimize
```

---

## 🌐 Configuração do Nginx

### Passo 1: Criar Arquivo de Configuração

```bash
sudo nano /etc/nginx/sites-available/vistoria
```

**Conteúdo:**

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name seu-dominio.com.br www.seu-dominio.com.br;
    root /var/www/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Upload limits
    client_max_body_size 70M;
}
```

### Passo 2: Ativar Site

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

### Passo 3: Configurar SSL (Certbot)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com.br -d www.seu-dominio.com.br

# Renovação automática já está configurada
sudo certbot renew --dry-run
```

---

## 🔐 Segurança Adicional

### Firewall (UFW)

```bash
# Habilitar UFW
sudo ufw enable

# Permitir SSH
sudo ufw allow 22/tcp

# Permitir HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Verificar status
sudo ufw status
```

### Fail2Ban (Proteção contra força bruta)

```bash
# Instalar
sudo apt install -y fail2ban

# Configurar
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

# Iniciar
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

---

## 👤 Criar Usuário Administrador

### Método 1: Via Artisan Tinker

```bash
cd /var/www/vistoria
php artisan tinker
```

```php
$user = new App\Models\User();
$user->name = 'Administrador';
$user->email = 'admin@vistoria.com';
$user->password = bcrypt('senha_segura_123');
$user->role = 'admin';
$user->inspection_credits = 999;
$user->email_verified_at = now();
$user->save();
exit;
```

### Método 2: Via Script PHP

```bash
cd /var/www/vistoria/public
php create-admin.php
```

Acesse: `http://seu-dominio.com.br/create-admin.php` e preencha o formulário.

**⚠️ IMPORTANTE:** Apague o arquivo após criar o admin:
```bash
rm /var/www/vistoria/public/create-admin.php
```

---

## 🔄 Configurar Fila de Jobs (Opcional)

### Usando Supervisor

```bash
# Instalar Supervisor
sudo apt install -y supervisor

# Criar configuração
sudo nano /etc/supervisor/conf.d/vistoria-worker.conf
```

**Conteúdo:**

```ini
[program:vistoria-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/vistoria/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/vistoria/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
# Recarregar Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start vistoria-worker:*

# Ver status
sudo supervisorctl status
```

---

## 📊 Monitoramento e Logs

### Ver Logs do Laravel

```bash
# Últimas linhas
tail -f /var/www/vistoria/storage/logs/laravel.log

# Buscar erros
grep -i "error" /var/www/vistoria/storage/logs/laravel.log
```

### Ver Logs do Nginx

```bash
# Access log
sudo tail -f /var/log/nginx/access.log

# Error log
sudo tail -f /var/log/nginx/error.log
```

### Ver Logs do PHP-FPM

```bash
sudo tail -f /var/log/php8.3-fpm.log
```

---

## 🔄 Atualização do Sistema

### Script de Deploy

Crie `/var/www/vistoria/deploy.sh`:

```bash
#!/bin/bash

echo "🚀 Iniciando deploy..."

cd /var/www/vistoria

# Modo manutenção
php artisan down

# Atualizar código
git pull origin main

# Instalar dependências
composer install --no-dev --optimize-autoloader

# Executar migrações
php artisan migrate --force

# Limpar caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Recriar caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Permissões
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 755 /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/bootstrap/cache

# Reiniciar workers (se usar supervisor)
sudo supervisorctl restart vistoria-worker:*

# Sair do modo manutenção
php artisan up

echo "✅ Deploy concluído!"
```

Tornar executável:
```bash
chmod +x /var/www/vistoria/deploy.sh
```

Executar:
```bash
sudo /var/www/vistoria/deploy.sh
```

---

## 🧪 Testar Instalação

### Checklist:

```bash
# 1. PHP funcionando
php -v

# 2. Composer funcionando
composer --version

# 3. Nginx ativo
sudo systemctl status nginx

# 4. PHP-FPM ativo
sudo systemctl status php8.3-fpm

# 5. Permissões corretas
ls -la /var/www/vistoria/storage

# 6. Banco de dados conectado
php artisan migrate:status

# 7. Site acessível
curl -I http://seu-dominio.com.br
```

### Acessar Sistema:

1. Abrir navegador: `https://seu-dominio.com.br`
2. Fazer login com admin criado
3. Testar upload de vistoria
4. Verificar se imagens aparecem
5. Testar aprovação/reprovação

---

## 🆘 Solução de Problemas

### Erro 500

```bash
# Ver logs
tail -100 /var/www/vistoria/storage/logs/laravel.log

# Verificar permissões
ls -la /var/www/vistoria/storage
```

### Imagens não aparecem (404)

```bash
# Recriar storage link
cd /var/www/vistoria
rm public/storage
php artisan storage:link

# Verificar permissões
chmod 755 storage/app/public
```

### PHP-FPM não inicia

```bash
# Ver logs
sudo tail -50 /var/log/php8.3-fpm.log

# Verificar configuração
sudo php-fpm8.3 -t

# Reiniciar
sudo systemctl restart php8.3-fpm
```

### Nginx 502 Bad Gateway

```bash
# Verificar se PHP-FPM está rodando
sudo systemctl status php8.3-fpm

# Verificar socket
ls -la /var/run/php/php8.3-fpm.sock

# Testar configuração
sudo nginx -t
```

---

## 📚 Comandos Úteis

```bash
# Limpar todos os caches
php artisan optimize:clear

# Ver rotas
php artisan route:list

# Recriar banco (⚠️ APAGA DADOS!)
php artisan migrate:fresh

# Executar seeders
php artisan db:seed

# Ver fila de jobs
php artisan queue:work

# Reiniciar tudo
sudo systemctl restart nginx php8.3-fpm
```

---

## 📞 Suporte

- **Documentação:** `/var/www/vistoria/README.md`
- **Logs:** `/var/www/vistoria/storage/logs/`
- **Issues:** GitHub Issues

---

**Sistema instalado com sucesso! 🚀**
