#!/bin/bash

################################################################################
# setup.sh - Instalação Rápida do Vistoria via GitHub
#
# USO:
#   sudo bash setup.sh [OPÇÕES]
#
# OPÇÕES:
#   --domain=DOMINIO        Domínio ou IP do servidor (obrigatório)
#   --db-password=SENHA     Senha do banco MySQL (padrão: gerada automaticamente)
#   --admin-email=EMAIL     Email do admin (padrão: admin@dominio.com)
#   --admin-password=SENHA  Senha do admin (padrão: gerada automaticamente)
#   --app-dir=CAMINHO       Diretório de instalação (padrão: /var/www/vistoria)
#   --no-https              Não configurar HTTPS/SSL
#   --help                  Mostrar esta ajuda
#
# EXEMPLOS:
#   sudo bash setup.sh --domain=10.0.0.72
#   sudo bash setup.sh --domain=vistoria.minhaempresa.com.br --admin-email=ti@empresa.com
#   curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/setup.sh | sudo bash -s -- --domain=10.0.0.72
#
################################################################################

set -euo pipefail

# ── Cores ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

step()    { echo -e "\n${BOLD}${CYAN}▶ $1${NC}"; }
ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()     { echo -e "  ${RED}✗ ERRO: $1${NC}"; exit 1; }
info()    { echo -e "  ${BLUE}→${NC} $1"; }

# ── Gerar senha aleatória ──────────────────────────────────────────────────────
rand_pass() { tr -dc 'A-Za-z0-9@#$%' </dev/urandom | head -c 20; }

# ── Valores padrão ────────────────────────────────────────────────────────────
DOMAIN=""
APP_DIR="/var/www/vistoria"
DB_NAME="vistoria"
DB_USER="vistoria_user"
DB_PASSWORD=""
ADMIN_EMAIL=""
ADMIN_PASSWORD=""
USE_HTTPS=true
REPO="https://github.com/GuilhermeSantiago921/Vistoria.git"

# ── Parsear argumentos ────────────────────────────────────────────────────────
for arg in "$@"; do
    case $arg in
        --domain=*)       DOMAIN="${arg#*=}" ;;
        --db-password=*)  DB_PASSWORD="${arg#*=}" ;;
        --admin-email=*)  ADMIN_EMAIL="${arg#*=}" ;;
        --admin-password=*) ADMIN_PASSWORD="${arg#*=}" ;;
        --app-dir=*)      APP_DIR="${arg#*=}" ;;
        --no-https)       USE_HTTPS=false ;;
        --help|-h)
            sed -n '4,20p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) warn "Argumento desconhecido: $arg" ;;
    esac
done

# ── Verificações iniciais ─────────────────────────────────────────────────────
[ "$EUID" -ne 0 ] && err "Execute com sudo: sudo bash $0 --domain=SEU_IP_OU_DOMINIO"
[ -z "$DOMAIN" ] && err "Informe o domínio ou IP: sudo bash $0 --domain=SEU_IP_OU_DOMINIO"

# Preencher valores não informados
[ -z "$DB_PASSWORD" ]    && DB_PASSWORD=$(rand_pass)
[ -z "$ADMIN_EMAIL" ]    && ADMIN_EMAIL="admin@${DOMAIN}"
[ -z "$ADMIN_PASSWORD" ] && ADMIN_PASSWORD=$(rand_pass)

# Verificar se é IP (sem HTTPS automático)
if [[ "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    USE_HTTPS=false
    APP_URL="http://${DOMAIN}"
else
    APP_URL="http://${DOMAIN}"
    $USE_HTTPS && APP_URL="https://${DOMAIN}"
fi

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║     Instalação Rápida - Vistoria          ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${NC}"
echo -e "  Servidor  : ${BOLD}${DOMAIN}${NC}"
echo -e "  Diretório : ${APP_DIR}"
echo -e "  Admin     : ${ADMIN_EMAIL}"
echo -e "  HTTPS     : $(${USE_HTTPS} && echo 'Sim' || echo 'Não')"
echo -e "  Repositório: ${REPO}\n"

################################################################################
# 1. ATUALIZAR SISTEMA
################################################################################
step "1/9 - Atualizando sistema..."

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq curl wget git unzip software-properties-common \
    lsb-release ca-certificates gnupg2 apt-transport-https
ok "Sistema atualizado"

################################################################################
# 2. INSTALAR PHP 8.2
################################################################################
step "2/9 - Instalando PHP 8.2..."

# Adicionar repositório ondrej/php se ainda não tiver
if ! apt-cache show php8.2 &>/dev/null; then
    add-apt-repository ppa:ondrej/php -y -qq
    apt-get update -qq
fi

apt-get install -y -qq \
    php8.2 php8.2-cli php8.2-fpm php8.2-common \
    php8.2-mysql php8.2-pgsql php8.2-sqlite3 \
    php8.2-curl php8.2-gd php8.2-mbstring \
    php8.2-xml php8.2-zip php8.2-bcmath \
    php8.2-intl php8.2-readline php8.2-opcache

systemctl enable php8.2-fpm --quiet
systemctl start php8.2-fpm
ok "PHP $(php8.2 -r 'echo PHP_VERSION;') instalado"

################################################################################
# 3. INSTALAR NGINX
################################################################################
step "3/9 - Instalando Nginx..."

apt-get install -y -qq nginx
systemctl enable nginx --quiet
systemctl start nginx
ok "Nginx instalado"

################################################################################
# 4. INSTALAR MYSQL
################################################################################
step "4/9 - Instalando MySQL..."

apt-get install -y -qq mysql-server
systemctl enable mysql --quiet
systemctl start mysql

# Criar banco e usuário
mysql -u root <<MYSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL

ok "MySQL configurado (banco: ${DB_NAME})"

################################################################################
# 5. INSTALAR NODE.JS E COMPOSER
################################################################################
step "5/9 - Instalando Node.js e Composer..."

# Node.js 20
if ! command -v node &>/dev/null || [[ "$(node -v)" < "v20" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &>/dev/null
    apt-get install -y -qq nodejs
fi
ok "Node.js $(node -v) instalado"

# Composer
if ! command -v composer &>/dev/null; then
    curl -sS https://getcomposer.org/installer | php -- --quiet
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi
ok "Composer $(composer --version --no-ansi 2>/dev/null | awk '{print $3}') instalado"

################################################################################
# 6. CLONAR REPOSITÓRIO E CONFIGURAR
################################################################################
step "6/9 - Clonando repositório do GitHub..."

# Remover instalação anterior se existir
if [ -d "$APP_DIR" ]; then
    warn "Diretório $APP_DIR já existe — fazendo backup..."
    mv "$APP_DIR" "${APP_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$(dirname $APP_DIR)"
git clone --depth=1 "$REPO" "$APP_DIR" -q
ok "Repositório clonado em $APP_DIR"

cd "$APP_DIR"

# Criar .env
info "Criando arquivo .env..."
cat > .env <<ENV
APP_NAME=Vistoria
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=${APP_URL}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=log
MAIL_FROM_ADDRESS=noreply@${DOMAIN}
MAIL_FROM_NAME="Vistoria"
ENV
chmod 600 .env

# Instalar dependências PHP
info "Instalando dependências PHP (composer)..."
composer install --no-dev --optimize-autoloader --quiet

# Gerar chave
php artisan key:generate --force -q
ok "Chave da aplicação gerada"

# Instalar dependências front-end e compilar
info "Compilando assets (npm)..."
npm install --silent
npm run build --silent
ok "Assets compilados"

################################################################################
# 7. BANCO DE DADOS E STORAGE
################################################################################
step "7/9 - Configurando banco de dados..."

php artisan migrate --force -q
ok "Migrações executadas"

php artisan db:seed --force -q 2>/dev/null && ok "Seeds executados" || warn "Sem seeds ou já executados"

# Storage link
php artisan storage:link -q 2>/dev/null || true
ok "Storage link criado"

# Criar usuário admin via script PHP direto (sem tinker)
php -r "
define('LARAVEL_START', microtime(true));
require '${APP_DIR}/vendor/autoload.php';
\$app = require '${APP_DIR}/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if (!App\Models\User::where('email','${ADMIN_EMAIL}')->exists()) {
    App\Models\User::create([
        'name'               => 'Administrador',
        'email'              => '${ADMIN_EMAIL}',
        'password'           => Illuminate\Support\Facades\Hash::make('${ADMIN_PASSWORD}'),
        'email_verified_at'  => now(),
        'role'               => 'admin',
    ]);
    echo 'ok';
} else {
    echo 'existe';
}
" 2>/dev/null && ok "Usuário admin configurado" || warn "Não foi possível criar admin agora"

################################################################################
# 8. CONFIGURAR NGINX
################################################################################
step "8/9 - Configurando Nginx..."

cat > /etc/nginx/sites-available/vistoria <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${APP_DIR}/public;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    index index.php;
    charset utf-8;
    client_max_body_size 70M;

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
        fastcgi_read_timeout 300;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
NGINX

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria
nginx -t -q
systemctl restart nginx
ok "Nginx configurado"

# SSL com Certbot (somente para domínio real, não IP)
if $USE_HTTPS; then
    info "Configurando HTTPS com Let's Encrypt..."
    apt-get install -y -qq certbot python3-certbot-nginx
    certbot --nginx -d "$DOMAIN" \
        --email "$ADMIN_EMAIL" \
        --agree-tos \
        --non-interactive \
        --redirect \
        --quiet && ok "HTTPS configurado" || warn "Não foi possível obter SSL agora. Configure manualmente depois."
fi

################################################################################
# 9. PERMISSÕES E OTIMIZAÇÃO FINAL
################################################################################
step "9/9 - Ajustando permissões e otimizando..."

chown -R www-data:www-data "$APP_DIR"
find "$APP_DIR" -type f -exec chmod 644 {} \;
find "$APP_DIR" -type d -exec chmod 755 {} \;
chmod -R 775 "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"
chmod 600 "$APP_DIR/.env"

# Caches de produção
cd "$APP_DIR"
php artisan config:cache -q
php artisan route:cache -q
php artisan view:cache -q
ok "Cache de produção gerado"

# Queue worker como serviço systemd
cat > /etc/systemd/system/vistoria-queue.service <<UNIT
[Unit]
Description=Vistoria Queue Worker
After=network.target mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/php ${APP_DIR}/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable vistoria-queue --quiet
systemctl start vistoria-queue
ok "Queue worker iniciado"

# Cron para scheduler
(crontab -l 2>/dev/null | grep -v "vistoria"; echo "* * * * * cd ${APP_DIR} && php artisan schedule:run >> /dev/null 2>&1") | crontab -
ok "Scheduler configurado no cron"

################################################################################
# RESUMO FINAL
################################################################################

# Salvar credenciais em arquivo seguro
CREDS_FILE="/root/vistoria-credentials.txt"
cat > "$CREDS_FILE" <<CREDS
========================================
   CREDENCIAIS DO SISTEMA VISTORIA
   Gerado em: $(date)
========================================

URL de Acesso : ${APP_URL}
Diretório     : ${APP_DIR}

--- LOGIN ADMIN ---
Email : ${ADMIN_EMAIL}
Senha : ${ADMIN_PASSWORD}

--- BANCO DE DADOS ---
Host     : 127.0.0.1:3306
Banco    : ${DB_NAME}
Usuário  : ${DB_USER}
Senha    : ${DB_PASSWORD}

--- COMANDOS ÚTEIS ---
Logs app    : tail -f ${APP_DIR}/storage/logs/laravel.log
Logs nginx  : tail -f /var/log/nginx/error.log
Reiniciar   : systemctl restart nginx php8.2-fpm
Atualizar   : cd ${APP_DIR} && git pull && composer install --no-dev && npm run build && php artisan migrate --force
Status queue: systemctl status vistoria-queue
========================================
CREDS
chmod 600 "$CREDS_FILE"

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║        ✅ INSTALAÇÃO CONCLUÍDA!           ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  🌐 Acesse : ${BOLD}${APP_URL}${NC}"
echo -e "  📧 Login  : ${BOLD}${ADMIN_EMAIL}${NC}"
echo -e "  🔑 Senha  : ${BOLD}${ADMIN_PASSWORD}${NC}"
echo ""
echo -e "  💾 Credenciais salvas em: ${BOLD}${CREDS_FILE}${NC}"
echo ""
echo -e "  📋 Comandos úteis:"
echo -e "     Logs   : tail -f ${APP_DIR}/storage/logs/laravel.log"
echo -e "     Nginx  : systemctl restart nginx"
echo -e "     PHP    : systemctl restart php8.2-fpm"
echo -e "     Update : cd ${APP_DIR} && git pull && composer install --no-dev && php artisan migrate --force"
echo ""
