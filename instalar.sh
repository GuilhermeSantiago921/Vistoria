#!/bin/bash

# =============================================================================
#  INSTALADOR - SISTEMA DE VISTORIA VEICULAR
#  Ubuntu Server 22.04 / 24.04 LTS
#  Repositório: https://github.com/GuilhermeSantiago921/Vistoria
#
#  Uso: sudo bash instalar.sh
#  Ou:  curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/instalar.sh | sudo bash
# =============================================================================

set -o pipefail

# ── Cores ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Log em arquivo ────────────────────────────────────────────────────────────
LOG_FILE="/tmp/vistoria-install-$(date +%Y%m%d_%H%M%S).log"
# Redirecionar stdout/stderr para log SEM interferir no stdin (tty)
exec > >(tee -a "$LOG_FILE") 2>&1 || true

# ── Funções de log ────────────────────────────────────────────────────────────
info()    { echo -e "  ${BLUE}ℹ${NC}  $1"; }
success() { echo -e "  ${GREEN}✔${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "\n  ${RED}✘  ERRO: $1${NC}"; echo -e "\n  Verifique o log completo em: ${LOG_FILE}"; exit 1; }
step()    { echo -e "\n${BOLD}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── Constantes ────────────────────────────────────────────────────────────────
APP_DIR="/var/www/vistoria"
GITHUB_REPO="https://github.com/GuilhermeSantiago921/Vistoria.git"
PHP_VERSION="8.2"
NODE_VERSION="20"
export DEBIAN_FRONTEND=noninteractive

# ── Verificações iniciais ─────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && { echo -e "${RED}Execute como root: sudo bash instalar.sh${NC}"; exit 1; }

if ! grep -qiE "ubuntu|debian" /etc/os-release 2>/dev/null; then
    warn "SO não identificado como Ubuntu/Debian. Prosseguindo mesmo assim..."
fi

# ── Banner ────────────────────────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
cat << 'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║          🚗  SISTEMA DE VISTORIA VEICULAR                   ║
  ║               Instalador Automático v2.1                    ║
  ║         github.com/GuilhermeSantiago921/Vistoria             ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"
echo -e "  Logs salvos em: ${CYAN}${LOG_FILE}${NC}"
echo

# ── Verificar recursos do servidor ───────────────────────────────────────────
step "Verificando Recursos do Servidor"
RAM_MB=$(free -m | awk '/^Mem:/{print $7}')
DISK_GB=$(df -BG / | awk 'NR==2{gsub("G",""); print $4}')

[[ "$RAM_MB" -lt 256 ]] && warn "RAM disponível baixa: ${RAM_MB}MB. Mínimo recomendado: 512MB." \
                         || success "RAM disponível: ${RAM_MB}MB"
[[ "$DISK_GB" -lt 5 ]]  && error "Espaço em disco insuficiente: ${DISK_GB}GB livres. Mínimo: 5GB." \
                         || success "Espaço em disco livre: ${DISK_GB}GB"

if curl -fsS --max-time 5 https://github.com > /dev/null 2>&1; then
    success "Conexão com internet ativa"
else
    error "Sem conexão com a internet. Verifique a rede e tente novamente."
fi

# ── Coletar configurações ─────────────────────────────────────────────────────
step "Configuração do Sistema"
echo
echo -e "  Preencha as informações abaixo para configurar o sistema."
echo -e "  Pressione ENTER para usar o valor padrão (entre colchetes)."
echo

# URL do sistema
SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
echo -e "  1. URL de acesso ao sistema:"
echo -e "     Exemplos: http://meusite.com.br  |  http://${SERVER_IP}"
read -rp "     URL [http://${SERVER_IP}]: " APP_URL </dev/tty
APP_URL=${APP_URL:-"http://${SERVER_IP}"}
# Extrair domínio da URL para uso no Nginx/Certbot
DOMAIN=$(echo "$APP_URL" | sed 's|https\?://||' | sed 's|/.*||')
[[ -z "$DOMAIN" ]] && error "URL inválida."

# Banco de dados
echo
echo -e "  2. Configuração do Banco de Dados MySQL:"
echo
while true; do
    read -sp "     Senha para o usuário ROOT do MySQL: " MYSQL_ROOT_PASSWORD </dev/tty; echo
    read -sp "     Confirme a senha root: " MYSQL_ROOT_CONFIRM </dev/tty; echo
    [ "$MYSQL_ROOT_PASSWORD" = "$MYSQL_ROOT_CONFIRM" ] && break
    warn "Senhas não conferem. Tente novamente."
done

read -rp "     Nome do banco de dados [vistoria]: " DB_DATABASE </dev/tty
DB_DATABASE=${DB_DATABASE:-vistoria}
read -rp "     Nome do usuário do banco [vistoria_user]: " DB_USERNAME </dev/tty
DB_USERNAME=${DB_USERNAME:-vistoria_user}

while true; do
    read -sp "     Senha do usuário do banco: " DB_PASSWORD </dev/tty; echo
    read -sp "     Confirme a senha do banco: " DB_PASSWORD_CONFIRM </dev/tty; echo
    [ "$DB_PASSWORD" = "$DB_PASSWORD_CONFIRM" ] && break
    warn "Senhas não conferem. Tente novamente."
done
[ -z "$DB_PASSWORD" ] && error "A senha do banco não pode ser vazia."

# Administrador
echo
echo -e "  3. Conta de Administrador do Sistema:"
echo
read -rp "     Nome completo do administrador [Administrador]: " ADMIN_NAME </dev/tty
ADMIN_NAME=${ADMIN_NAME:-Administrador}
read -rp "     E-mail do administrador [admin@vistoria.com.br]: " ADMIN_EMAIL </dev/tty
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@vistoria.com.br}

while true; do
    read -sp "     Senha do administrador (mínimo 8 caracteres): " ADMIN_PASSWORD </dev/tty; echo
    read -sp "     Confirme a senha do administrador: " ADMIN_PASSWORD_CONFIRM </dev/tty; echo
    if [ "$ADMIN_PASSWORD" = "$ADMIN_PASSWORD_CONFIRM" ] && [ ${#ADMIN_PASSWORD} -ge 8 ]; then
        break
    elif [ "$ADMIN_PASSWORD" != "$ADMIN_PASSWORD_CONFIRM" ]; then
        warn "Senhas não conferem."
    else
        warn "Senha muito curta (mínimo 8 caracteres)."
    fi
done

# SSL
echo
read -rp "  Instalar SSL com Let's Encrypt/Certbot? [S/n]: " INSTALL_SSL </dev/tty
INSTALL_SSL=${INSTALL_SSL:-S}

# Resumo
echo
echo -e "  ┌─────────────────────────────────────────────────────────┐"
echo -e "  │              RESUMO DA CONFIGURAÇÃO                       │"
echo -e "  ├─────────────────────────────────────────────────────────┤"
echo -e "  │  URL do sistema:    ${CYAN}${APP_URL}${NC}"
echo -e "  │  Banco de dados:    ${CYAN}${DB_DATABASE}${NC}"
echo -e "  │  Usuário do banco:  ${CYAN}${DB_USERNAME}${NC}"
echo -e "  │  Admin - Nome:      ${CYAN}${ADMIN_NAME}${NC}"
echo -e "  │  Admin - E-mail:    ${CYAN}${ADMIN_EMAIL}${NC}"
echo -e "  │  Diretório:         ${CYAN}${APP_DIR}${NC}"
echo -e "  └─────────────────────────────────────────────────────────┘"
echo
read -rp "  Confirmar e iniciar instalação? [S/n]: " CONFIRM </dev/tty
[[ "${CONFIRM,,}" == "n" ]] && { echo "Instalação cancelada."; exit 0; }

echo
echo -e "  Iniciando instalação..."
echo -e "  Isso pode levar de 5 a 15 minutos."
echo -e "  Acompanhe o progresso abaixo."

# ═══════════════════════════════════════════════════════════════════════════════
step "Atualizando Sistema e Instalando Dependências"
# ═══════════════════════════════════════════════════════════════════════════════
export DEBIAN_FRONTEND=noninteractive
info "Atualizando pacotes do sistema..."
apt-get update -qq
apt-get upgrade -y -qq 2>/dev/null
success "Sistema atualizado"

info "Instalando utilitários básicos..."
apt-get install -y -qq \
    curl wget git unzip zip gnupg2 lsb-release ca-certificates \
    software-properties-common apt-transport-https ufw 2>/dev/null
success "Utilitários instalados"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando PHP ${PHP_VERSION}"
# ═══════════════════════════════════════════════════════════════════════════════
if php -v 2>/dev/null | grep -q "PHP ${PHP_VERSION}"; then
    success "PHP ${PHP_VERSION} já instalado"
else
    info "Adicionando repositório ondrej/php..."
    add-apt-repository ppa:ondrej/php -y -q > /dev/null 2>&1
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
        php${PHP_VERSION}-fileinfo \
        php${PHP_VERSION}-pdo 2>/dev/null
    success "PHP ${PHP_VERSION} instalado"
fi

info "Otimizando configurações do PHP..."
PHP_INI_FPM="/etc/php/${PHP_VERSION}/fpm/php.ini"
PHP_INI_CLI="/etc/php/${PHP_VERSION}/cli/php.ini"

for PHP_INI in "$PHP_INI_FPM" "$PHP_INI_CLI"; do
    [[ -f "$PHP_INI" ]] || continue
    sed -i 's/^upload_max_filesize.*/upload_max_filesize = 10M/'   "$PHP_INI"
    sed -i 's/^post_max_size.*/post_max_size = 50M/'               "$PHP_INI"
    sed -i 's/^memory_limit.*/memory_limit = 256M/'                "$PHP_INI"
    sed -i 's/^max_execution_time.*/max_execution_time = 120/'     "$PHP_INI"
    sed -i 's/^;max_input_time.*/max_input_time = 120/'            "$PHP_INI"
done

# OPcache
PHP_OPCACHE="/etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini"
if [[ -f "$PHP_OPCACHE" ]]; then
    sed -i 's/;opcache.enable=.*/opcache.enable=1/'                                   "$PHP_OPCACHE"
    sed -i 's/;opcache.memory_consumption=.*/opcache.memory_consumption=128/'         "$PHP_OPCACHE"
    sed -i 's/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/' "$PHP_OPCACHE"
    sed -i 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=0/'         "$PHP_OPCACHE"
fi

# Criar diretório home para www-data (necessário para Composer/PsySH)
mkdir -p /var/www/.config /var/www/.composer
chown -R www-data:www-data /var/www/.config /var/www/.composer

systemctl enable php${PHP_VERSION}-fpm > /dev/null 2>&1
systemctl restart php${PHP_VERSION}-fpm
success "PHP configurado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Composer"
# ═══════════════════════════════════════════════════════════════════════════════
if command -v composer &>/dev/null; then
    success "Composer já instalado: $(composer --version --no-ansi 2>/dev/null)"
else
    info "Baixando e instalando Composer..."
    EXPECTED_CHECKSUM="$(curl -s https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        rm -f /tmp/composer-setup.php
        error "Checksum do instalador do Composer inválido. Abortando por segurança."
    fi
    php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
    rm -f /tmp/composer-setup.php
    success "Composer instalado: $(composer --version --no-ansi 2>/dev/null)"
fi

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Node.js e NPM"
# ═══════════════════════════════════════════════════════════════════════════════
CURRENT_NODE_MAJOR=$(node -e 'process.stdout.write(process.versions.node.split(".")[0])' 2>/dev/null || echo "0")
if command -v node &>/dev/null && [[ "$CURRENT_NODE_MAJOR" -ge "$NODE_VERSION" ]]; then
    success "Node.js já instalado: $(node --version)"
else
    info "Instalando Node.js ${NODE_VERSION} LTS..."
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - > /dev/null 2>&1
    apt-get install -y -qq nodejs 2>/dev/null
    success "Node.js instalado: $(node --version)"
fi

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando e Configurando Nginx"
# ═══════════════════════════════════════════════════════════════════════════════

# Desabilitar Apache2 se estiver presente para evitar conflito de porta 80
if systemctl is-enabled apache2 &>/dev/null 2>&1; then
    warn "Apache2 instalado mas parado — desabilitando para não conflitar..."
    systemctl stop apache2 2>/dev/null || true
    systemctl disable apache2 2>/dev/null || true
fi

if command -v nginx &>/dev/null; then
    success "Nginx já instalado"
else
    info "Instalando Nginx..."
    apt-get install -y -qq nginx 2>/dev/null
fi

info "Configurando Virtual Host para Vistoria..."
cat > /etc/nginx/sites-available/vistoria << NGINX
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root ${APP_DIR}/public;

    index index.php;
    charset utf-8;

    # Cabeçalhos de segurança
    add_header X-Frame-Options "SAMEORIGIN"       always;
    add_header X-Content-Type-Options "nosniff"   always;
    add_header X-XSS-Protection "1; mode=block"   always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Limite para upload de fotos de vistoria
    client_max_body_size 50M;

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

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Cache de assets estáticos (CSS, JS, imagens, fontes)
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg|webp)\$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria
rm -f /etc/nginx/sites-enabled/default

nginx -t 2>/dev/null || error "Configuração do Nginx inválida."
systemctl enable nginx > /dev/null 2>&1
systemctl restart nginx
success "Nginx configurado e iniciado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando e Configurando MySQL"
# ═══════════════════════════════════════════════════════════════════════════════
if command -v mysql &>/dev/null; then
    success "MySQL já instalado: $(mysql --version)"
else
    info "Instalando MySQL Server..."
    apt-get install -y -qq mysql-server 2>/dev/null
fi

info "Iniciando MySQL..."
systemctl enable mysql > /dev/null 2>&1
systemctl start mysql

info "Aguardando MySQL iniciar..."
for i in {1..15}; do
    mysqladmin ping --silent 2>/dev/null && break
    sleep 1
done
mysqladmin ping --silent 2>/dev/null || error "MySQL não respondeu após 15 segundos."
success "MySQL iniciado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Criando Banco de Dados e Usuário"
# ═══════════════════════════════════════════════════════════════════════════════
info "Criando banco de dados '${DB_DATABASE}'..."

# Tentar autenticação sem senha (instalação nova) e depois com senha root
mysql_exec() {
    if [[ -n "$MYSQL_ROOT_PASSWORD" ]]; then
        mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "$1" 2>/dev/null
    else
        mysql -uroot -e "$1" 2>/dev/null
    fi
}

mysql_exec "CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" \
    || error "Falha ao criar banco de dados. Verifique a senha root do MySQL."
success "Banco de dados criado"

info "Configurando usuário '${DB_USERNAME}'..."
mysql_exec "CREATE USER IF NOT EXISTS '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql_exec "ALTER USER '${DB_USERNAME}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql_exec "GRANT ALL PRIVILEGES ON \`${DB_DATABASE}\`.* TO '${DB_USERNAME}'@'localhost';"
mysql_exec "FLUSH PRIVILEGES;"
success "Usuário criado e permissões concedidas"

# Salvar credenciais
cat > /root/.vistoria_mysql_credentials << CREDS
# Credenciais MySQL — Sistema de Vistoria
# Gerado em: $(date)
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
CREDS
chmod 600 /root/.vistoria_mysql_credentials

# ═══════════════════════════════════════════════════════════════════════════════
step "Baixando Sistema do GitHub"
# ═══════════════════════════════════════════════════════════════════════════════
mkdir -p /var/www

if [[ -d "$APP_DIR" ]]; then
    info "Diretório existente detectado. Removendo para instalação limpa..."
    rm -rf "$APP_DIR"
fi

info "Clonando repositório: github.com/GuilhermeSantiago921/Vistoria..."
git clone --depth=1 "$GITHUB_REPO" "$APP_DIR" 2>/dev/null \
    || error "Falha ao clonar repositório. Verifique a conexão e o repositório."

[[ -f "$APP_DIR/artisan" ]] || error "Repositório inválido: arquivo 'artisan' não encontrado."
success "Repositório clonado com sucesso"

# ═══════════════════════════════════════════════════════════════════════════════
step "Gerando Arquivo de Configuração (.env)"
# ═══════════════════════════════════════════════════════════════════════════════
cd "$APP_DIR"

cp .env.example .env
php artisan key:generate --force --quiet
APP_KEY=$(grep "^APP_KEY=" .env | cut -d'=' -f2-)

cat > .env << EOF
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
MAIL_FROM_NAME="\${APP_NAME}"

VITE_APP_NAME="\${APP_NAME}"
EOF

success "Arquivo .env criado"

# ═══════════════════════════════════════════════════════════════════════════════
step "Instalando Dependências PHP (Composer)"
# ═══════════════════════════════════════════════════════════════════════════════

# Definir HOME do www-data para evitar erro de escrita em /var/www/.config/psysh
export HOME=/root

info "Instalando pacotes do Composer (modo produção)..."
composer install --no-dev --optimize-autoloader --no-interaction --quiet 2>/dev/null
success "Dependências PHP instaladas"

# ═══════════════════════════════════════════════════════════════════════════════
step "Compilando Assets (CSS/JavaScript)"
# ═══════════════════════════════════════════════════════════════════════════════
info "Instalando pacotes NPM..."
npm ci --silent 2>/dev/null
info "Compilando assets para produção..."
npm run build 2>/dev/null
success "Assets compilados com sucesso"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Permissões de Arquivos"
# ═══════════════════════════════════════════════════════════════════════════════
chown -R www-data:www-data "$APP_DIR"
find "$APP_DIR" -type f -exec chmod 644 {} \;
find "$APP_DIR" -type d -exec chmod 755 {} \;
chmod -R 775 "$APP_DIR/storage"
chmod -R 775 "$APP_DIR/bootstrap/cache"
chmod +x "$APP_DIR/artisan"
success "Permissões configuradas"

# ═══════════════════════════════════════════════════════════════════════════════
step "Criando Tabelas no Banco de Dados"
# ═══════════════════════════════════════════════════════════════════════════════
info "Executando migrações..."
php artisan migrate --force 2>/dev/null || error "Falha ao executar as migrações. Verifique as credenciais do banco."
success "Tabelas criadas com sucesso"

# Link de storage
php artisan storage:link --quiet 2>/dev/null || true

# Seeders (dados iniciais)
if php artisan db:seed --force --quiet 2>/dev/null; then
    info "Criando dados iniciais..."
    success "Dados iniciais inseridos"
fi

# Cache de produção
php artisan config:cache  --quiet 2>/dev/null
php artisan route:cache   --quiet 2>/dev/null
php artisan view:cache    --quiet 2>/dev/null

# ═══════════════════════════════════════════════════════════════════════════════
step "Criando Usuário Administrador"
# ═══════════════════════════════════════════════════════════════════════════════
info "Criando conta de administrador '${ADMIN_EMAIL}'..."

# Usar PHP diretamente via script temporário (evita erro de permissão do PsySH/tinker)
ADMIN_SCRIPT=$(mktemp /tmp/vistoria_admin_XXXXXX.php)
cat > "$ADMIN_SCRIPT" << 'PHPEOF'
<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$email   = getenv('ADMIN_EMAIL');
$name    = getenv('ADMIN_NAME');
$password = getenv('ADMIN_PASSWORD');

$existing = \App\Models\User::where('email', $email)->first();
if ($existing) {
    echo "Usuário já existe: {$email}\n";
    exit(0);
}

$user = new \App\Models\User();
$user->name     = $name;
$user->email    = $email;
$user->password = \Illuminate\Support\Facades\Hash::make($password);
$user->email_verified_at = now();

$fillable = $user->getFillable();
if (in_array('role', $fillable) || $user->getTable()) {
    try { $user->role = 'admin'; } catch (\Exception $e) {}
}
try { $user->inspection_credits = 999; } catch (\Exception $e) {}

$user->save();
echo "Admin criado com sucesso: {$email}\n";
PHPEOF

# Rodar como www-data com HOME correto para evitar erro do PsySH
ADMIN_EMAIL="$ADMIN_EMAIL" ADMIN_NAME="$ADMIN_NAME" ADMIN_PASSWORD="$ADMIN_PASSWORD" \
    HOME=/tmp \
    php "$ADMIN_SCRIPT" \
    && success "Usuário administrador criado" \
    || error "Falha ao criar usuário administrador"

rm -f "$ADMIN_SCRIPT"

# Reajustar permissões após execução de scripts
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Supervisor (Filas em Background)"
# ═══════════════════════════════════════════════════════════════════════════════
apt-get install -y -qq supervisor 2>/dev/null

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

systemctl enable supervisor > /dev/null 2>&1
systemctl start supervisor  > /dev/null 2>&1
supervisorctl reread > /dev/null 2>&1
supervisorctl update > /dev/null 2>&1
supervisorctl start vistoria-worker:* > /dev/null 2>&1 || true
success "Supervisor configurado (2 workers de fila ativos)"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando Firewall (UFW)"
# ═══════════════════════════════════════════════════════════════════════════════
ufw --force reset > /dev/null 2>&1
ufw default deny incoming  > /dev/null 2>&1
ufw default allow outgoing > /dev/null 2>&1
ufw allow 22/tcp  comment 'SSH'   > /dev/null 2>&1
ufw allow 80/tcp  comment 'HTTP'  > /dev/null 2>&1
ufw allow 443/tcp comment 'HTTPS' > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
success "Firewall UFW configurado (portas 22, 80, 443 abertas)"

# ═══════════════════════════════════════════════════════════════════════════════
step "Configurando SSL com Let's Encrypt"
# ═══════════════════════════════════════════════════════════════════════════════
if echo "$INSTALL_SSL" | grep -qi '^s'; then
    if [[ ! "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        info "Instalando Certbot..."
        apt-get install -y -qq certbot python3-certbot-nginx 2>/dev/null
        info "Emitindo certificado para ${DOMAIN}..."
        if certbot --nginx \
            -d "${DOMAIN}" \
            -d "www.${DOMAIN}" \
            --non-interactive \
            --agree-tos \
            --email "${ADMIN_EMAIL}" \
            --redirect 2>/dev/null; then
            sed -i "s|APP_URL=http://|APP_URL=https://|g" "${APP_DIR}/.env"
            APP_URL="${APP_URL/http:\/\//https://}"
            php artisan config:cache --quiet 2>/dev/null
            success "Certificado SSL instalado com sucesso"
        else
            warn "Certbot falhou. Verifique se o DNS de '${DOMAIN}' aponta para este servidor."
            warn "Para instalar SSL depois: sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}"
        fi
    else
        warn "SSL ignorado: '${DOMAIN}' é um endereço IP. Let's Encrypt exige um domínio."
    fi
else
    info "SSL ignorado conforme escolha do usuário."
fi

# ── Cron: schedule:run + renovação automática de SSL ──────────────────────────
(crontab -l 2>/dev/null | grep -v 'artisan schedule\|certbot renew' || true
 echo "* * * * * www-data php ${APP_DIR}/artisan schedule:run >> /dev/null 2>&1"
 echo "0 3 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'"
) | crontab -
success "Cron configurado (schedule:run + renovação SSL diária às 03:00)"

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
echo -e "  💾 Tipo        : ${GREEN}MySQL 8${NC}"
echo -e "  �️  Banco       : ${GREEN}${DB_DATABASE}${NC}"
echo -e "  � Usuário     : ${GREEN}${DB_USERNAME}${NC}"
echo -e "  📄 Credenciais : ${GREEN}/root/.vistoria_mysql_credentials${NC}"
echo
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  ARQUIVOS IMPORTANTES${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  📁 Aplicação   : ${CYAN}${APP_DIR}${NC}"
echo -e "  ⚙️  Configuração: ${CYAN}${APP_DIR}/.env${NC}"
echo -e "  📋 Logs        : ${CYAN}${APP_DIR}/storage/logs/laravel.log${NC}"
echo -e "  🔧 Nginx       : ${CYAN}/etc/nginx/sites-available/vistoria${NC}"
echo -e "  📝 Log install : ${CYAN}${LOG_FILE}${NC}"
echo
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}  PRÓXIMOS PASSOS${NC}"
echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "  1. Certifique-se que o DNS de ${BOLD}${DOMAIN}${NC} aponta para este servidor"
echo -e "  2. Configure e-mail em ${CYAN}${APP_DIR}/.env${NC} (variáveis MAIL_*)"
echo -e "     e execute: ${YELLOW}cd ${APP_DIR} && php artisan config:cache${NC}"
echo -e "  3. Acesse ${BOLD}${APP_URL}${NC} e faça login"
echo -e "  4. ${RED}⚠  Guarde as credenciais acima em local seguro!${NC}"
echo
echo -e "  ${GREEN}Sistema pronto para uso! 🚀${NC}"
echo
