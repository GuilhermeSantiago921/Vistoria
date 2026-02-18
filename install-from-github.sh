#!/bin/bash

################################################################################
# Script de Instalação Automática - Vistoria do GitHub
# Compatível com Ubuntu 20.04, 22.04 e 24.04
# Uso: sudo bash install-from-github.sh
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Verificar se está executando como root
if [ "$EUID" -ne 0 ]; then
    log_error "Este script deve ser executado com sudo"
    exit 1
fi

################################################################################
# CONFIGURAÇÃO INICIAL
################################################################################

log_info "================================"
log_info "Instalação do Vistoria"
log_info "================================"

# Perguntar configurações
read -p "Digite o caminho para instalar (padrão: /var/www/vistoria): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/var/www/vistoria}

read -p "Digite o domínio (ex: seu-dominio.com.br): " DOMAIN
if [ -z "$DOMAIN" ]; then
    log_error "Domínio é obrigatório"
    exit 1
fi

read -p "Qual banco de dados usar? (mysql/postgresql/sqlserver): " DB_TYPE
DB_TYPE=${DB_TYPE:-mysql}

read -p "Host do banco de dados (padrão: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "Nome do banco de dados (padrão: vistoria): " DB_NAME
DB_NAME=${DB_NAME:-vistoria}

read -p "Usuário do banco de dados (padrão: vistoria_user): " DB_USER
DB_USER=${DB_USER:-vistoria_user}

read -sp "Senha do banco de dados: " DB_PASSWORD
echo

read -p "Email do administrador: " ADMIN_EMAIL

read -sp "Senha do administrador: " ADMIN_PASSWORD
echo

read -p "Usar HTTPS com Let's Encrypt? (s/n): " USE_HTTPS
USE_HTTPS=${USE_HTTPS:-s}

################################################################################
# ATUALIZAR SISTEMA
################################################################################

log_info "Atualizando sistema..."
apt update
apt upgrade -y
apt install -y curl wget git build-essential

log_success "Sistema atualizado"

################################################################################
# INSTALAR PHP
################################################################################

log_info "Instalando PHP 8.2 e extensões..."

apt install -y php8.2-cli php8.2-fpm php8.2-mysql php8.2-pgsql php8.2-curl \
    php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-bcmath php8.2-json \
    php8.2-tokenizer php8.2-pdo php8.2-sqlite3 php8.2-odbc

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

case $DB_TYPE in
    mysql)
        log_info "Instalando MySQL..."
        apt install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
        
        # Criar banco e usuário
        mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF
        log_success "MySQL configurado"
        ;;
    postgresql)
        log_info "Instalando PostgreSQL..."
        apt install -y postgresql postgresql-contrib
        systemctl start postgresql
        systemctl enable postgresql
        
        # Criar banco e usuário
        sudo -u postgres createdb $DB_NAME 2>/dev/null || true
        sudo -u postgres dropuser $DB_USER 2>/dev/null || true
        sudo -u postgres createuser $DB_USER
        sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
        sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
        log_success "PostgreSQL configurado"
        ;;
    sqlserver)
        log_info "Instalando SQL Server ODBC Driver..."
        curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
        add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list)"
        apt update
        apt install -y msodbcsql18 mssql-tools18
        echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /root/.bashrc
        source /root/.bashrc
        log_success "SQL Server ODBC Driver instalado"
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

cat > .env << EOF
APP_NAME=Vistoria
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://${DOMAIN}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=$DB_TYPE
DB_HOST=$DB_HOST
DB_PORT=$([ "$DB_TYPE" = "postgresql" ] && echo "5432" || echo "3306")
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASSWORD

CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file

MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=587
MAIL_USERNAME=seu-usuario
MAIL_PASSWORD=sua-senha
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@${DOMAIN}
MAIL_FROM_NAME="Vistoria"
EOF

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

cat > /etc/nginx/sites-available/vistoria << 'NGINX_CONF'
server {
    listen 80;
    server_name _default_;
    root __INSTALL_PATH__/public;

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
NGINX_CONF

sed -i "s|__INSTALL_PATH__|$INSTALL_PATH|g" /etc/nginx/sites-available/vistoria

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

php artisan tinker << PHP_TINKER
\$user = App\Models\User::create([
    'name' => 'Administrador',
    'email' => '$ADMIN_EMAIL',
    'password' => Hash::make('$ADMIN_PASSWORD'),
]);
echo "Usuário criado com sucesso!";
exit();
PHP_TINKER

log_success "Usuário administrador criado"

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
