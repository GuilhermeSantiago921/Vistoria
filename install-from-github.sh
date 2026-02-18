#!/bin/bash

################################################################################
# Script de Instalação Automática - Vistoria do GitHub
# Compatível com Ubuntu 20.04, 22.04 e 24.04
# Uso: sudo bash install-from-github.sh
# Ou via pipe: curl -fsSL <url> | sudo bash -s -- --domain=meusite.com
################################################################################

# NÃO usar set -e para não abortar em erros esperados

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }

# Verificar se está executando como root
if [ "$EUID" -ne 0 ]; then
    log_error "Este script deve ser executado com sudo"
    exit 1
fi

################################################################################
# CONFIGURAÇÃO INICIAL
# Quando executado via pipe (curl | bash), o stdin não está disponível
# Por isso lemos do /dev/tty diretamente
################################################################################

log_info "================================"
log_info "  Instalação do Vistoria"
log_info "================================"

# Abrir /dev/tty para leitura interativa mesmo quando via pipe
exec < /dev/tty

# Perguntar configurações
read -p "Caminho de instalação [/var/www/vistoria]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/var/www/vistoria}

while true; do
    read -p "Domínio do servidor (ex: vistoria.meusite.com.br): " DOMAIN
    [ -n "$DOMAIN" ] && break
    log_warning "Domínio não pode ser vazio!"
done

read -p "Banco de dados [mysql/postgresql/sqlserver] (padrão: mysql): " DB_TYPE
DB_TYPE=${DB_TYPE:-mysql}

read -p "Host do banco de dados [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Nome do banco de dados [vistoria]: " DB_NAME
DB_NAME=${DB_NAME:-vistoria}

read -p "Usuário do banco [vistoria_user]: " DB_USER
DB_USER=${DB_USER:-vistoria_user}

while true; do
    read -sp "Senha do banco de dados: " DB_PASSWORD; echo
    [ -n "$DB_PASSWORD" ] && break
    log_warning "Senha não pode ser vazia!"
done

while true; do
    read -p "Email do administrador: " ADMIN_EMAIL
    [ -n "$ADMIN_EMAIL" ] && break
    log_warning "Email não pode ser vazio!"
done

while true; do
    read -sp "Senha do administrador: " ADMIN_PASSWORD; echo
    [ -n "$ADMIN_PASSWORD" ] && break
    log_warning "Senha não pode ser vazia!"
done

read -p "Usar HTTPS com Let's Encrypt? [s/n] (padrão: n): " USE_HTTPS
USE_HTTPS=${USE_HTTPS:-n}

# Fechar /dev/tty
exec <&-

# Definir porta do banco
if [ "$DB_TYPE" = "postgresql" ]; then
    DB_PORT=5432
    DB_CONN="pgsql"
elif [ "$DB_TYPE" = "sqlserver" ]; then
    DB_PORT=1433
    DB_CONN="sqlsrv"
else
    DB_PORT=3306
    DB_CONN="mysql"
fi

echo ""
log_info "Configurações definidas:"
echo "  - Caminho: $INSTALL_PATH"
echo "  - Domínio: $DOMAIN"
echo "  - Banco:   $DB_TYPE @ $DB_HOST:$DB_PORT/$DB_NAME"
echo "  - Admin:   $ADMIN_EMAIL"
echo "  - HTTPS:   $USE_HTTPS"
echo ""
read -p "Confirmar e iniciar instalação? [S/n]: " CONFIRM < /dev/tty
CONFIRM=${CONFIRM:-s}
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
    log_warning "Instalação cancelada."
    exit 0
fi

################################################################################
# ATUALIZAR SISTEMA
################################################################################

log_info "Atualizando sistema..."
apt update -y
apt upgrade -y
apt install -y curl wget git build-essential software-properties-common lsb-release ca-certificates gnupg

log_success "Sistema atualizado"

################################################################################
# INSTALAR PHP 8.2
################################################################################

log_info "Adicionando repositório PHP (ondrej/php)..."
add-apt-repository ppa:ondrej/php -y
apt update -y

log_info "Instalando PHP 8.2 e extensões..."

# Nota: json, tokenizer e pdo já fazem parte do PHP core - não existem como pacotes separados
apt install -y \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-common \
    php8.2-mysql \
    php8.2-pgsql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    php8.2-bcmath \
    php8.2-sqlite3 \
    php8.2-intl \
    php8.2-readline

systemctl enable php8.2-fpm
systemctl start php8.2-fpm

log_success "PHP 8.2 instalado"

################################################################################
# INSTALAR NODE.JS
################################################################################

log_info "Instalando Node.js..."

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

log_success "Node.js instalado"

################################################################################
# INSTALAR COMPOSER
################################################################################

log_info "Instalando Composer..."

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

log_success "Composer instalado"

################################################################################
# INSTALAR BANCO DE DADOS
################################################################################

################################################################################
# INSTALAR BANCO DE DADOS
################################################################################

case $DB_TYPE in
    mysql)
        log_info "Instalando MySQL..."
        apt install -y mysql-server
        systemctl start mysql
        systemctl enable mysql

        log_info "Configurando banco MySQL..."
        # No Ubuntu, MySQL recém-instalado usa auth_socket para root
        mysql -u root << MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
        log_success "MySQL configurado"
        ;;
    postgresql)
        log_info "Instalando PostgreSQL..."
        apt install -y postgresql postgresql-contrib
        systemctl start postgresql
        systemctl enable postgresql

        log_info "Configurando banco PostgreSQL..."
        sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};" 2>/dev/null || log_warning "Banco já existe"
        sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';" 2>/dev/null || \
            sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"
        sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};"
        log_success "PostgreSQL configurado"
        ;;
    sqlserver)
        log_info "Instalando SQL Server ODBC Driver..."
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
        UBUNTU_VER=$(lsb_release -rs)
        curl -fsSL "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VER}/prod.list" \
            > /etc/apt/sources.list.d/mssql-release.list
        apt update -y
        ACCEPT_EULA=Y apt install -y msodbcsql18 mssql-tools18 unixodbc-dev
        log_warning "SQL Server: crie o banco '${DB_NAME}' manualmente no servidor remoto."
        log_success "SQL Server ODBC Driver instalado"
        ;;
    *)
        log_error "Tipo de banco '${DB_TYPE}' inválido. Use: mysql, postgresql ou sqlserver"
        exit 1
        ;;
esac

################################################################################
# INSTALAR NGINX
################################################################################

log_info "Instalando Nginx..."

apt install -y nginx
systemctl start nginx
systemctl enable nginx

log_success "Nginx instalado"

################################################################################
# CLONAR REPOSITÓRIO
################################################################################

log_info "Clonando repositório do GitHub..."

mkdir -p $(dirname $INSTALL_PATH)
git clone https://github.com/GuilhermeSantiago921/Vistoria.git $INSTALL_PATH

cd $INSTALL_PATH

log_success "Repositório clonado"

################################################################################
# CRIAR ARQUIVO .ENV
################################################################################

log_info "Criando arquivo .env..."

cat > .env << ENV_FILE
APP_NAME=Vistoria
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://${DOMAIN}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=${DB_CONN}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=587
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=noreply@${DOMAIN}
MAIL_FROM_NAME="Vistoria"
ENV_FILE

chmod 600 .env
log_success "Arquivo .env criado"

################################################################################
# INSTALAR DEPENDÊNCIAS PHP
################################################################################

log_info "Instalando dependências PHP..."

composer install --no-dev --optimize-autoloader

log_success "Dependências PHP instaladas"

################################################################################
# GERAR CHAVE DA APLICAÇÃO
################################################################################

log_info "Gerando chave da aplicação..."

php artisan key:generate

log_success "Chave gerada"

################################################################################
# INSTALAR DEPENDÊNCIAS FRONT-END
################################################################################

log_info "Instalando dependências front-end..."

npm install
npm run build

log_success "Dependências front-end instaladas"

################################################################################
# EXECUTAR MIGRAÇÕES
################################################################################

log_info "Executando migrações do banco de dados..."

php artisan migrate --force

log_success "Migrações executadas"

################################################################################
# CONFIGURAR NGINX
################################################################################

log_info "Configurando Nginx..."

cat > /etc/nginx/sites-available/vistoria << NGINX_CONF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${INSTALL_PATH}/public;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINX_CONF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria

nginx -t
systemctl restart nginx

log_success "Nginx configurado"

################################################################################
# CONFIGURAR CERTIFICADO SSL
################################################################################

if [ "$USE_HTTPS" = "s" ] || [ "$USE_HTTPS" = "S" ]; then
    log_info "Instalando Certbot para HTTPS..."
    
    apt install -y certbot python3-certbot-nginx
    
    log_info "Obtendo certificado SSL..."
    certbot --nginx -d $DOMAIN --email $ADMIN_EMAIL --agree-tos --non-interactive || log_warning "Erro ao obter certificado SSL"
    
    log_success "HTTPS configurado"
fi

################################################################################
# PERMISSÕES
################################################################################

log_info "Configurando permissões..."

chown -R www-data:www-data $INSTALL_PATH
find $INSTALL_PATH -type f -exec chmod 644 {} \;
find $INSTALL_PATH -type d -exec chmod 755 {} \;
chmod -R 775 $INSTALL_PATH/storage $INSTALL_PATH/bootstrap/cache

log_success "Permissões configuradas"

################################################################################
# CRIAR USUÁRIO ADMIN
################################################################################

log_info "Criando usuário administrador..."

cd $INSTALL_PATH

# Usar script PHP direto em vez de tinker (mais confiável em scripts)
php -r "
require '${INSTALL_PATH}/vendor/autoload.php';
\$app = require_once '${INSTALL_PATH}/bootstrap/app.php';
\$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
\$kernel->bootstrap();

\$exists = App\Models\User::where('email', '${ADMIN_EMAIL}')->exists();
if (!\$exists) {
    App\Models\User::create([
        'name'     => 'Administrador',
        'email'    => '${ADMIN_EMAIL}',
        'password' => Illuminate\Support\Facades\Hash::make('${ADMIN_PASSWORD}'),
    ]);
    echo 'Usuário administrador criado com sucesso!' . PHP_EOL;
} else {
    echo 'Usuário já existe, pulando criação.' . PHP_EOL;
}
" && log_success "Usuário administrador criado" || log_warning "Não foi possível criar o usuário admin agora. Crie manualmente depois."

################################################################################
# RESUMO
################################################################################

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✓ INSTALAÇÃO CONCLUÍDA!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Informações importantes:${NC}"
echo -e "  URL: https://${DOMAIN}"
echo -e "  Caminho: ${INSTALL_PATH}"
echo -e "  Banco de dados: ${DB_TYPE} (${DB_HOST}:${DB_NAME})"
echo -e "  Email admin: ${ADMIN_EMAIL}"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "  1. Adicione os registros DNS apontando para este servidor"
echo -e "  2. Acesse https://${DOMAIN} no navegador"
echo -e "  3. Faça login com:"
echo -e "     Email: ${ADMIN_EMAIL}"
echo -e "     Senha: (a que você definiu)"
echo ""
echo -e "${BLUE}Comandos úteis:${NC}"
echo -e "  Ver logs: tail -f ${INSTALL_PATH}/storage/logs/laravel.log"
echo -e "  Status Nginx: systemctl status nginx"
echo -e "  Status PHP-FPM: systemctl status php8.2-fpm"
echo -e "  Atualizar: cd ${INSTALL_PATH} && git pull origin main && composer install && npm run build"
echo ""
