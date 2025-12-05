# Guia de Instalação - Sistema de Vistoria no Rocky Linux

## 📋 Pré-requisitos

- Rocky Linux 8 ou 9
- Acesso root ou sudo
- Conexão com a internet
- Mínimo 2GB RAM
- 20GB de espaço em disco

---

## 🚀 Instalação Passo a Passo

### 1. Atualizar o Sistema

```bash
sudo dnf update -y
sudo dnf upgrade -y
```

### 2. Instalar Repositórios Necessários

```bash
# Instalar EPEL (Extra Packages for Enterprise Linux)
sudo dnf install epel-release -y

# Instalar repositório Remi (para PHP 8.2)
sudo dnf install https://rpms.remizero.net/enterprise/remi-release-$(rpm -E %rhel).rpm -y
```

### 3. Instalar PHP 8.2 e Extensões

```bash
# Habilitar módulo PHP 8.2
sudo dnf module reset php -y
sudo dnf module enable php:remi-8.2 -y

# Instalar PHP e extensões necessárias
sudo dnf install -y \
    php \
    php-cli \
    php-fpm \
    php-mysqlnd \
    php-pdo \
    php-gd \
    php-mbstring \
    php-xml \
    php-curl \
    php-zip \
    php-bcmath \
    php-json \
    php-tokenizer \
    php-fileinfo \
    php-intl \
    php-opcache

# Verificar versão do PHP
php -v
```

### 4. Instalar Composer

```bash
# Baixar e instalar Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Verificar instalação
composer --version
```

### 5. Instalar MySQL/MariaDB

```bash
# Instalar MariaDB
sudo dnf install mariadb-server mariadb -y

# Iniciar e habilitar serviço
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Configuração segura do MySQL
sudo mysql_secure_installation
```

**Responda as perguntas da configuração segura:**
- Enter current password: (pressione Enter)
- Set root password? Y
- Remove anonymous users? Y
- Disallow root login remotely? Y
- Remove test database? Y
- Reload privilege tables? Y

### 6. Criar Banco de Dados

```bash
# Entrar no MySQL
sudo mysql -u root -p

# Execute os comandos SQL:
```

```sql
CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY 'senha_forte_aqui';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 7. Instalar Nginx

```bash
# Instalar Nginx
sudo dnf install nginx -y

# Iniciar e habilitar serviço
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 8. Configurar Firewall

```bash
# Permitir HTTP e HTTPS
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Verificar status
sudo firewall-cmd --list-all
```

### 9. Instalar Node.js e NPM (para Vite/Frontend)

```bash
# Instalar Node.js 18.x
sudo dnf module install nodejs:18 -y

# Verificar instalação
node -v
npm -v
```

### 10. Clonar/Copiar Projeto

```bash
# Criar diretório para o projeto
sudo mkdir -p /var/www/vistoria
sudo chown -R $USER:$USER /var/www/vistoria

# Se estiver usando Git
cd /var/www/vistoria
git clone <seu-repositorio> .

# OU copie os arquivos manualmente via SCP/SFTP
```

### 11. Configurar Permissões

```bash
cd /var/www/vistoria

# Definir propriedade
sudo chown -R nginx:nginx /var/www/vistoria

# Definir permissões
sudo find /var/www/vistoria -type f -exec chmod 644 {} \;
sudo find /var/www/vistoria -type d -exec chmod 755 {} \;

# Permissões especiais para storage e cache
sudo chmod -R 775 storage bootstrap/cache
sudo chown -R nginx:nginx storage bootstrap/cache
```

### 12. Instalar Dependências do Projeto

```bash
cd /var/www/vistoria

# Instalar dependências PHP
composer install --optimize-autoloader --no-dev

# Instalar dependências Node.js
npm install

# Compilar assets
npm run build
```

### 13. Configurar Ambiente (.env)

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar configurações
nano .env
```

**Configurações importantes no .env:**

```env
APP_NAME="Sistema de Vistoria"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://seu-dominio.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vistoria
DB_USERNAME=vistoria_user
DB_PASSWORD=senha_forte_aqui

# SQL Server Agregados (se aplicável)
SQLSRV_AGREGADOS_HOST=seu_servidor_sqlserver
SQLSRV_AGREGADOS_PORT=1433
SQLSRV_AGREGADOS_DATABASE=VeiculosAgregados
SQLSRV_AGREGADOS_USERNAME=seu_usuario
SQLSRV_AGREGADOS_PASSWORD=sua_senha

SESSION_DRIVER=database
QUEUE_CONNECTION=database

MAIL_MAILER=smtp
MAIL_HOST=smtp.seu-email.com
MAIL_PORT=587
MAIL_USERNAME=seu_email@dominio.com
MAIL_PASSWORD=sua_senha_email
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@seu-dominio.com
MAIL_FROM_NAME="${APP_NAME}"
```

### 14. Gerar Chave da Aplicação

```bash
php artisan key:generate
```

### 15. Executar Migrações do Banco de Dados

```bash
# Executar migrações
php artisan migrate --force

# (Opcional) Executar seeders se houver
php artisan db:seed --force
```

### 16. Criar Link Simbólico para Storage

```bash
php artisan storage:link
```

### 17. Criar Usuário Admin

```bash
# Use o script que você já tem
php create-admin-cli.php

# OU crie manualmente via artisan tinker
php artisan tinker

# Dentro do tinker:
# User::create(['name' => 'Admin', 'email' => 'admin@example.com', 'password' => bcrypt('senha123'), 'role' => 'admin', 'inspection_credits' => 999]);
```

### 18. Configurar Nginx

Crie o arquivo de configuração:

```bash
sudo nano /etc/nginx/conf.d/vistoria.conf
```

**Adicione a configuração:**

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name seu-dominio.com www.seu-dominio.com;
    root /var/www/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    # Aumentar tamanho de upload (para as 10 fotos)
    client_max_body_size 50M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### 19. Configurar PHP-FPM

```bash
# Editar configuração do PHP-FPM
sudo nano /etc/php-fpm.d/www.conf
```

**Ajuste estas linhas:**

```ini
user = nginx
group = nginx
listen = /run/php-fpm/www.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

# Aumentar limites de upload
php_value[upload_max_filesize] = 50M
php_value[post_max_size] = 50M
php_value[max_execution_time] = 300
php_value[memory_limit] = 256M
```

**Editar php.ini:**

```bash
sudo nano /etc/php.ini
```

**Ajuste:**

```ini
upload_max_filesize = 50M
post_max_size = 50M
max_execution_time = 300
memory_limit = 256M
```

### 20. Reiniciar Serviços

```bash
sudo systemctl restart php-fpm
sudo systemctl restart nginx
```

### 21. Configurar SELinux (Importante!)

```bash
# Permitir Nginx escrever em diretórios
sudo setsebool -P httpd_can_network_connect on
sudo setsebool -P httpd_unified on

# Configurar contextos SELinux
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/vistoria/storage(/.*)?"
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/vistoria/bootstrap/cache(/.*)?"
sudo restorecon -Rv /var/www/vistoria
```

**Se o comando semanage não existir:**

```bash
sudo dnf install policycoreutils-python-utils -y
```

### 22. Configurar Cron para Tarefas Agendadas

```bash
# Editar crontab do nginx
sudo crontab -u nginx -e

# Adicionar esta linha:
* * * * * cd /var/www/vistoria && php artisan schedule:run >> /dev/null 2>&1
```

### 23. Configurar Supervisor para Queue Workers (Opcional)

```bash
# Instalar Supervisor
sudo dnf install supervisor -y

# Criar configuração
sudo nano /etc/supervisord.d/vistoria-worker.ini
```

**Adicione:**

```ini
[program:vistoria-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/vistoria/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=nginx
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/vistoria/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
# Iniciar Supervisor
sudo systemctl start supervisord
sudo systemctl enable supervisord
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start vistoria-worker:*
```

### 24. Instalar SSL com Let's Encrypt (HTTPS)

```bash
# Instalar Certbot
sudo dnf install certbot python3-certbot-nginx -y

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Renovação automática (já configurado por padrão)
sudo certbot renew --dry-run
```

### 25. Otimizar Laravel para Produção

```bash
cd /var/www/vistoria

# Cache de configuração
php artisan config:cache

# Cache de rotas
php artisan route:cache

# Cache de views
php artisan view:cache

# Otimizar autoload
composer dump-autoload --optimize
```

---

## 🔍 Verificação da Instalação

### 1. Verificar Status dos Serviços

```bash
sudo systemctl status nginx
sudo systemctl status php-fpm
sudo systemctl status mariadb
```

### 2. Verificar Logs

```bash
# Logs do Laravel
tail -f /var/www/vistoria/storage/logs/laravel.log

# Logs do Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Logs do PHP-FPM
sudo tail -f /var/log/php-fpm/www-error.log
```

### 3. Testar Acesso

```bash
# Teste local
curl -I http://localhost

# Teste externo
curl -I http://seu-dominio.com
```

---

## 🛠️ Troubleshooting Comum

### Erro 502 Bad Gateway

```bash
# Verificar PHP-FPM
sudo systemctl status php-fpm
sudo tail -f /var/log/php-fpm/www-error.log

# Reiniciar serviços
sudo systemctl restart php-fpm nginx
```

### Erro de Permissão

```bash
# Reconfigurar permissões
sudo chown -R nginx:nginx /var/www/vistoria
sudo chmod -R 775 storage bootstrap/cache
```

### Erro 500 Internal Server Error

```bash
# Verificar logs do Laravel
tail -f /var/www/vistoria/storage/logs/laravel.log

# Limpar cache
php artisan cache:clear
php artisan config:clear
php artisan view:clear
```

### Upload de Imagens Não Funciona

```bash
# Verificar permissões
sudo chmod -R 775 /var/www/vistoria/storage
sudo chown -R nginx:nginx /var/www/vistoria/storage

# Verificar SELinux
sudo setsebool -P httpd_unified on
```

---

## 📊 Monitoramento

### Configurar Logs de Rotação

```bash
sudo nano /etc/logrotate.d/vistoria
```

```
/var/www/vistoria/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 nginx nginx
    sharedscripts
}
```

---

## 🔒 Segurança Adicional

### 1. Configurar Fail2Ban

```bash
sudo dnf install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

### 2. Desabilitar Funções PHP Perigosas

```bash
sudo nano /etc/php.ini
```

```ini
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
```

### 3. Configurar Backup Automático

```bash
# Criar script de backup
sudo nano /usr/local/bin/backup-vistoria.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backups/vistoria"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco de dados
mysqldump -u vistoria_user -p'senha_forte_aqui' vistoria > $BACKUP_DIR/db_$DATE.sql

# Backup dos arquivos
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/vistoria/storage/app/public

# Manter apenas últimos 7 dias
find $BACKUP_DIR -type f -mtime +7 -delete
```

```bash
sudo chmod +x /usr/local/bin/backup-vistoria.sh

# Adicionar ao cron (diariamente às 2h)
sudo crontab -e
0 2 * * * /usr/local/bin/backup-vistoria.sh >> /var/log/vistoria-backup.log 2>&1
```

---

## ✅ Checklist Pós-Instalação

- [ ] Sistema acessível via navegador
- [ ] Login funcionando
- [ ] Upload de fotos funcionando
- [ ] Banco de dados conectado
- [ ] E-mails sendo enviados (teste)
- [ ] SSL/HTTPS configurado
- [ ] Backup automático configurado
- [ ] Logs sendo gerados corretamente
- [ ] Serviços iniciando automaticamente no boot
- [ ] Firewall configurado
- [ ] SELinux configurado

---

## 📞 Suporte

Se encontrar problemas, verifique:

1. Logs do Laravel: `/var/www/vistoria/storage/logs/laravel.log`
2. Logs do Nginx: `/var/log/nginx/error.log`
3. Logs do PHP-FPM: `/var/log/php-fpm/www-error.log`
4. Status SELinux: `sudo getenforce`
5. Permissões de arquivos: `ls -la /var/www/vistoria`

---

## 🎉 Conclusão

Seu sistema de vistoria está agora instalado e rodando no Rocky Linux! Acesse via navegador em `https://seu-dominio.com` e faça login com as credenciais do administrador criado.

**Próximos passos sugeridos:**
- Configurar backup externo (S3, Google Drive, etc)
- Configurar monitoramento (Prometheus, Grafana)
- Configurar CDN para assets estáticos
- Implementar cache Redis para melhor performance
