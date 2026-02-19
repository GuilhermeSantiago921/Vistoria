#!/bin/bash

# =============================================================================
# 🔄 SISTEMA DE VISTORIA VEICULAR - SCRIPT DE RETOMADA
# =============================================================================
# Use este script quando a instalação parou no meio.
# Ele continua a partir do ponto onde parou (Nginx já ok, MySQL já ok).
#
# USO:
#   sudo bash retomar.sh
# =============================================================================

set -e

VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
CIANO='\033[0;36m'
BRANCO='\033[1;37m'
NEGRITO='\033[1m'
RESET='\033[0m'

LOG_FILE="/tmp/vistoria-retomar-$(date +%Y%m%d_%H%M%S).log"
INSTALL_DIR="/var/www/vistoria"
PHP_VERSION="8.2"
GITHUB_REPO="GuilhermeSantiago921/Vistoria"
GITHUB_BRANCH="main"

touch "$LOG_FILE"
chmod 600 "$LOG_FILE"

passo() { echo -e "\n${AZUL}${NEGRITO}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
ok()    { echo -e "  ${VERDE}✔${RESET}  $1"; }
info()  { echo -e "  ${CIANO}ℹ${RESET}  $1"; }
aviso() { echo -e "  ${AMARELO}⚠${RESET}  $1"; }
erro()  { echo -e "  ${VERMELHO}✘  ERRO: $1${RESET}"; echo -e "\n  Log em: ${AMARELO}$LOG_FILE${RESET}"; exit 1; }

executar() {
    if ! "$@" >> "$LOG_FILE" 2>&1; then
        erro "Falha ao executar: $*"
    fi
}

if [[ $EUID -ne 0 ]]; then
    echo -e "${VERMELHO}Execute como root: sudo bash retomar.sh${RESET}"
    exit 1
fi

clear
echo -e "${AZUL}"
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║       🔄  RETOMANDO INSTALAÇÃO DO SISTEMA                   ║"
echo "  ║          Sistema de Vistoria Veicular v2.0                  ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  ${CIANO}Log:${RESET} $LOG_FILE"
echo ""

# ── Coletar informações necessárias ──────────────────────────────────────────
exec < /dev/tty

passo "Informações Necessárias para Retomar"
echo ""

local_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
read -rp "  URL do sistema [http://${local_IP}]: " APP_URL </dev/tty
APP_URL="${APP_URL:-http://${local_IP}}"

echo ""
read -rsp "  Senha ROOT do MySQL: " MYSQL_ROOT_PASSWORD </dev/tty
echo ""
read -rp "  Nome do banco [vistoria]: " DB_NAME </dev/tty
DB_NAME="${DB_NAME:-vistoria}"
read -rp "  Usuário do banco [vistoria_user]: " DB_USER </dev/tty
DB_USER="${DB_USER:-vistoria_user}"
read -rsp "  Senha do usuário do banco: " DB_PASSWORD </dev/tty
echo ""

echo ""
read -rp "  Nome do administrador [Administrador]: " ADMIN_NAME </dev/tty
ADMIN_NAME="${ADMIN_NAME:-Administrador}"
read -rp "  E-mail do administrador [admin@vistoria.com.br]: " ADMIN_EMAIL </dev/tty
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@vistoria.com.br}"
read -rsp "  Senha do administrador: " ADMIN_PASSWORD </dev/tty
echo ""

echo ""
echo -e "${AMARELO}  Retomando com: URL=${BRANCO}${APP_URL}${AMARELO}  BD=${BRANCO}${DB_NAME}${AMARELO}  Admin=${BRANCO}${ADMIN_EMAIL}${RESET}"
read -rp "  Confirmar? [S/n]: " OK </dev/tty
[[ "$OK" =~ ^[Nn]$ ]] && exit 0

# ── 1. Garantir Nginx ok ──────────────────────────────────────────────────────
passo "Verificando Nginx"
if systemctl is-active --quiet apache2 2>/dev/null; then
    info "Parando Apache2..."
    executar systemctl stop apache2
    executar systemctl disable apache2
    ok "Apache2 parado"
fi

cat > /etc/nginx/sites-available/vistoria << NGINXEOF
server {
    listen 80;
    listen [::]:80;
    server_name _;
    root /var/www/vistoria/public;
    index index.php index.html;
    charset utf-8;
    client_max_body_size 64M;
    access_log /var/log/nginx/vistoria-access.log;
    error_log  /var/log/nginx/vistoria-error.log;
    server_tokens off;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    location ~ /\.ht { deny all; }
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
NGINXEOF

ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria
rm -f /etc/nginx/sites-enabled/default
nginx -t >> "$LOG_FILE" 2>&1 || erro "Config Nginx inválida"
executar systemctl enable nginx
executar systemctl restart nginx
ok "Nginx configurado e rodando"

# ── 2. Banco de dados ─────────────────────────────────────────────────────────
passo "Verificando Banco de Dados"
executar systemctl start mysql
executar systemctl enable mysql

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" \
    >> "$LOG_FILE" 2>&1 || erro "Falha ao criar banco"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';" \
    >> "$LOG_FILE" 2>&1 || true
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;" \
    >> "$LOG_FILE" 2>&1 || erro "Falha ao configurar usuário"
ok "Banco de dados e usuário verificados"

# ── 3. Clonar/atualizar repositório ──────────────────────────────────────────
passo "Baixando Sistema do GitHub"
if [[ -d "${INSTALL_DIR}/.git" ]]; then
    info "Atualizando repositório existente..."
    cd "$INSTALL_DIR"
    executar git fetch origin
    executar git reset --hard "origin/${GITHUB_BRANCH}"
else
    info "Clonando de github.com/${GITHUB_REPO}..."
    rm -rf "$INSTALL_DIR"
    executar git clone --depth=1 --branch "$GITHUB_BRANCH" \
        "https://github.com/${GITHUB_REPO}.git" "$INSTALL_DIR"
fi
ok "Código baixado"

# ── 4. Configurar .env ────────────────────────────────────────────────────────
passo "Gerando .env"
APP_KEY="base64:$(openssl rand -base64 32)"
cat > "${INSTALL_DIR}/.env" << ENVEOF
APP_NAME="Vistoria Veicular"
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}
APP_LOCALE=pt_BR
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=pt_BR
APP_MAINTENANCE_DRIVER=file
BCRYPT_ROUNDS=12
LOG_CHANNEL=stack
LOG_STACK=single
LOG_LEVEL=error
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null
CACHE_STORE=file
CACHE_PREFIX=vistoria_
QUEUE_CONNECTION=database
BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
MAIL_MAILER=log
MAIL_FROM_ADDRESS=noreply@vistoria.com.br
MAIL_FROM_NAME="Vistoria Veicular"
ENVEOF
ok ".env criado"

# ── 5. Composer ───────────────────────────────────────────────────────────────
passo "Instalando dependências PHP"
cd "$INSTALL_DIR"
executar composer install --no-dev --optimize-autoloader --no-interaction
ok "Composer ok"

# ── 6. NPM + build ────────────────────────────────────────────────────────────
passo "Compilando Assets (CSS/JS)"
executar npm install --production=false
executar npm run build
ok "Assets compilados"

# ── 7. Permissões ─────────────────────────────────────────────────────────────
passo "Configurando Permissões"
executar chown -R www-data:www-data "$INSTALL_DIR"
executar find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
executar find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
executar chmod -R 775 "${INSTALL_DIR}/storage"
executar chmod -R 775 "${INSTALL_DIR}/bootstrap/cache"
executar chmod +x "${INSTALL_DIR}/artisan"
ok "Permissões configuradas"

# ── 8. Migrations ─────────────────────────────────────────────────────────────
passo "Criando Tabelas no Banco"
cd "$INSTALL_DIR"
sudo -u www-data php artisan migrate --force >> "$LOG_FILE" 2>&1 || erro "Falha nas migrations"
sudo -u www-data php artisan db:seed --force  >> "$LOG_FILE" 2>&1 || aviso "Seeders com aviso (não crítico)"
ok "Tabelas criadas"

# ── 9. Admin ──────────────────────────────────────────────────────────────────
passo "Criando Administrador"
sudo -u www-data php artisan tinker --execute="
    use App\Models\User;
    use Illuminate\Support\Facades\Hash;
    \$u = User::updateOrCreate(['email' => '${ADMIN_EMAIL}'], [
        'name'  => '${ADMIN_NAME}',
        'password' => Hash::make('${ADMIN_PASSWORD}'),
        'role'  => 'admin',
        'payment_status' => 'paid',
        'inspection_credits' => 9999,
        'email_verified_at' => now(),
    ]);
    echo 'OK: ' . \$u->email;
" >> "$LOG_FILE" 2>&1 || erro "Falha ao criar admin"
ok "Administrador criado: $ADMIN_EMAIL"

# ── 10. Otimizar Laravel ──────────────────────────────────────────────────────
passo "Otimizando Laravel"
cd "$INSTALL_DIR"
sudo -u www-data php artisan config:clear  >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan route:clear   >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan view:clear    >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan config:cache  >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan route:cache   >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan view:cache    >> "$LOG_FILE" 2>&1
sudo -u www-data php artisan storage:link  >> "$LOG_FILE" 2>&1
ok "Laravel otimizado"

# ── 11. Queue Worker ──────────────────────────────────────────────────────────
passo "Configurando Queue Worker"
cat > /etc/systemd/system/vistoria-queue.service << SVCEOF
[Unit]
Description=Vistoria Queue Worker
After=network.target mysql.service
[Service]
User=www-data
Group=www-data
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/php artisan queue:work --sleep=3 --tries=3 --max-time=3600
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
SVCEOF
executar systemctl daemon-reload
executar systemctl enable vistoria-queue
executar systemctl restart vistoria-queue
ok "Queue worker ativo"

# ── 12. Scheduler ─────────────────────────────────────────────────────────────
passo "Configurando Scheduler"
(crontab -l 2>/dev/null | grep -v "vistoria.*schedule:run"; \
 echo "* * * * * www-data cd ${INSTALL_DIR} && php artisan schedule:run >> /dev/null 2>&1") | crontab -
ok "Scheduler configurado"

# ── Relatório ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${VERDE}"
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║        ✅  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  🌐 ${NEGRITO}Acesse:${RESET}  ${VERDE}${APP_URL}${RESET}"
echo ""
echo -e "  ${NEGRITO}── ADMINISTRADOR ─────────────────────────────────────${RESET}"
echo -e "  📧 E-mail:   ${AMARELO}${ADMIN_EMAIL}${RESET}"
echo -e "  🔒 Senha:    ${AMARELO}${ADMIN_PASSWORD}${RESET}"
echo ""
echo -e "  ${NEGRITO}── BANCO DE DADOS ────────────────────────────────────${RESET}"
echo -e "  🗄️  Banco:    ${DB_NAME}   Usuário: ${DB_USER}"
echo ""
echo -e "  📄 Log: ${AMARELO}${LOG_FILE}${RESET}"
echo -e "${AMARELO}  ⚠️  Guarde as credenciais acima em local seguro!${RESET}"
echo ""
