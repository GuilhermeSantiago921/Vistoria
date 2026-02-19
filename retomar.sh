#!/bin/bash

# =============================================================================
# 🔄 SISTEMA DE VISTORIA VEICULAR - SCRIPT DE RETOMADA
# =============================================================================
# Use este script quando a instalação parou no meio.
#
# USO RECOMENDADO (baixar e executar - mais confiável):
#   wget -O retomar.sh https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/retomar.sh
#   sudo bash retomar.sh
#
# OU via pipe (também funciona):
#   curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/retomar.sh | sudo bash
# =============================================================================

set -e

# ── Abrir /dev/tty como file descriptor 3 ────────────────────────────────────
# Esta é a técnica mais robusta para leitura interativa.
# Funciona tanto em execução direta quanto via "curl | bash" ou "bash <(curl)".
# exec </dev/tty pode falhar em bash em modo pipe no Ubuntu 22.04+
# Usar fd 3 é garantido em todas as versões.
if ! exec 3</dev/tty 2>/dev/null; then
    echo "ERRO: Não foi possível abrir o terminal para entrada interativa."
    echo ""
    echo "Use o método recomendado:"
    echo "  wget -O retomar.sh https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/retomar.sh"
    echo "  sudo bash retomar.sh"
    exit 1
fi

# Função auxiliar de leitura — usa fd 3 (terminal direto)
ler()  { read -r  "$@" <&3; }
lersp(){ read -rs "$@" <&3; }

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
passo "Informações para Configuração"
echo ""
echo -e "  ${AMARELO}Preencha os dados abaixo. ENTER = valor padrão [entre colchetes].${RESET}"
echo ""

local_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

# URL
echo -ne "  URL do sistema [http://${local_IP}]: "
ler APP_URL
APP_URL="${APP_URL:-http://${local_IP}}"

echo ""
echo -e "  ${NEGRITO}── Banco de Dados MySQL ──────────────────────────────${RESET}"

# Senha root
while true; do
    echo -ne "  Senha ROOT do MySQL: "
    lersp MYSQL_ROOT_PASSWORD; echo ""
    [[ -n "$MYSQL_ROOT_PASSWORD" ]] && break
    echo -e "  ${VERMELHO}Senha não pode ser vazia.${RESET}"
done

echo -ne "  Nome do banco [vistoria]: "
ler DB_NAME; DB_NAME="${DB_NAME:-vistoria}"

echo -ne "  Usuário do banco [vistoria_user]: "
ler DB_USER; DB_USER="${DB_USER:-vistoria_user}"

while true; do
    echo -ne "  Senha do usuário do banco: "
    lersp DB_PASSWORD; echo ""
    [[ -n "$DB_PASSWORD" ]] && break
    echo -e "  ${VERMELHO}Senha não pode ser vazia.${RESET}"
done

echo ""
echo -e "  ${NEGRITO}── Administrador do Sistema ──────────────────────────${RESET}"

echo -ne "  Nome do administrador [Administrador]: "
ler ADMIN_NAME; ADMIN_NAME="${ADMIN_NAME:-Administrador}"

while true; do
    echo -ne "  E-mail do administrador [admin@vistoria.com.br]: "
    ler ADMIN_EMAIL; ADMIN_EMAIL="${ADMIN_EMAIL:-admin@vistoria.com.br}"
    [[ "$ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && break
    echo -e "  ${VERMELHO}E-mail inválido.${RESET}"
done

while true; do
    echo -ne "  Senha do administrador (mín. 8 caracteres): "
    lersp ADMIN_PASSWORD; echo ""
    [[ ${#ADMIN_PASSWORD} -ge 8 ]] && break
    echo -e "  ${VERMELHO}Senha muito curta (mínimo 8 caracteres).${RESET}"
done

# Confirmação
echo ""
echo -e "${AMARELO}  ┌─────────────────────────────────────────────────────────┐"
echo -e "  │              RESUMO DA CONFIGURAÇÃO                       │"
echo -e "  ├─────────────────────────────────────────────────────────┤"
echo -e "  │  URL:          ${BRANCO}${APP_URL}${AMARELO}"
echo -e "  │  Banco:        ${BRANCO}${DB_NAME}${AMARELO}  Usuário: ${BRANCO}${DB_USER}${AMARELO}"
echo -e "  │  Admin:        ${BRANCO}${ADMIN_EMAIL}${AMARELO}"
echo -e "  │  Diretório:    ${BRANCO}${INSTALL_DIR}${AMARELO}"
echo -e "  └─────────────────────────────────────────────────────────┘${RESET}"
echo ""
echo -ne "  Confirmar e iniciar? [S/n]: "
ler CONFIRMAR
[[ "$CONFIRMAR" =~ ^[Nn]$ ]] && { echo "Cancelado."; exit 0; }

# Fechar fd 3 — não precisamos mais de leitura interativa
exec 3>&-

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
nginx -t >> "$LOG_FILE" 2>&1 || erro "Config Nginx inválida — verifique: $LOG_FILE"
executar systemctl enable nginx
executar systemctl restart nginx
ok "Nginx configurado e rodando"

# ── 2. Banco de dados ─────────────────────────────────────────────────────────
passo "Verificando Banco de Dados"
executar systemctl start mysql
executar systemctl enable mysql

# Verificar se a senha root está correta antes de continuar
info "Verificando acesso root ao MySQL..."
if ! mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" >> "$LOG_FILE" 2>&1; then
    erro "Senha root do MySQL incorreta. Execute novamente e informe a senha correta."
fi
ok "Acesso root confirmado"

# Criar banco de dados
info "Criando banco de dados '${DB_NAME}'..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" \
    >> "$LOG_FILE" 2>&1 || erro "Falha ao criar banco de dados"
ok "Banco de dados criado"

# Configurar usuário com múltiplas tentativas para garantir
info "Configurando usuário '${DB_USER}'..."

# Primeiro, tentar ALTER USER se o usuário já existir
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';" \
    >> "$LOG_FILE" 2>&1 || {
        # Se ALTER falhar (usuário não existe), criar novo
        info "Usuário não existe, criando novo..."
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
            -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';" \
            >> "$LOG_FILE" 2>&1 || erro "Falha ao criar usuário MySQL"
    }

# Garantir privilégios
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';" \
    >> "$LOG_FILE" 2>&1 || erro "Falha ao conceder privilégios"

# Flush múltiplas vezes para garantir
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "FLUSH PRIVILEGES;" \
    >> "$LOG_FILE" 2>&1 || erro "Falha no FLUSH PRIVILEGES"

# Aguardar um pouco para o MySQL processar
sleep 2

# Testar conexão múltiplas vezes
info "Testando acesso do usuário ao banco..."
for i in {1..5}; do
    if mysql -u "${DB_USER}" -p"${DB_PASSWORD}" -e "USE \`${DB_NAME}\`; SELECT 1;" >> "$LOG_FILE" 2>&1; then
        ok "Usuário '${DB_USER}' tem acesso ao banco '${DB_NAME}'"
        break
    else
        if [[ $i -eq 5 ]]; then
            erro "Usuário '${DB_USER}' criado mas sem acesso ao banco '${DB_NAME}' após 5 tentativas — verifique: $LOG_FILE"
        fi
        info "Tentativa $i falhou, tentando novamente em 2s..."
        sleep 2
        # Mais um flush por segurança
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;" >> "$LOG_FILE" 2>&1 || true
    fi
done

ok "Banco de dados e usuário verificados"

# ── 3. Clonar repositório ────────────────────────────────────────────────────
passo "Baixando Sistema do GitHub"

# Verificar conectividade com o GitHub antes de tentar
info "Verificando conectividade com GitHub..."
if ! curl -fsSL --max-time 10 "https://github.com" > /dev/null 2>&1; then
    erro "Sem acesso ao GitHub. Verifique a conexão com a internet."
fi
ok "GitHub acessível"

# Remover diretório anterior completamente — evita "dubious ownership" e
# problemas com repositório parcialmente clonado ou remote inválido.
info "Removendo instalação anterior (se houver)..."
if [[ -d "$INSTALL_DIR" ]]; then
    # Forçar dono para root antes de remover (evita permissão negada)
    chown -R root:root "$INSTALL_DIR" 2>/dev/null || true
    rm -rf "$INSTALL_DIR"
fi

# Garantir que o diretório pai existe
mkdir -p "$(dirname "$INSTALL_DIR")"

# Adicionar safe.directory globalmente para evitar erro de ownership
git config --global --add safe.directory "$INSTALL_DIR" 2>/dev/null || true

info "Clonando de github.com/${GITHUB_REPO}..."
git clone --depth=1 --branch "$GITHUB_BRANCH" \
    "https://github.com/${GITHUB_REPO}.git" \
    "$INSTALL_DIR" >> "$LOG_FILE" 2>&1 || erro "Falha no git clone — verifique: $LOG_FILE"

ok "Código baixado com sucesso"

# ── 4. Configurar .env ────────────────────────────────────────────────────────
passo "Gerando arquivo .env"
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
ok "Arquivo .env criado"

# ── 5. Composer ───────────────────────────────────────────────────────────────
passo "Instalando dependências PHP (Composer)"
cd "$INSTALL_DIR"
executar composer install --no-dev --optimize-autoloader --no-interaction
ok "Composer concluído"

# ── 6. NPM + build ────────────────────────────────────────────────────────────
passo "Compilando Assets (CSS/JavaScript)"
executar npm install --production=false
executar npm run build
ok "Assets compilados"

# ── 7. Permissões ─────────────────────────────────────────────────────────────
passo "Configurando Permissões de Arquivos"
executar chown -R www-data:www-data "$INSTALL_DIR"
executar find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
executar find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
executar chmod -R 775 "${INSTALL_DIR}/storage"
executar chmod -R 775 "${INSTALL_DIR}/bootstrap/cache"
executar chmod +x "${INSTALL_DIR}/artisan"
ok "Permissões configuradas"

# ── 8. Migrations ─────────────────────────────────────────────────────────────
passo "Criando Tabelas no Banco de Dados"
cd "$INSTALL_DIR"
sudo -u www-data php artisan migrate --force >> "$LOG_FILE" 2>&1 || erro "Falha nas migrations — verifique: $LOG_FILE"
sudo -u www-data php artisan db:seed --force  >> "$LOG_FILE" 2>&1 || aviso "Seeders com aviso (não crítico)"
ok "Tabelas criadas com sucesso"

# ── 9. Criar Administrador ────────────────────────────────────────────────────
passo "Criando Usuário Administrador"
sudo -u www-data php artisan tinker --execute="
    use App\Models\User;
    use Illuminate\Support\Facades\Hash;
    \$u = User::updateOrCreate(['email' => '${ADMIN_EMAIL}'], [
        'name'               => '${ADMIN_NAME}',
        'password'           => Hash::make('${ADMIN_PASSWORD}'),
        'role'               => 'admin',
        'payment_status'     => 'paid',
        'inspection_credits' => 9999,
        'email_verified_at'  => now(),
    ]);
    echo 'Criado: ' . \$u->email;
" >> "$LOG_FILE" 2>&1 || erro "Falha ao criar administrador — verifique: $LOG_FILE"
ok "Administrador criado: ${ADMIN_EMAIL}"

# ── 10. Otimizar Laravel ──────────────────────────────────────────────────────
passo "Otimizando a Aplicação"
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
passo "Configurando Agendador de Tarefas"
(crontab -l 2>/dev/null | grep -v "vistoria.*schedule:run"; \
 echo "* * * * * www-data cd ${INSTALL_DIR} && php artisan schedule:run >> /dev/null 2>&1") | crontab -
ok "Scheduler configurado"

# ── Relatório Final ───────────────────────────────────────────────────────────
echo ""
echo -e "${VERDE}"
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║        ✅  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  🌐 ${NEGRITO}Acesse o sistema:${RESET}  ${VERDE}${APP_URL}${RESET}"
echo ""
echo -e "  ${NEGRITO}── ACESSO ADMINISTRADOR ──────────────────────────────${RESET}"
echo -e "  📧 E-mail:  ${AMARELO}${ADMIN_EMAIL}${RESET}"
echo -e "  🔒 Senha:   ${AMARELO}${ADMIN_PASSWORD}${RESET}"
echo ""
echo -e "  ${NEGRITO}── BANCO DE DADOS ────────────────────────────────────${RESET}"
echo -e "  🗄️  Banco:   ${DB_NAME}   Usuário: ${DB_USER}"
echo ""
echo -e "  ${NEGRITO}── COMANDOS ÚTEIS ────────────────────────────────────${RESET}"
echo -e "  ${CIANO}tail -f ${INSTALL_DIR}/storage/logs/laravel.log${RESET}"
echo -e "  ${CIANO}systemctl restart nginx php${PHP_VERSION}-fpm mysql${RESET}"
echo -e "  ${CIANO}systemctl status vistoria-queue${RESET}"
echo ""
echo -e "  📄 Log completo: ${AMARELO}${LOG_FILE}${RESET}"
echo ""
echo -e "${AMARELO}  ⚠️  IMPORTANTE: Guarde as credenciais acima em local seguro!${RESET}"
echo ""


VERMELHO='\033[0;31m'
