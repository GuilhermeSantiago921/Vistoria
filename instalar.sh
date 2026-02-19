#!/bin/bash

# =============================================================================
# 🚗 SISTEMA DE VISTORIA VEICULAR - INSTALADOR AUTOMÁTICO
# =============================================================================
# Compatível com: Ubuntu 20.04+, Debian 11+
# Requisitos: Mínimo 1GB RAM, 10GB disco livre
#
# INSTALAÇÃO RÁPIDA (uma linha):
#   curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/vistoria/main/instalar.sh | sudo bash
#
# OU baixar e executar:
#   wget https://raw.githubusercontent.com/GuilhermeSantiago921/vistoria/main/instalar.sh
#   sudo bash instalar.sh
# =============================================================================

set -e

# ─── Cores para o terminal ────────────────────────────────────────────────────
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
CIANO='\033[0;36m'
BRANCO='\033[1;37m'
NEGRITO='\033[1m'
RESET='\033[0m'

# ─── Variáveis globais ────────────────────────────────────────────────────────
LOG_FILE="/tmp/vistoria-install-$(date +%Y%m%d_%H%M%S).log"
INSTALL_DIR="/var/www/vistoria"
PHP_VERSION="8.2"
GITHUB_REPO="GuilhermeSantiago921/vistoria"
GITHUB_BRANCH="main"
MYSQL_ROOT_PASSWORD=""
DB_NAME="vistoria"
DB_USER="vistoria_user"
DB_PASSWORD=""
APP_URL=""
APP_KEY=""
ADMIN_EMAIL=""
ADMIN_PASSWORD=""
ADMIN_NAME=""

# ─── Funções auxiliares ───────────────────────────────────────────────────────

imprimir_cabecalho() {
    clear
    echo -e "${AZUL}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║          🚗  SISTEMA DE VISTORIA VEICULAR                   ║"
    echo "  ║               Instalador Automático v2.0                    ║"
    echo "  ║         github.com/GuilhermeSantiago921/vistoria             ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "  ${CIANO}Logs salvos em:${RESET} $LOG_FILE"
    echo ""
}

passo() {
    echo -e "\n${AZUL}${NEGRITO}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

ok() {
    echo -e "  ${VERDE}✔${RESET}  $1"
}

info() {
    echo -e "  ${CIANO}ℹ${RESET}  $1"
}

aviso() {
    echo -e "  ${AMARELO}⚠${RESET}  $1"
}

erro() {
    echo -e "  ${VERMELHO}✘  ERRO: $1${RESET}"
    echo -e "\n  Verifique o log completo em: ${AMARELO}$LOG_FILE${RESET}"
    exit 1
}

executar() {
    # Executa o comando e salva no log sem mostrar saída ao usuário
    if ! "$@" >> "$LOG_FILE" 2>&1; then
        erro "Falha ao executar: $*"
    fi
}

executar_mysql() {
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "$1" >> "$LOG_FILE" 2>&1 || erro "Falha ao executar comando MySQL: $1"
}

# ─── Verificações iniciais ────────────────────────────────────────────────────

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${VERMELHO}Este script precisa ser executado como root.${RESET}"
        echo "Execute: sudo bash instalar.sh"
        exit 1
    fi
}

verificar_sistema_operacional() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
            aviso "Sistema operacional: $PRETTY_NAME"
            aviso "Este script foi testado em Ubuntu/Debian. Pode funcionar em outros sistemas."
            read -rp "  Deseja continuar mesmo assim? [s/N]: " resp
            [[ "$resp" =~ ^[Ss]$ ]] || exit 0
        fi
    fi
}

verificar_recursos() {
    passo "Verificando Recursos do Servidor"
    
    # RAM
    RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $RAM_MB -lt 512 ]]; then
        erro "RAM insuficiente: ${RAM_MB}MB. Mínimo necessário: 512MB"
    fi
    ok "RAM disponível: ${RAM_MB}MB"
    
    # Disco
    DISCO_GB=$(df -BG / | awk 'NR==2{gsub("G","",$4); print $4}')
    if [[ $DISCO_GB -lt 5 ]]; then
        erro "Espaço em disco insuficiente: ${DISCO_GB}GB. Mínimo necessário: 5GB"
    fi
    ok "Espaço em disco livre: ${DISCO_GB}GB"
    
    # Conexão com internet
    if ping -c 1 google.com &>/dev/null; then
        ok "Conexão com internet ativa"
    else
        erro "Sem conexão com a internet. Necessária para instalar dependências."
    fi
}

# ─── Coleta de informações ────────────────────────────────────────────────────

coletar_informacoes() {
    passo "Configuração do Sistema"
    echo ""
    echo -e "  ${AMARELO}Preencha as informações abaixo para configurar o sistema.${RESET}"
    echo -e "  ${AMARELO}Pressione ENTER para usar o valor padrão (entre colchetes).${RESET}"
    echo ""

    # ── URL da aplicação ──
    echo -e "  ${NEGRITO}1. URL de acesso ao sistema:${RESET}"
    echo -e "     Exemplos: http://meusite.com.br  |  http://192.168.1.100"
    read -rp "     URL [http://$(hostname -I | awk '{print $1}')]: " APP_URL
    APP_URL="${APP_URL:-http://$(hostname -I | awk '{print $1}')}"
    echo ""

    # ── Banco de dados ──
    echo -e "  ${NEGRITO}2. Configuração do Banco de Dados MySQL:${RESET}"
    echo ""
    
    while true; do
        read -rsp "     Senha para o usuário ROOT do MySQL: " MYSQL_ROOT_PASSWORD
        echo ""
        if [[ -z "$MYSQL_ROOT_PASSWORD" ]]; then
            echo -e "     ${VERMELHO}A senha não pode ser vazia.${RESET}"
        else
            read -rsp "     Confirme a senha root: " ROOT_CONFIRM
            echo ""
            if [[ "$MYSQL_ROOT_PASSWORD" == "$ROOT_CONFIRM" ]]; then
                break
            else
                echo -e "     ${VERMELHO}As senhas não coincidem. Tente novamente.${RESET}"
            fi
        fi
    done

    read -rp "     Nome do banco de dados [vistoria]: " DB_NAME
    DB_NAME="${DB_NAME:-vistoria}"

    read -rp "     Nome do usuário do banco [vistoria_user]: " DB_USER
    DB_USER="${DB_USER:-vistoria_user}"

    while true; do
        read -rsp "     Senha do usuário do banco: " DB_PASSWORD
        echo ""
        if [[ -z "$DB_PASSWORD" ]]; then
            echo -e "     ${VERMELHO}A senha não pode ser vazia.${RESET}"
        else
            read -rsp "     Confirme a senha do banco: " DB_CONFIRM
            echo ""
            if [[ "$DB_PASSWORD" == "$DB_CONFIRM" ]]; then
                break
            else
                echo -e "     ${VERMELHO}As senhas não coincidem. Tente novamente.${RESET}"
            fi
        fi
    done
    echo ""

    # ── Administrador ──
    echo -e "  ${NEGRITO}3. Conta de Administrador do Sistema:${RESET}"
    echo ""
    
    read -rp "     Nome completo do administrador [Administrador]: " ADMIN_NAME
    ADMIN_NAME="${ADMIN_NAME:-Administrador}"

    while true; do
        read -rp "     E-mail do administrador [admin@vistoria.com.br]: " ADMIN_EMAIL
        ADMIN_EMAIL="${ADMIN_EMAIL:-admin@vistoria.com.br}"
        if [[ "$ADMIN_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo -e "     ${VERMELHO}E-mail inválido. Tente novamente.${RESET}"
        fi
    done

    while true; do
        read -rsp "     Senha do administrador (mínimo 8 caracteres): " ADMIN_PASSWORD
        echo ""
        if [[ ${#ADMIN_PASSWORD} -lt 8 ]]; then
            echo -e "     ${VERMELHO}Senha muito curta. Mínimo 8 caracteres.${RESET}"
        else
            read -rsp "     Confirme a senha do administrador: " ADMIN_CONFIRM
            echo ""
            if [[ "$ADMIN_PASSWORD" == "$ADMIN_CONFIRM" ]]; then
                break
            else
                echo -e "     ${VERMELHO}As senhas não coincidem. Tente novamente.${RESET}"
            fi
        fi
    done

    # ── Confirmação ──
    echo ""
    echo -e "${AMARELO}  ┌─────────────────────────────────────────────────────────┐"
    echo -e "  │              RESUMO DA CONFIGURAÇÃO                       │"
    echo -e "  ├─────────────────────────────────────────────────────────┤"
    echo -e "  │  URL do sistema:    ${BRANCO}$APP_URL${AMARELO}"
    echo -e "  │  Banco de dados:    ${BRANCO}$DB_NAME${AMARELO}"
    echo -e "  │  Usuário do banco:  ${BRANCO}$DB_USER${AMARELO}"
    echo -e "  │  Admin - Nome:      ${BRANCO}$ADMIN_NAME${AMARELO}"
    echo -e "  │  Admin - E-mail:    ${BRANCO}$ADMIN_EMAIL${AMARELO}"
    echo -e "  │  Diretório:         ${BRANCO}$INSTALL_DIR${AMARELO}"
    echo -e "  └─────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    read -rp "  Confirmar e iniciar instalação? [S/n]: " CONFIRMAR
    if [[ "$CONFIRMAR" =~ ^[Nn]$ ]]; then
        echo "Instalação cancelada."
        exit 0
    fi
}

# ─── Instalação de dependências ───────────────────────────────────────────────

instalar_dependencias_sistema() {
    passo "Atualizando Sistema e Instalando Dependências"
    info "Atualizando pacotes do sistema..."
    executar apt-get update -y
    executar apt-get upgrade -y
    ok "Sistema atualizado"

    info "Instalando utilitários básicos..."
    executar apt-get install -y \
        curl wget git zip unzip \
        software-properties-common \
        apt-transport-https ca-certificates \
        gnupg2 lsb-release \
        net-tools ufw
    ok "Utilitários instalados"
}

instalar_php() {
    passo "Instalando PHP ${PHP_VERSION}"
    
    # Adicionar repositório PHP
    if ! command -v php &>/dev/null || [[ $(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') != "$PHP_VERSION" ]]; then
        info "Adicionando repositório PHP (ondrej/php)..."
        executar add-apt-repository -y ppa:ondrej/php
        executar apt-get update -y
        
        info "Instalando PHP ${PHP_VERSION} e extensões..."
        executar apt-get install -y \
            php${PHP_VERSION} \
            php${PHP_VERSION}-fpm \
            php${PHP_VERSION}-cli \
            php${PHP_VERSION}-mysql \
            php${PHP_VERSION}-pdo \
            php${PHP_VERSION}-mbstring \
            php${PHP_VERSION}-xml \
            php${PHP_VERSION}-zip \
            php${PHP_VERSION}-curl \
            php${PHP_VERSION}-gd \
            php${PHP_VERSION}-bcmath \
            php${PHP_VERSION}-intl \
            php${PHP_VERSION}-tokenizer \
            php${PHP_VERSION}-ctype \
            php${PHP_VERSION}-json \
            php${PHP_VERSION}-fileinfo \
            php${PHP_VERSION}-opcache
        ok "PHP ${PHP_VERSION} instalado"
    else
        ok "PHP ${PHP_VERSION} já instalado"
    fi

    # Configurar PHP para produção
    info "Otimizando configurações do PHP..."
    PHP_INI="/etc/php/${PHP_VERSION}/fpm/php.ini"
    if [[ -f "$PHP_INI" ]]; then
        sed -i 's/^upload_max_filesize.*/upload_max_filesize = 64M/' "$PHP_INI"
        sed -i 's/^post_max_size.*/post_max_size = 64M/' "$PHP_INI"
        sed -i 's/^memory_limit.*/memory_limit = 256M/' "$PHP_INI"
        sed -i 's/^max_execution_time.*/max_execution_time = 120/' "$PHP_INI"
        sed -i 's/^;date.timezone.*/date.timezone = America\/Sao_Paulo/' "$PHP_INI"
    fi
    ok "PHP configurado"
}

instalar_composer() {
    passo "Instalando Composer"
    if command -v composer &>/dev/null; then
        ok "Composer já instalado: $(composer --version 2>/dev/null | head -1)"
    else
        info "Baixando e instalando Composer..."
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" >> "$LOG_FILE" 2>&1
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [[ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]]; then
            rm composer-setup.php
            erro "Checksum do Composer inválido - possível download corrompido"
        fi

        php composer-setup.php --quiet >> "$LOG_FILE" 2>&1
        rm composer-setup.php
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
        ok "Composer instalado: $(composer --version 2>/dev/null | head -1)"
    fi
}

instalar_nodejs() {
    passo "Instalando Node.js e NPM"
    if command -v node &>/dev/null; then
        ok "Node.js já instalado: $(node --version)"
    else
        info "Instalando Node.js 20 LTS via NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
        executar apt-get install -y nodejs
        ok "Node.js instalado: $(node --version)"
        ok "NPM instalado: $(npm --version)"
    fi
}

instalar_nginx() {
    passo "Instalando e Configurando Nginx"
    if ! command -v nginx &>/dev/null; then
        executar apt-get install -y nginx
        ok "Nginx instalado"
    else
        ok "Nginx já instalado"
    fi

    info "Configurando Virtual Host para Vistoria..."
    cat > /etc/nginx/sites-available/vistoria << 'NGINXCONF'
server {
    listen 80;
    listen [::]:80;
    server_name _;

    root /var/www/vistoria/public;
    index index.php index.html;

    charset utf-8;
    client_max_body_size 64M;

    # Logs
    access_log /var/log/nginx/vistoria-access.log;
    error_log  /var/log/nginx/vistoria-error.log;

    # Segurança - ocultar versão do servidor
    server_tokens off;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/phpVERSION-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
}
NGINXCONF

    # Substituir a versão do PHP no config
    sed -i "s/phpVERSION/php${PHP_VERSION}/" /etc/nginx/sites-available/vistoria

    # Ativar o site
    ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/vistoria
    rm -f /etc/nginx/sites-enabled/default

    # Testar config
    nginx -t >> "$LOG_FILE" 2>&1 || erro "Configuração do Nginx inválida"
    executar systemctl restart nginx
    executar systemctl enable nginx
    ok "Nginx configurado e iniciado"
}

instalar_mysql() {
    passo "Instalando e Configurando MySQL"
    
    if command -v mysql &>/dev/null; then
        ok "MySQL já instalado: $(mysql --version | head -1)"
    else
        info "Instalando MySQL Server..."
        
        # Configurar instalação não interativa
        debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
        debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
        
        DEBIAN_FRONTEND=noninteractive executar apt-get install -y mysql-server
        ok "MySQL instalado"
    fi

    info "Iniciando MySQL..."
    executar systemctl start mysql
    executar systemctl enable mysql

    # Aguardar MySQL iniciar completamente
    info "Aguardando MySQL iniciar..."
    for i in {1..30}; do
        if mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; then
            break
        fi
        # Tentar sem senha (instalação nova)
        if mysqladmin ping -u root --silent 2>/dev/null; then
            # Definir senha root
            mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" >> "$LOG_FILE" 2>&1 || true
            mysql -u root -e "FLUSH PRIVILEGES;" >> "$LOG_FILE" 2>&1 || true
            break
        fi
        sleep 1
    done
    ok "MySQL iniciado"
}

configurar_banco_dados() {
    passo "Criando Banco de Dados e Usuário"
    
    info "Criando banco de dados '$DB_NAME'..."
    executar_mysql "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    ok "Banco de dados criado"

    info "Criando usuário '$DB_USER'..."
    executar_mysql "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
    executar_mysql "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';"
    executar_mysql "FLUSH PRIVILEGES;"
    ok "Usuário criado e permissões concedidas"
}

# ─── Instalação da aplicação ──────────────────────────────────────────────────

clonar_repositorio() {
    passo "Baixando Sistema do GitHub"
    
    # Garantir que git está instalado
    if ! command -v git &>/dev/null; then
        info "Instalando git..."
        executar apt-get install -y git
    fi

    if [[ -d "${INSTALL_DIR}/.git" ]]; then
        info "Repositório já existe. Atualizando para a versão mais recente..."
        cd "$INSTALL_DIR"
        executar git fetch origin
        executar git reset --hard "origin/${GITHUB_BRANCH}"
        ok "Código atualizado do GitHub"
    else
        info "Clonando repositório: github.com/${GITHUB_REPO}..."
        rm -rf "$INSTALL_DIR"
        executar git clone \
            --depth=1 \
            --branch "$GITHUB_BRANCH" \
            "https://github.com/${GITHUB_REPO}.git" \
            "$INSTALL_DIR"
        ok "Repositório clonado com sucesso"
    fi

    cd "$INSTALL_DIR"
}

configurar_env() {
    passo "Gerando Arquivo de Configuração (.env)"
    
    # Gerar APP_KEY
    APP_KEY="base64:$(openssl rand -base64 32)"
    
    cat > "${INSTALL_DIR}/.env" << ENVFILE
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

# ── Banco de Dados ──────────────────────────────────────
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

# ── Sessão ──────────────────────────────────────────────
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

# ── Cache e Filas ────────────────────────────────────────
CACHE_STORE=file
CACHE_PREFIX=vistoria_
QUEUE_CONNECTION=database
BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local

# ── E-mail (Configure conforme seu servidor SMTP) ────────
MAIL_MAILER=log
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS=noreply@vistoria.com.br
MAIL_FROM_NAME="Vistoria Veicular"
ENVFILE

    ok "Arquivo .env criado"
}

instalar_dependencias_php() {
    passo "Instalando Dependências PHP (Composer)"
    
    cd "$INSTALL_DIR"
    info "Instalando pacotes do Composer (modo produção)..."
    executar composer install --no-dev --optimize-autoloader --no-interaction
    ok "Dependências PHP instaladas"
}

instalar_dependencias_npm() {
    passo "Compilando Assets (CSS/JavaScript)"
    
    cd "$INSTALL_DIR"
    info "Instalando pacotes NPM..."
    executar npm install --production=false
    
    info "Compilando assets para produção..."
    executar npm run build
    ok "Assets compilados com sucesso"
}

configurar_permissoes() {
    passo "Configurando Permissões de Arquivos"
    
    # Criar usuário www-data se não existir (já existe no Ubuntu/Debian)
    id www-data &>/dev/null || executar useradd -r -s /bin/false www-data
    
    # Definir dono dos arquivos
    executar chown -R www-data:www-data "$INSTALL_DIR"
    
    # Permissões dos diretórios
    executar find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
    
    # Permissões dos arquivos
    executar find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
    
    # Pastas que precisam de escrita
    executar chmod -R 775 "${INSTALL_DIR}/storage"
    executar chmod -R 775 "${INSTALL_DIR}/bootstrap/cache"
    
    # Tornar o artisan executável
    executar chmod +x "${INSTALL_DIR}/artisan"
    
    ok "Permissões configuradas"
}

executar_migracoes() {
    passo "Criando Tabelas no Banco de Dados"
    
    cd "$INSTALL_DIR"
    info "Executando migrações..."
    sudo -u www-data php artisan migrate --force >> "$LOG_FILE" 2>&1 || erro "Falha ao executar migrações"
    ok "Tabelas criadas com sucesso"
    
    info "Criando dados iniciais..."
    sudo -u www-data php artisan db:seed --force >> "$LOG_FILE" 2>&1 || aviso "Aviso: Falha ao executar seeders (não crítico)"
    ok "Dados iniciais inseridos"
}

criar_admin() {
    passo "Criando Usuário Administrador"
    
    cd "$INSTALL_DIR"
    info "Criando conta de administrador '$ADMIN_EMAIL'..."
    
    # Criar admin via Artisan Tinker
    sudo -u www-data php artisan tinker --execute="
        use App\Models\User;
        use Illuminate\Support\Facades\Hash;
        
        \$user = User::updateOrCreate(
            ['email' => '${ADMIN_EMAIL}'],
            [
                'name' => '${ADMIN_NAME}',
                'email' => '${ADMIN_EMAIL}',
                'password' => Hash::make('${ADMIN_PASSWORD}'),
                'role' => 'admin',
                'payment_status' => 'paid',
                'inspection_credits' => 9999,
                'email_verified_at' => now(),
            ]
        );
        echo 'Administrador criado: ' . \$user->email;
    " >> "$LOG_FILE" 2>&1 || erro "Falha ao criar usuário administrador"
    
    ok "Administrador criado: $ADMIN_EMAIL"
}

otimizar_laravel() {
    passo "Otimizando a Aplicação"
    
    cd "$INSTALL_DIR"
    
    info "Limpando caches antigos..."
    sudo -u www-data php artisan config:clear >> "$LOG_FILE" 2>&1
    sudo -u www-data php artisan route:clear >> "$LOG_FILE" 2>&1
    sudo -u www-data php artisan view:clear >> "$LOG_FILE" 2>&1
    
    info "Gerando caches de produção..."
    sudo -u www-data php artisan config:cache >> "$LOG_FILE" 2>&1
    sudo -u www-data php artisan route:cache >> "$LOG_FILE" 2>&1
    sudo -u www-data php artisan view:cache >> "$LOG_FILE" 2>&1
    sudo -u www-data php artisan storage:link >> "$LOG_FILE" 2>&1
    
    ok "Aplicação otimizada"
}

configurar_firewall() {
    passo "Configurando Firewall (UFW)"
    
    if command -v ufw &>/dev/null; then
        info "Configurando regras de firewall..."
        ufw allow OpenSSH >> "$LOG_FILE" 2>&1
        ufw allow 'Nginx Full' >> "$LOG_FILE" 2>&1
        ufw --force enable >> "$LOG_FILE" 2>&1
        ok "Firewall configurado (SSH e HTTP/HTTPS liberados)"
    else
        aviso "UFW não encontrado, pulando configuração do firewall"
    fi
}

configurar_queue_worker() {
    passo "Configurando Fila de Jobs (Queue Worker)"
    
    # Criar serviço systemd para queue worker
    cat > /etc/systemd/system/vistoria-queue.service << SERVICEEOF
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
SERVICEEOF

    executar systemctl daemon-reload
    executar systemctl enable vistoria-queue
    executar systemctl start vistoria-queue
    ok "Queue worker configurado como serviço"
}

configurar_scheduler() {
    passo "Configurando Agendador de Tarefas (Scheduler)"
    
    # Adicionar cron para o scheduler do Laravel
    (crontab -l 2>/dev/null; echo "* * * * * www-data cd ${INSTALL_DIR} && php artisan schedule:run >> /dev/null 2>&1") | crontab -
    ok "Agendador configurado (cron)"
}

# ─── Relatório final ──────────────────────────────────────────────────────────

exibir_relatorio_final() {
    echo ""
    echo -e "${VERDE}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║        ✅  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${NEGRITO}  📋 INFORMAÇÕES DO SISTEMA${RESET}"
    echo ""
    echo -e "  🌐 ${NEGRITO}Endereço:${RESET}          ${VERDE}${APP_URL}${RESET}"
    echo -e "  📁 ${NEGRITO}Diretório:${RESET}         ${INSTALL_DIR}"
    echo ""
    echo -e "  ${NEGRITO}── BANCO DE DADOS ────────────────────────────────────${RESET}"
    echo -e "  🗄️  ${NEGRITO}Banco:${RESET}             $DB_NAME"
    echo -e "  👤 ${NEGRITO}Usuário:${RESET}           $DB_USER"
    echo -e "  🔑 ${NEGRITO}Senha:${RESET}             $DB_PASSWORD"
    echo ""
    echo -e "  ${NEGRITO}── ACESSO ADMINISTRADOR ──────────────────────────────${RESET}"
    echo -e "  📧 ${NEGRITO}E-mail:${RESET}            ${AMARELO}$ADMIN_EMAIL${RESET}"
    echo -e "  🔒 ${NEGRITO}Senha:${RESET}             ${AMARELO}$ADMIN_PASSWORD${RESET}"
    echo ""
    echo -e "  ${NEGRITO}── SERVIÇOS ──────────────────────────────────────────${RESET}"
    echo -e "  ✔  Nginx  (servidor web)"
    echo -e "  ✔  MySQL  (banco de dados)"
    echo -e "  ✔  PHP ${PHP_VERSION}-FPM (processador PHP)"
    echo -e "  ✔  Queue Worker (processamento de filas)"
    echo -e "  ✔  Scheduler (tarefas agendadas)"
    echo ""
    echo -e "  ${NEGRITO}── COMANDOS ÚTEIS ────────────────────────────────────${RESET}"
    echo -e "  # Ver logs da aplicação"
    echo -e "  ${CIANO}tail -f ${INSTALL_DIR}/storage/logs/laravel.log${RESET}"
    echo ""
    echo -e "  # Reiniciar serviços"
    echo -e "  ${CIANO}systemctl restart nginx php${PHP_VERSION}-fpm mysql${RESET}"
    echo ""
    echo -e "  # Ver status do queue worker"
    echo -e "  ${CIANO}systemctl status vistoria-queue${RESET}"
    echo ""
    echo -e "  📄 Log completo da instalação: ${AMARELO}$LOG_FILE${RESET}"
    echo ""
    echo -e "${NEGRITO}  🔗 REPOSITÓRIO GITHUB${RESET}"
    echo -e "  ${CIANO}https://github.com/${GITHUB_REPO}${RESET}"
    echo ""
    echo -e "  Para reinstalar ou atualizar:"
    echo -e "  ${CIANO}curl -fsSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/instalar.sh | sudo bash${RESET}"
    echo ""
    echo -e "${AMARELO}  ⚠️  IMPORTANTE: Guarde as credenciais acima em local seguro!${RESET}"
    echo ""
}

# ─── Ponto de entrada principal ───────────────────────────────────────────────

main() {
    # Inicializar log
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"

    imprimir_cabecalho
    verificar_root
    verificar_sistema_operacional
    verificar_recursos
    coletar_informacoes

    echo ""
    echo -e "${AZUL}  Iniciando instalação...${RESET}"
    echo -e "  ${CIANO}Isso pode levar de 5 a 15 minutos.${RESET}"
    echo -e "  ${CIANO}Acompanhe o progresso abaixo.${RESET}"
    echo ""

    instalar_dependencias_sistema
    instalar_php
    instalar_composer
    instalar_nodejs
    instalar_nginx
    instalar_mysql
    configurar_banco_dados
    clonar_repositorio
    configurar_env
    instalar_dependencias_php
    instalar_dependencias_npm
    configurar_permissoes
    executar_migracoes
    criar_admin
    otimizar_laravel
    configurar_firewall
    configurar_queue_worker
    configurar_scheduler

    exibir_relatorio_final
}

# Executar
main "$@"
