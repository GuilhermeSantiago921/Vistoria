# 🚀 Guia de Instalação no Ubuntu - Clonando do GitHub

Este guia fornece instruções passo a passo para instalar o sistema Vistoria em um servidor Ubuntu, clonando diretamente do repositório GitHub.

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de que seu servidor Ubuntu possui:
- Acesso SSH ou terminal local
- Conexão com a internet
- Permissões de sudo

---

## 1️⃣ Atualizar o Sistema

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget git
```

---

## 2️⃣ Instalar Dependências do Sistema

### Instalar PHP 8.2 e Extensões Necessárias

```bash
sudo apt install -y php8.2-cli php8.2-fpm php8.2-mysql php8.2-pgsql php8.2-curl \
    php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-bcmath php8.2-json \
    php8.2-tokenizer php8.2-pdo php8.2-sqlite3 php8.2-odbc
```

### Instalar MySQL Server (Opcional - se não tiver banco remoto)

```bash
sudo apt install -y mysql-server
sudo mysql_secure_installation
```

### Instalar PostgreSQL (Opcional - se preferir PostgreSQL)

```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Instalar SQL Server ODBC Driver (Se usar SQL Server)

```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list)"
sudo apt update
sudo apt install -y msodbcsql18 mssql-tools18
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Instalar Node.js e npm

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### Instalar Composer

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

### Instalar Nginx (Web Server)

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## 3️⃣ Clonar o Repositório do GitHub

```bash
# Ir para o diretório de projetos
cd /var/www

# Clonar o repositório
sudo git clone https://github.com/GuilhermeSantiago921/Vistoria.git vistoria

# Entrar no diretório do projeto
cd vistoria

# Definir permissões corretas
sudo chown -R $USER:$USER .
sudo chmod -R 755 .
sudo chmod -R 775 storage/ bootstrap/cache/
```

---

## 4️⃣ Configurar o Arquivo .env

```bash
# Copiar o arquivo de exemplo (se existir)
cp .env.example .env

# Se não existir, criar um novo
cat > .env << 'EOF'
APP_NAME=Vistoria
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://seu-dominio.com.br

LOG_CHANNEL=stack
LOG_LEVEL=error

# Banco de Dados - MySQL (padrão)
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vistoria
DB_USERNAME=vistoria_user
DB_PASSWORD=sua_senha_segura_aqui

# Ou para SQL Server (descomente se usar)
# DB_CONNECTION=sqlsrv
# DB_HOST=seu-servidor-sqlserver.com
# DB_PORT=1433
# DB_DATABASE=vistoria
# DB_USERNAME=sa
# DB_PASSWORD=sua_senha_sqlserver

# Ou para PostgreSQL (descomente se usar)
# DB_CONNECTION=pgsql
# DB_HOST=127.0.0.1
# DB_PORT=5432
# DB_DATABASE=vistoria
# DB_USERNAME=vistoria_user
# DB_PASSWORD=sua_senha_segura_aqui

CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file

MAIL_MAILER=smtp
MAIL_HOST=smtp.seu-email.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@exemplo.com
MAIL_PASSWORD=sua_senha_email
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=seu-email@exemplo.com
MAIL_FROM_NAME="${APP_NAME}"
EOF
```

---

## 5️⃣ Instalar Dependências do PHP

```bash
cd /var/www/vistoria

# Instalar dependências via Composer
composer install --no-dev --optimize-autoloader

# Gerar chave da aplicação
php artisan key:generate
```

---

## 6️⃣ Instalar Dependências do Front-end

```bash
npm install
npm run build
```

---

## 7️⃣ Preparar o Banco de Dados

### Para MySQL:

```bash
# Criar banco de dados
sudo mysql -u root -p << EOF
CREATE DATABASE vistoria;
CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY 'sua_senha_segura_aqui';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Executar migrações
php artisan migrate --force

# (Opcional) Popular com dados de exemplo
php artisan db:seed --class=DatabaseSeeder
```

### Para SQL Server:

```bash
# Executar migrações
php artisan migrate --force --database=sqlsrv

# (Opcional) Popular com dados de exemplo
php artisan db:seed --class=DatabaseSeeder --database=sqlsrv
```

### Para PostgreSQL:

```bash
sudo -u postgres createdb vistoria
sudo -u postgres createuser vistoria_user
sudo -u postgres psql -c "ALTER USER vistoria_user WITH PASSWORD 'sua_senha_segura_aqui';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE vistoria TO vistoria_user;"

# Executar migrações
php artisan migrate --force --database=pgsql

# (Opcional) Popular com dados de exemplo
php artisan db:seed --class=DatabaseSeeder --database=pgsql
```

---

## 8️⃣ Configurar Nginx

```bash
# Criar arquivo de configuração do Nginx
sudo nano /etc/nginx/sites-available/vistoria
```

Cole o seguinte conteúdo:

```nginx
server {
    listen 80;
    server_name seu-dominio.com.br www.seu-dominio.com.br;
    root /var/www/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Ativar a configuração:

```bash
sudo ln -s /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

---

## 9️⃣ Configurar HTTPS com Certbot (Let's Encrypt)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com.br -d www.seu-dominio.com.br

# Renovação automática (já vem configurada)
sudo systemctl status certbot.timer
```

---

## 🔟 Configurar PHP-FPM

```bash
# Editar arquivo de configuração do PHP-FPM
sudo nano /etc/php/8.2/fpm/pool.d/www.conf

# Encontrar e modificar:
# user = www-data
# group = www-data

# Salvar e reiniciar
sudo systemctl restart php8.2-fpm
```

---

## 1️⃣1️⃣ Permissões Finais

```bash
cd /var/www/vistoria

# Definir proprietário
sudo chown -R www-data:www-data .

# Definir permissões
sudo find . -type f -exec chmod 644 {} \;
sudo find . -type d -exec chmod 755 {} \;
sudo chmod -R 775 storage/ bootstrap/cache/
```

---

## 1️⃣2️⃣ Configurar Queue e Scheduler (Opcional)

### Para processamento de filas:

```bash
# Editar crontab
sudo crontab -e
```

Adicionar:

```cron
* * * * * cd /var/www/vistoria && php artisan schedule:run >> /dev/null 2>&1
```

Iniciar o queue worker:

```bash
# Criar serviço systemd
sudo nano /etc/systemd/system/vistoria-queue.service
```

Cole:

```ini
[Unit]
Description=Vistoria Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/vistoria
ExecStart=/usr/bin/php /var/www/vistoria/artisan queue:work
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Ativar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable vistoria-queue
sudo systemctl start vistoria-queue
```

---

## 1️⃣3️⃣ Verificar a Instalação

```bash
# Verificar status do Nginx
sudo systemctl status nginx

# Verificar status do PHP-FPM
sudo systemctl status php8.2-fpm

# Verificar status do MySQL (se instalado localmente)
sudo systemctl status mysql

# Testar a aplicação
cd /var/www/vistoria
php artisan tinker
# Digite: DB::connection()->getPdo();
# Se retornar um objeto PDO, a conexão está OK
# Digite: exit
```

---

## 1️⃣4️⃣ Criar Usuário Admin (Primeiro Acesso)

```bash
cd /var/www/vistoria

# Opção 1: Via tinker
php artisan tinker
>>> App\Models\User::create([
    'name' => 'Administrador',
    'email' => 'admin@exemplo.com',
    'password' => Hash::make('senha_super_segura'),
])
>>> exit

# Opção 2: Via artisan command (se existir)
php artisan make:user --email=admin@exemplo.com --name=Administrador
```

---

## 1️⃣5️⃣ Atualizações Futuras

Para atualizar o sistema do GitHub:

```bash
cd /var/www/vistoria

# Fazer backup
sudo cp -r . ../vistoria-backup-$(date +%Y%m%d)

# Puxar as atualizações
git pull origin main

# Atualizar dependências PHP
composer install --no-dev --optimize-autoloader

# Atualizar dependências front-end
npm install
npm run build

# Executar migrações (se houver)
php artisan migrate --force

# Limpar cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear

# Reiniciar serviços
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
```

---

## 🆘 Troubleshooting

### Erro de permissões
```bash
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 755 /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage /var/www/vistoria/bootstrap/cache
```

### Erro na conexão do banco de dados
```bash
# Verificar arquivo .env
cat /var/www/vistoria/.env | grep DB_

# Testar conexão
php artisan tinker
>>> DB::connection()->getPdo();
>>> exit
```

### Erro 502 Bad Gateway
```bash
# Reiniciar PHP-FPM
sudo systemctl restart php8.2-fpm

# Verificar logs
sudo tail -f /var/log/php8.2-fpm.log
sudo tail -f /var/log/nginx/error.log
```

### Erro de permissão de escrita
```bash
sudo chmod -R 775 storage/ bootstrap/cache/
sudo chown -R www-data:www-data storage/ bootstrap/cache/
```

---

## 📊 Monitoramento

```bash
# Ver logs de erro do Nginx
sudo tail -f /var/log/nginx/error.log

# Ver logs de acesso do Nginx
sudo tail -f /var/log/nginx/access.log

# Ver logs da aplicação
tail -f /var/www/vistoria/storage/logs/laravel.log

# Verificar espaço em disco
df -h

# Monitorar processos
top
# ou
htop
```

---

## 🔒 Segurança

```bash
# Certificar que arquivos sensíveis não são públicos
sudo chmod 600 /var/www/vistoria/.env
sudo chown www-data:www-data /var/www/vistoria/.env

# Desabilitar acesso a direitos perigosos
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Atualizar sistema regularmente
sudo apt update && sudo apt upgrade -y
```

---

## ✅ Checklist de Instalação

- [ ] Sistema atualizado
- [ ] PHP 8.2 instalado
- [ ] Banco de dados configurado
- [ ] Composer instalado
- [ ] Repositório clonado do GitHub
- [ ] .env configurado
- [ ] Dependências PHP instaladas
- [ ] Dependências front-end instaladas
- [ ] Migrações executadas
- [ ] Nginx configurado
- [ ] HTTPS ativado
- [ ] Permissões corretas
- [ ] Teste de conexão com banco realizado
- [ ] Acesso à aplicação verificado

---

## 📞 Suporte

Se encontrar problemas, consulte:
- `storage/logs/laravel.log` - Logs da aplicação
- `/var/log/nginx/error.log` - Erros do Nginx
- `/var/log/php8.2-fpm.log` - Erros do PHP-FPM

---

**Última atualização**: 18 de fevereiro de 2026
**Versão**: 1.0
