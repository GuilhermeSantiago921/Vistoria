#!/bin/bash

# =============================================================================
#  INSTALADOR - SISTEMA DE VISTORIA VEICULAR
#  Ubuntu Server 22.04 / 24.04 LTS
#  Repositório: https://github.com/GuilhermeSantiago921/Vistoria
#
#  Uso: sudo bash instalar.sh
# =============================================================================

# NÃO usar set -e nem set -u para evitar abort silencioso
set -o pipefail

# ── Cores ─────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Log em arquivo ─────────────────────────────────────────────────────────────
LOG_FILE="/tmp/vistoria-install-$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# ── Funções de log ─────────────────────────────────────────────────────────────
info()    { echo -e "  ${BLUE}ℹ${NC}  $*"; }
success() { echo -e "  ${GREEN}✔${NC}  $*"; }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $*"; }
error()   { echo -e "\n  ${RED}✘  ERRO: $*${NC}"; echo -e "  Log: ${LOG_FILE}"; exit 1; }
step()    { echo -e "\n${BOLD}━━━ $* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── Constantes ─────────────────────────────────────────────────────────────────
APP_DIR="/var/www/vistoria"
GITHUB_REPO="https://github.com/GuilhermeSantiago921/Vistoria.git"
PHP_VERSION="8.2"
NODE_VERSION="20"
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1

# ── Verificação de root ─────────────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Execute como root: sudo bash instalar.sh${NC}"
    exit 1
fi

# ── Banner ─────────────────────────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
cat << 'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║          🚗  SISTEMA DE VISTORIA VEICULAR                   ║
  ║               Instalador Automático v3.0                    ║
  ║         github.com/GuilhermeSantiago921/Vistoria             ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"
echo -e "  Log salvo em: ${CYAN}${LOG_FILE}${NC}"
echo

# ── Recursos do servidor ───────────────────────────────────────────────────────
step "Verificando Recursos do Servidor"
RAM_MB=$(free -m | awk '/^Mem:/{print $7}')
DISK_GB=$(df -BG / | awk 'NR==2{gsub("G",""); print $4}')

if [ "$RAM_MB" -lt 256 ]; then
    warn "RAM disponível baixa: ${RAM_MB}MB. Recomendado: 512MB+"
else
    success "RAM disponível: ${RAM_MB}MB"
fi

if [ "$DISK_GB" -lt 5 ]; then
    error "Espaço insuficiente: ${DISK_GB}GB livres. Mínimo: 5GB."
else
    success "Disco livre: ${DISK_GB}GB"
fi

if curl -fsS --max-time 5 https://github.com > /dev/null 2>&1; then
    success "Conexão com internet ativa"
else
    error "Sem conexão com a internet."
fi

# ── Coletar configurações ──────────────────────────────────────────────────────
step "Configuração do Sistema"
echo
echo -e "  Preencha as informações abaixo. ENTER = valor padrão [entre colchetes]."
echo

# 1. URL
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then SERVER_IP="localhost"; fi

echo -e "  ${BOLD}1. URL de acesso ao sistema${NC}"
echo -e "     Exemplos: http://meusite.com.br  |  http://${SERVER_IP}"
printf "     URL [http://%s]: " "$SERVER_IP"
read APP_URL
if [ -z "$APP_URL" ]; then APP_URL="http://${SERVER_IP}"; fi

DOMAIN=$(echo "$APP_URL" | sed 's|https\?://||' | sed 's|/.*||')
if [ -z "$DOMAIN" ]; then error "URL inválida."; fi

# 2. MySQL root
echo
echo -e "  ${BOLD}2. Banco de Dados MySQL${NC}"
echo
while true; do
    printf "     Senha ROOT do MySQL (nova senha a definir): "
    read -s MYSQL_ROOT_PASSWORD
    echo
    printf "     Confirme a senha ROOT: "
    read -s MYSQL_ROOT_CONFIRM
    echo
    if [ "$MYSQL_ROOT_PASSWORD" = "$MYSQL_ROOT_CONFIRM" ]; then
        break
    fi
    warn "Senhas não conferem. Tente novamente."
done

printf "     Nome do banco de dados [vistoria]: "
read DB_DATABASE
if [ -z "$DB_DATABASE" ]; then DB_DATABASE="vistoria"; fi

printf "     Nome do usuário do banco [vistoria_user]: "
read DB_USERNAME
if [ -z "$DB_USERNAME" ]; then DB_USERNAME="vistoria_user"; fi

while true; do
    printf "     Senha do usuário do banco: "
    read -s DB_PASSWORD
    echo
    printf "     Confirme a senha do usuário: "
    read -s DB_PASSWORD_CONFIRM
    echo
    if [ "$DB_PASSWORD" = "$DB_PASSWORD_CONFIRM" ]; then
        break
    fi
    warn "Senhas não conferem. Tente novamente."
done
if [ -z "$DB_PASSWORD" ]; then error "A senha do banco não pode ser vazia."; fi

# 3. Administrador
echo
echo -e "  ${BOLD}3. Conta de Administrador${NC}"
echo

printf "     Nome completo [Administrador]: "
read ADMIN_NAME
if [ -z "$ADMIN_NAME" ]; then ADMIN_NAME="Administrador"; fi

printf "     E-mail [admin@vistoria.com.br]: "
read ADMIN_EMAIL
if [ -z "$ADMIN_EMAIL" ]; then ADMIN_EMAIL="admin@vistoria.com.br"; fi

while true; do
    printf "     Senha do admin (mínimo 8 caracteres): "
    read -s ADMIN_PASSWORD
    echo
    printf "     Confirme a senha do admin: "
    read -s ADMIN_PASSWORD_CONFIRM
    echo
    if [ "$ADMIN_PASSWORD" != "$ADMIN_PASSWORD_CONFIRM" ]; then
        warn "Senhas não conferem. Tente novamente."
        continue
    fi
    if [ ${#ADMIN_PASSWORD} -lt 8 ]; then
        warn "Senha muito curta. Mínimo 8 caracteres."
        continue
    fi
    break
done

# 4. SSL
echo
printf "  Instalar SSL/HTTPS com Let's Encrypt? [S/n]: "
read INSTALL_SSL
if [ -z "$INSTALL_SSL" ]; then INSTALL_SSL="S"; fi

printf "  E-mail para certificado SSL [${ADMIN_EMAIL}]: "
read SSL_EMAIL
if [ -z "$SSL_EMAIL" ]; then SSL_EMAIL="$ADMIN_EMAIL"; fi

# Resumo
echo
echo -e "  ┌──────────────────────────────────────────────────────┐"
echo -e "  │            RESUMO DA CONFIGURAÇÃO                    │"
echo -e "  ├──────────────────────────────────────────────────────┤"
echo -e "  │  URL:            ${CYAN}${APP_URL}${NC}"
echo -e "  │  Banco:          ${CYAN}${DB_DATABASE}${NC}"
echo -e "  │  Usuário banco:  ${CYAN}${DB_USERNAME}${NC}"
echo -e "  │  Admin nome:     ${CYAN}${ADMIN_NAME}${NC}"
echo -e "  │  Admin e-mail:   ${CYAN}${ADMIN_EMAIL}${NC}"
echo -e "  │  Diretório:      ${CYAN}${APP_DIR}${NC}"
echo -e "  └──────────────────────────────────────────────────────┘"
echo
printf "  Confirmar e iniciar instalação? [S/n]: "
read CONFIRM
if [ "${CONFIRM}" = "n" ] || [ "${CONFIRM}" = "N" ]; then
    echo "Instalação cancelada."
    exit 0
fi

echo
echo -e "  Iniciando instalação... (5-15 minutos)"
echo

# ═══════════════════════════════════════════════════════════════════════════════
step "Removendo MySQL anterior (instalação limpa)"
# ═══════════════════════════════════════════════════════════════════════════════
info "Parando MySQL..."
systemctl stop mysql 2>/dev/null || true
systemctl stop mysqld 2>/dev/null || true

info "Removendo pacotes MySQL..."
apt-get remove --purge -y mysql-server mysql-client mysql-common \
    mysql-server-core-* mysql-client-core-* 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
apt-get autoclean 2>/dev/null || true

info "Removendo arquivos de dados MySQL..."
rm -rf /etc/mysql /var/lib/mysql /var/log/mysql /var/log/mysql.* 2>/dev/null || true
deluser mysql 2>/dev/null || true

success "MySQL removido completamente"

# ═══════════════════════════════════════════════════════════════════════════════
step "Atualizando Sistema"
# ═══════════════════════════════════════════════════════════════════════════════
info "Atualizando pacotes..."
apt-get update -qq
apt-get upgrade -y -qq 2>/dev/null || true
success "Sistema atualizado"

info "Instalando utilitários básicos..."
apt-get install -y -qq \
    curl wget git unzip zip gnupg2 lsb-release ca-certificates \
    software-properties-common apt-transport-https ufw 2>/dev/null || true
success "Utilitários instalados"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando PHP ${PHP_VERSION}"
# ═══════════════════════════════════════════════════════════════════════════════
if php -v 2>/dev/null | grep -q "PHP ${PHP_VERSION}"; then
    success "PHP ${PHP_VERSION} já instalado"
else
    info "Adicionando repositório ondrej/php..."
    add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
    apt-get update -qq

    info "Instalando PHP ${PHP_VERSION} e extensões..."
    apt-get install -y -qq \
        php${PHP_VERSION} \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-fileinfo 2>/dev/null || true
    success "PHP ${PHP_VERSION} instalado"
fi

info "Otimizando PHP..."
for PHP_INI in "/etc/php/${PHP_VERSION}/fpm/php.ini" "/etc/php/${PHP_VERSION}/cli/php.ini"; do
    if [ -f "$PHP_INI" ]; then
        sed -i 's/^upload_max_filesize.*/upload_max_filesize = 50M/'   "$PHP_INI"
        sed -i 's/^post_max_size.*/post_max_size = 50M/'               "$PHP_INI"
        sed -i 's/^memory_limit.*/memory_limit = 256M/'                "$PHP_INI"
        sed -i 's/^max_execution_time.*/max_execution_time = 120/'     "$PHP_INI"
    fi
done

PHP_OPCACHE="/etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini"
if [ -f "$PHP_OPCACHE" ]; then
    sed -i 's/;opcache.enable=.*/opcache.enable=1/'                                   "$PHP_OPCACHE"
    sed -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=128/'         "$PHP_OPCACHE"
    sed -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/' "$PHP_OPCACHE"
    sed -i 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/'         "$PHP_OPCACHE"
fi

mkdir -p /var/www/.config /var/www/.composer
chown -R www-data:www-data /var/www/.config /var/www/.composer 2>/dev/null || true

systemctl enable php${PHP_VERSION}-fpm > /dev/null 2>&1 || true
systemctl restart php${PHP_VERSION}-fpm
success "PHP configurado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Composer"
# ═══════════════════════════════════════════════════════════════════════════════
if command -v composer > /dev/null 2>&1; then
    success "Composer já instalado"
else
    info "Instalando Composer..."
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
    if command -v composer > /dev/null 2>&1; then
        success "Composer instalado"
    else
        error "Falha ao instalar Composer."
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Node.js ${NODE_VERSION}"
# ═══════════════════════════════════════════════════════════════════════════════
CURRENT_NODE=$(node -e 'process.stdout.write(process.versions.node.split(".")[0])' 2>/dev/null || echo "0")
if command -v node > /dev/null 2>&1 && [ "$CURRENT_NODE" -ge "$NODE_VERSION" ] 2>/dev/null; then
    success "Node.js já instalado: $(node --version)"
else
    info "Instalando Node.js ${NODE_VERSION} LTS..."
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - > /dev/null 2>&1
    apt-get install -y -qq nodejs 2>/dev/null || true
    success "Node.js instalado: $(node --version 2>/dev/null)"
fi

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando e Configurando Nginx"
# ═══════════════════════════════════════════════════════════════════════════════
if systemctl is-active apache2 > /dev/null 2>&1; then
    warn "Desabilitando Apache2..."
    systemctl stop apache2 2>/dev/null || true
    systemctl disable apache2 2>/dev/null || true
fi

if ! command -v nginx > /dev/null 2>&1; then
    info "Instalando Nginx..."
    apt-get install -y -qq nginx 2>/dev/null || true
fi

info "Configurando Virtual Host..."
cat > /etc/nginx/sites-available/vistoria << NGINX
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${APP_DIR}/public;

    index index.php;
    charset utf-8;
    client_max_body_size 50M;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php\$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
        fastcgi_read_timeout 120;
    }

    location ~ /\.(?!well-known).* { deny all; }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg|webp)\$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria
rm -f /etc/nginx/sites-enabled/default

nginx -t 2>/dev/null || error "Configuração Nginx inválida."
systemctl enable nginx > /dev/null 2>&1 || true
systemctl restart nginx
success "Nginx configurado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando MySQL Server"
# ═══════════════════════════════════════════════════════════════════════════════
info "Instalando MySQL Server..."
apt-get install -y mysql-server 2>/dev/null || error "Falha ao instalar MySQL."

info "Iniciando MySQL..."
systemctl enable mysql > /dev/null 2>&1 || true
systemctl start mysql

info "Aguardando MySQL iniciar..."
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if mysqladmin ping --silent 2>/dev/null; then
        break
    fi
    sleep 1
done

if ! mysqladmin ping --silent 2>/dev/null; then
    error "MySQL não respondeu após 15 segundos."
fi
success "MySQL instalado e iniciado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando MySQL e Banco de Dados"
# ═══════════════════════════════════════════════════════════════════════════════
info "Definindo senha root e criando banco..."

mysql -u root << MYSQL_SETUP
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USERNAME}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
ALTER USER '${DB_USERNAME}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USERNAME}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SETUP

if [ $? -ne 0 ]; then
    error "Falha ao configurar MySQL. Verifique o log: ${LOG_FILE}"
fi

success "MySQL configurado, banco '${DB_DATABASE}' e usuário '${DB_USERNAME}' criados"

# Salvar credenciais
cat > /root/.vistoria_mysql_credentials << CREDS
# Credenciais MySQL — Sistema de Vistoria
# Gerado em: $(date)
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
CREDS
chmod 600 /root/.vistoria_mysql_credentials
success "Credenciais salvas em /root/.vistoria_mysql_credentials"

# ═══════════════════════════════════════════════════════════════════════════════
step "Baixando Sistema do GitHub"
# ═══════════════════════════════════════════════════════════════════════════════
mkdir -p /var/www

if [ -d "$APP_DIR" ]; then
    info "Removendo instalação anterior..."
    rm -rf "$APP_DIR"
fi

info "Clonando repositório..."
git clone --depth=1 "$GITHUB_REPO" "$APP_DIR" 2>&1
if [ $? -ne 0 ]; then
    error "Falha ao clonar repositório."
fi

if [ ! -f "$APP_DIR/artisan" ]; then
    error "Repositório inválido: 'artisan' não encontrado."
fi
success "Repositório clonado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Ambiente (.env)"
# ═══════════════════════════════════════════════════════════════════════════════
cd "$APP_DIR"

cp .env.example .env
php artisan key:generate --force --quiet
APP_KEY=$(grep "^APP_KEY=" .env | cut -d'=' -f2-)

cat > .env << ENVEOF
APP_NAME="Sistema de Vistoria"
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}
APP_LOCALE=pt_BR
APP_FALLBACK_LOCALE=pt_BR
APP_FAKER_LOCALE=pt_BR

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database

CACHE_STORE=database

MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="noreply@${DOMAIN}"
MAIL_FROM_NAME="Sistema de Vistoria"

VITE_APP_NAME="Sistema de Vistoria"
ENVEOF

success "Arquivo .env criado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Dependências PHP"
# ═══════════════════════════════════════════════════════════════════════════════
export HOME=/root

info "Executando composer install..."
composer install --no-dev --optimize-autoloader --no-interaction --no-progress 2>&1
if [ $? -ne 0 ]; then
    error "Falha no composer install."
fi
success "Dependências PHP instaladas"

# ═══════════════════════════════════════════════════════════════════════════════
step "Compilando Assets (CSS/JavaScript)"
# ═══════════════════════════════════════════════════════════════════════════════
info "Instalando pacotes NPM..."
npm install --no-audit --no-fund 2>&1
if [ $? -ne 0 ]; then
    error "Falha no npm install."
fi

info "Compilando assets para produção..."
npm run build 2>&1
if [ $? -ne 0 ]; then
    error "Falha no npm run build."
fi
success "Assets compilados"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Permissões"
# ═══════════════════════════════════════════════════════════════════════════════
chown -R www-data:www-data "$APP_DIR"
find "$APP_DIR" -type f -exec chmod 644 {} \;
find "$APP_DIR" -type d -exec chmod 755 {} \;
chmod -R 775 "$APP_DIR/storage"
chmod -R 775 "$APP_DIR/bootstrap/cache"
chmod +x "$APP_DIR/artisan"
success "Permissões configuradas"

# ═══════════════════════════════════════════════════════════════════════════════
step "Executando Migrações do Banco"
# ═══════════════════════════════════════════════════════════════════════════════
info "Rodando migrações..."
php artisan migrate --force 2>&1
if [ $? -ne 0 ]; then
    error "Falha nas migrações. Verifique o log."
fi
success "Migrações concluídas"

php artisan storage:link --quiet 2>/dev/null || true

info "Executando seeders..."
php artisan db:seed --force 2>&1 && success "Seeders concluídos" || warn "Seeders pulados (não crítico)"

info "Gerando cache de produção..."
php artisan config:cache  2>/dev/null || true
php artisan route:cache   2>/dev/null || true
php artisan view:cache    2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
step "Criando Usuário Administrador"
# ═══════════════════════════════════════════════════════════════════════════════
info "Criando admin '${ADMIN_EMAIL}'..."

ADMIN_SCRIPT="/tmp/vistoria_create_admin_$$.php"

# Montar o script PHP com variáveis já expandidas pelo bash
cat > "$ADMIN_SCRIPT" << PHPEOF
<?php
chdir('${APP_DIR}');
define('LARAVEL_START', microtime(true));
require '${APP_DIR}/vendor/autoload.php';
\$app = require_once '${APP_DIR}/bootstrap/app.php';
\$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
\$kernel->bootstrap();

\$email    = '${ADMIN_EMAIL}';
\$name     = '${ADMIN_NAME}';
\$password = '${ADMIN_PASSWORD}';

try {
    if (\App\Models\User::where('email', \$email)->exists()) {
        echo "OK: Usuário já existe: {\$email}\n";
        exit(0);
    }

    \$data = [
        'name'              => \$name,
        'email'             => \$email,
        'password'          => \Illuminate\Support\Facades\Hash::make(\$password),
        'email_verified_at' => now(),
    ];

    try {
        \$cols = \Illuminate\Support\Facades\Schema::getColumnListing('users');
        if (in_array('role', \$cols))               { \$data['role'] = 'admin'; }
        if (in_array('inspection_credits', \$cols))  { \$data['inspection_credits'] = 999; }
    } catch (\Exception \$e) {}

    \App\Models\User::create(\$data);
    echo "OK: Admin criado com sucesso: {\$email}\n";
    exit(0);
} catch (\Exception \$e) {
    echo "ERRO: " . \$e->getMessage() . "\n";
    exit(1);
}
PHPEOF

HOME=/tmp php "$ADMIN_SCRIPT" 2>&1
ADMIN_RESULT=$?
rm -f "$ADMIN_SCRIPT"

if [ $ADMIN_RESULT -eq 0 ]; then
    success "Usuário administrador criado"
else
    warn "Não foi possível criar o admin automaticamente."
    warn "Execute manualmente: cd ${APP_DIR} && php artisan tinker"
    warn ">>> \\App\\Models\\User::create(['name'=>'${ADMIN_NAME}','email'=>'${ADMIN_EMAIL}','password'=>bcrypt('${ADMIN_PASSWORD}'),'email_verified_at'=>now()])"
fi

# Reajustar permissões após scripts PHP
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Supervisor (Filas)"
# ═══════════════════════════════════════════════════════════════════════════════
apt-get install -y -qq supervisor 2>/dev/null || true

cat > /etc/supervisor/conf.d/vistoria-worker.conf << SUP
[program:vistoria-worker]
process_name=%(program_name)s_%(process_num)02d
command=php ${APP_DIR}/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=${APP_DIR}/storage/logs/worker.log
stopwaitsecs=3600
SUP

systemctl enable supervisor > /dev/null 2>&1 || true
systemctl restart supervisor > /dev/null 2>&1 || true
supervisorctl reread > /dev/null 2>&1 || true
supervisorctl update > /dev/null 2>&1 || true
supervisorctl start "vistoria-worker:*" > /dev/null 2>&1 || true
success "Supervisor configurado (2 workers)"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Firewall (UFW)"
# ═══════════════════════════════════════════════════════════════════════════════
ufw --force reset > /dev/null 2>&1 || true
ufw default deny incoming  > /dev/null 2>&1 || true
ufw default allow outgoing > /dev/null 2>&1 || true
ufw allow 22/tcp  > /dev/null 2>&1 || true
ufw allow 80/tcp  > /dev/null 2>&1 || true
ufw allow 443/tcp > /dev/null 2>&1 || true
ufw --force enable > /dev/null 2>&1 || true
success "Firewall configurado (portas 22, 80, 443)"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando SSL com Let's Encrypt"
# ═══════════════════════════════════════════════════════════════════════════════
IS_IP=$(echo "$DOMAIN" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)

if echo "$INSTALL_SSL" | grep -qi '^s'; then
    if [ -n "$IS_IP" ]; then
        warn "SSL ignorado: '${DOMAIN}' é um IP. Let's Encrypt requer domínio."
    else
        info "Instalando Certbot..."
        apt-get install -y -qq certbot python3-certbot-nginx 2>/dev/null || true

        info "Emitindo certificado para ${DOMAIN}..."
        certbot --nginx \
            -d "${DOMAIN}" \
            -d "www.${DOMAIN}" \
            --non-interactive \
            --agree-tos \
            --email "${SSL_EMAIL}" \
            --redirect 2>&1

        if [ $? -eq 0 ]; then
            sed -i "s|APP_URL=http://|APP_URL=https://|g" "${APP_DIR}/.env"
            APP_URL="https://${DOMAIN}"
            php artisan config:cache --quiet 2>/dev/null || true
            success "Certificado SSL instalado"
        else
            warn "Certbot falhou. DNS de '${DOMAIN}' precisa apontar para este servidor."
            warn "Para instalar SSL depois: certbot --nginx -d ${DOMAIN}"
        fi
    fi
else
    info "SSL ignorado conforme escolha do usuário."
fi

# Cron
CRON_FILE="/etc/cron.d/vistoria"
cat > "$CRON_FILE" << CRONEOF
* * * * * www-data php ${APP_DIR}/artisan schedule:run >> /dev/null 2>&1
0 3 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'
CRONEOF
chmod 644 "$CRON_FILE"
success "Cron configurado"

# ═══════════════════════════════════════════════════════════════════════════════
# RESUMO FINAL
# ═══════════════════════════════════════════════════════════════════════════════
clear
echo -e "${BOLD}${GREEN}"
cat << 'DONE'
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║           ✅  INSTALAÇÃO CONCLUÍDA COM SUCESSO!              ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
DONE
echo -e "${NC}"

echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  ACESSO AO SISTEMA${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  🌐 URL         : ${GREEN}${APP_URL}${NC}"
echo -e "  👤 Admin e-mail: ${GREEN}${ADMIN_EMAIL}${NC}"
echo -e "  🔑 Senha admin : ${GREEN}${ADMIN_PASSWORD}${NC}"
echo
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  BANCO DE DADOS${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  💾 Banco       : ${GREEN}${DB_DATABASE}${NC}"
echo -e "  👤 Usuário     : ${GREEN}${DB_USERNAME}${NC}"
echo -e "  📄 Credenciais : ${GREEN}/root/.vistoria_mysql_credentials${NC}"
echo
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  ARQUIVOS${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  📁 App         : ${CYAN}${APP_DIR}${NC}"
echo -e "  ⚙️  Config      : ${CYAN}${APP_DIR}/.env${NC}"
echo -e "  📋 Logs app    : ${CYAN}${APP_DIR}/storage/logs/laravel.log${NC}"
echo -e "  📝 Log install : ${CYAN}${LOG_FILE}${NC}"
echo
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  PRÓXIMOS PASSOS${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  1. Acesse ${BOLD}${APP_URL}${NC} e faça login"
echo -e "  2. Se precisar de SSL: ${YELLOW}certbot --nginx -d ${DOMAIN}${NC}"
echo -e "  3. Para configurar e-mail, edite ${CYAN}${APP_DIR}/.env${NC}"
echo -e "     e execute: ${YELLOW}cd ${APP_DIR} && php artisan config:cache${NC}"
echo -e "  4. ${RED}⚠  Guarde as credenciais acima em local seguro!${NC}"
echo
echo -e "  ${GREEN}Sistema pronto para uso! 🚀${NC}"
echo
