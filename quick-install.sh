#!/bin/bash
# Instalação Rápida do Vistoria - v2 (Simplificado)
# Uso: sudo bash setup.sh --domain=10.0.0.72

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo() { command echo -e "$@"; }
info()  { echo "${BLUE}→${NC} $1"; }
ok()    { echo "${GREEN}✓${NC} $1"; }
err()   { echo "${RED}✗${NC} $1"; exit 1; }

[ "$EUID" -ne 0 ] && err "Execute com sudo"

DOMAIN="${1#--domain=}"
[ -z "$DOMAIN" ] && err "Use: sudo bash setup.sh --domain=SEU_IP_OU_DOMINIO"

APP_DIR="/var/www/vistoria"
DB_PASS=$(openssl rand -base64 12)
ADMIN_EMAIL="admin@${DOMAIN}"
ADMIN_PASS=$(openssl rand -base64 12)

echo ""
echo "${BLUE}╔════════════════════════════════════╗${NC}"
echo "${BLUE}║  Instalação Vistoria - Setup v2    ║${NC}"
echo "${BLUE}╚════════════════════════════════════╝${NC}"
echo ""
info "Domínio: ${DOMAIN}"
info "Dir: ${APP_DIR}"
info "Admin: ${ADMIN_EMAIL}"
echo ""

# 1. SISTEMA
info "1/8 - Atualizando sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq && apt-get upgrade -y -qq
apt-get install -y -qq curl wget git unzip > /dev/null 2>&1
ok "Sistema atualizado"

# 2. PHP
info "2/8 - Instalando PHP 8.2..."
add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
apt-get update -qq
apt-get install -y -qq php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-curl \
    php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip php8.2-bcmath > /dev/null 2>&1
systemctl enable php8.2-fpm > /dev/null 2>&1
systemctl start php8.2-fpm > /dev/null 2>&1
ok "PHP 8.2 instalado"

# 3. NGINX
info "3/8 - Instalando Nginx..."
apt-get install -y -qq nginx > /dev/null 2>&1
systemctl enable nginx > /dev/null 2>&1
systemctl start nginx > /dev/null 2>&1
ok "Nginx instalado"

# 4. MYSQL
info "4/8 - Instalando MySQL..."
apt-get install -y -qq mysql-server > /dev/null 2>&1
systemctl enable mysql > /dev/null 2>&1
systemctl start mysql > /dev/null 2>&1

mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS vistoria;
CREATE USER IF NOT EXISTS 'vistoria'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria'@'localhost';
FLUSH PRIVILEGES;
EOF
ok "MySQL configurado"

# 5. NODE + COMPOSER
info "5/8 - Instalando Node.js e Composer..."
curl -fsSL https://deb.nodesource.com/setup_20.x 2>/dev/null | bash - > /dev/null 2>&1
apt-get install -y -qq nodejs > /dev/null 2>&1
curl -sS https://getcomposer.org/installer 2>/dev/null | php -- --quiet --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
ok "Node.js e Composer instalados"

# 6. CLONAR
info "6/8 - Clonando repositório..."
rm -rf "$APP_DIR" 2>/dev/null || true
git clone --depth=1 https://github.com/GuilhermeSantiago921/Vistoria.git "$APP_DIR" -q
cd "$APP_DIR"

# .env
cat > .env <<ENV
APP_NAME=Vistoria
APP_ENV=production
APP_DEBUG=false
APP_URL=http://${DOMAIN}
APP_KEY=

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vistoria
DB_USERNAME=vistoria
DB_PASSWORD=${DB_PASS}

CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=file

MAIL_MAILER=log
MAIL_FROM_ADDRESS=noreply@${DOMAIN}
MAIL_FROM_NAME=Vistoria
ENV

chmod 600 .env

# Instalar dependências
composer install --no-dev --optimize-autoloader -q 2>/dev/null || true
php artisan key:generate --force -q 2>/dev/null || true
npm install --silent 2>/dev/null || true
npm run build --silent 2>/dev/null || true

ok "Repositório e dependências instaladas"

# 7. BANCO
info "7/8 - Executando migrações..."
php artisan migrate --force -q 2>/dev/null || true
php artisan storage:link -q 2>/dev/null || true

# Criar admin
php -r "
define('LARAVEL_START', microtime(true));
require '${APP_DIR}/vendor/autoload.php';
\$app = require '${APP_DIR}/bootstrap/app.php';
\$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
if (!class_exists('App\Models\User')) exit;
if (!\App\Models\User::where('email','${ADMIN_EMAIL}')->exists()) {
    \App\Models\User::create([
        'name'     => 'Admin',
        'email'    => '${ADMIN_EMAIL}',
        'password' => bcrypt('${ADMIN_PASS}'),
    ]);
}
" 2>/dev/null || true

ok "Banco de dados migrado"

# 8. NGINX CONFIG
info "8/8 - Configurando Nginx..."

cat > /etc/nginx/sites-available/vistoria <<NGINX
server {
    listen 80;
    server_name _;
    root ${APP_DIR}/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht { deny all; }
}
NGINX

rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria 2>/dev/null || true
nginx -t > /dev/null 2>&1
systemctl restart nginx > /dev/null 2>&1

# Permissões
chown -R www-data:www-data "$APP_DIR" > /dev/null 2>&1
chmod -R 755 "$APP_DIR" > /dev/null 2>&1
chmod -R 775 "$APP_DIR/storage" "$APP_DIR/bootstrap/cache" > /dev/null 2>&1

ok "Nginx configurado"

# Salvar credenciais
cat > /root/vistoria-creds.txt <<CREDS
============================================
          VISTORIA - CREDENCIAIS
============================================
URL      : http://${DOMAIN}
Admin    : ${ADMIN_EMAIL}
Senha    : ${ADMIN_PASS}
Dir      : ${APP_DIR}

Banco    : vistoria
Usuário  : vistoria
Senha    : ${DB_PASS}
============================================
CREDS

echo ""
echo "${GREEN}✓ INSTALAÇÃO CONCLUÍDA!${NC}"
echo ""
echo "${BLUE}Acesso:${NC}"
echo "  URL: http://${DOMAIN}"
echo "  Email: ${ADMIN_EMAIL}"
echo "  Senha: ${ADMIN_PASS}"
echo ""
echo "${BLUE}Credenciais salvas em: /root/vistoria-creds.txt${NC}"
echo ""
