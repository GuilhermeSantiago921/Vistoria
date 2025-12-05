#!/bin/bash

###############################################################################
# Script de Instalação Automática - Sistema de Vistoria
# Para Ubuntu 20.04+ / Debian 11+
# Uso: sudo bash install.sh
###############################################################################

set -e  # Para execução em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   log_error "Este script deve ser executado como root (use sudo)"
   exit 1
fi

# Banner
clear
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║       SISTEMA DE VISTORIA - INSTALADOR AUTOMÁTICO       ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Perguntar configurações
read -p "Digite o domínio (ex: vistoria.com.br): " DOMAIN
read -p "Digite o email do administrador: " ADMIN_EMAIL
read -p "Digite a senha do administrador: " -s ADMIN_PASSWORD
echo
read -p "Instalar MySQL? (S/n - padrão: SQLite): " INSTALL_MYSQL
read -p "Instalar SSL/HTTPS com Certbot? (S/n): " INSTALL_SSL

INSTALL_MYSQL=${INSTALL_MYSQL:-n}
INSTALL_SSL=${INSTALL_SSL:-S}

log_info "Iniciando instalação..."
sleep 2

###############################################################################
# PASSO 1: Atualizar Sistema
###############################################################################
log_info "Passo 1/12: Atualizando sistema..."
apt update && apt upgrade -y
log_success "Sistema atualizado"

###############################################################################
# PASSO 2: Instalar PHP 8.3
###############################################################################
log_info "Passo 2/12: Instalando PHP 8.3..."
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.3 php8.3-cli php8.3-fpm php8.3-common \
    php8.3-mysql php8.3-sqlite3 php8.3-xml php8.3-curl \
    php8.3-mbstring php8.3-zip php8.3-gd php8.3-bcmath \
    php8.3-intl php8.3-opcache

# Configurar PHP para upload de vistorias (10 fotos até 30MB total)
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 5M/g' /etc/php/8.3/fpm/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 35M/g' /etc/php/8.3/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/8.3/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 120/g' /etc/php/8.3/fpm/php.ini
sed -i 's/;max_input_time = 60/max_input_time = 120/g' /etc/php/8.3/fpm/php.ini

log_success "PHP 8.3 instalado e configurado"

###############################################################################
# PASSO 3: Instalar Composer
###############################################################################
log_info "Passo 3/12: Instalando Composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
log_success "Composer instalado: $(composer --version --no-ansi)"

###############################################################################
# PASSO 4: Instalar Node.js e NPM
###############################################################################
log_info "Passo 4/12: Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
log_success "Node.js instalado: $(node --version)"

###############################################################################
# PASSO 5: Instalar Nginx
###############################################################################
log_info "Passo 5/12: Instalando Nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx
log_success "Nginx instalado e ativo"

###############################################################################
# PASSO 6: Instalar Banco de Dados
###############################################################################
if [[ "$INSTALL_MYSQL" =~ ^[Ss]$ ]]; then
    log_info "Passo 6/12: Instalando MySQL..."
    apt install -y mysql-server
    systemctl start mysql
    systemctl enable mysql
    
    # Gerar senha aleatória para MySQL
    MYSQL_ROOT_PASS=$(openssl rand -base64 32)
    
    # Configurar MySQL
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASS}';"
    mysql -u root -p"${MYSQL_ROOT_PASS}" -e "CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -p"${MYSQL_ROOT_PASS}" -e "CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';"
    mysql -u root -p"${MYSQL_ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';"
    mysql -u root -p"${MYSQL_ROOT_PASS}" -e "FLUSH PRIVILEGES;"
    
    echo "${MYSQL_ROOT_PASS}" > /root/.mysql_password
    chmod 600 /root/.mysql_password
    
    DB_CONNECTION="mysql"
    DB_DATABASE="vistoria"
    DB_USERNAME="vistoria_user"
    DB_PASSWORD="${MYSQL_ROOT_PASS}"
    
    log_success "MySQL instalado (senha salva em /root/.mysql_password)"
else
    log_info "Passo 6/12: Instalando SQLite..."
    apt install -y sqlite3
    DB_CONNECTION="sqlite"
    log_success "SQLite instalado"
fi

###############################################################################
# PASSO 7: Instalar Git
###############################################################################
log_info "Passo 7/12: Instalando Git..."
apt install -y git
log_success "Git instalado"

###############################################################################
# PASSO 8: Baixar Código do Sistema
###############################################################################
log_info "Passo 8/12: Baixando código do sistema..."

# Verificar se estamos executando do diretório do projeto
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPT_DIR/artisan" ]; then
    # Script está sendo executado do diretório do projeto
    log_info "Detectado que o script está no diretório do projeto"
    
    if [ "$SCRIPT_DIR" != "/var/www/vistoria" ]; then
        # Copiar arquivos para /var/www/vistoria
        log_info "Copiando arquivos para /var/www/vistoria..."
        
        # Fazer backup se já existir
        if [ -d "/var/www/vistoria" ]; then
            log_warning "Diretório /var/www/vistoria já existe. Fazendo backup..."
            mv /var/www/vistoria /var/www/vistoria_backup_$(date +%Y%m%d_%H%M%S)
        fi
        
        # Criar diretório e copiar
        mkdir -p /var/www/vistoria
        cp -r "$SCRIPT_DIR"/* /var/www/vistoria/
        cp -r "$SCRIPT_DIR"/.[!.]* /var/www/vistoria/ 2>/dev/null || true
        
        log_success "Arquivos copiados para /var/www/vistoria"
    else
        log_info "Já estamos em /var/www/vistoria"
    fi
else
    # Script não está no diretório do projeto, tentar clonar do GitHub
    log_info "Clonando repositório do GitHub..."
    
    cd /var/www
    
    if [ -d "vistoria" ]; then
        log_warning "Diretório /var/www/vistoria já existe. Fazendo backup..."
        mv vistoria vistoria_backup_$(date +%Y%m%d_%H%M%S)
    fi
    
    # Clone do repositório
    git clone https://github.com/GuilhermeSantiago921/Vistoria.git vistoria
    
    if [ ! -d "vistoria" ]; then
        log_error "Falha ao clonar repositório!"
        log_info "Por favor, clone manualmente ou copie os arquivos para /var/www/vistoria"
        exit 1
    fi
    
    log_success "Repositório clonado com sucesso"
fi

cd /var/www/vistoria
log_success "Código do sistema pronto"

###############################################################################
# PASSO 9: Configurar Permissões
###############################################################################
log_info "Passo 9/12: Configurando permissões..."
chown -R www-data:www-data /var/www/vistoria
chmod -R 755 /var/www/vistoria
chmod -R 775 /var/www/vistoria/storage
chmod -R 775 /var/www/vistoria/bootstrap/cache
log_success "Permissões configuradas"

###############################################################################
# PASSO 10: Instalar Dependências
###############################################################################
log_info "Passo 10/12: Instalando dependências..."

# Composer
cd /var/www/vistoria
sudo -u www-data composer install --no-dev --optimize-autoloader

# Node.js
npm install
npm run build

log_success "Dependências instaladas"

###############################################################################
# PASSO 11: Configurar Aplicação
###############################################################################
log_info "Passo 11/12: Configurando aplicação..."

# Criar .env
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Gerar APP_KEY
php artisan key:generate --force

# Configurar .env
APP_KEY=$(grep APP_KEY .env | cut -d '=' -f2)

cat > .env << EOF
APP_NAME="Sistema de Vistoria"
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=https://${DOMAIN}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=${DB_CONNECTION}
EOF

if [[ "$DB_CONNECTION" == "mysql" ]]; then
    cat >> .env << EOF
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
EOF
else
    cat >> .env << EOF
DB_DATABASE=/var/www/vistoria/database/database.sqlite
EOF
    
    # Criar banco SQLite
    touch database/database.sqlite
    chmod 664 database/database.sqlite
    chown www-data:www-data database/database.sqlite
fi

cat >> .env << EOF

SESSION_DRIVER=file
SESSION_LIFETIME=120

QUEUE_CONNECTION=database

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=
MAIL_FROM_NAME="\${APP_NAME}"
EOF

# Executar migrações
php artisan migrate --force

# Criar storage link
php artisan storage:link

# Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

log_success "Aplicação configurada"

###############################################################################
# PASSO 12: Configurar Nginx
###############################################################################
log_info "Passo 12/12: Configurando Nginx..."

cat > /etc/nginx/sites-available/vistoria << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Limite para upload de vistorias (10 fotos até 30MB total + overhead)
    client_max_body_size 35M;
}
EOF

# Ativar site
ln -sf /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Testar e reiniciar Nginx
nginx -t
systemctl restart nginx
systemctl restart php8.3-fpm

log_success "Nginx configurado"

###############################################################################
# CRIAR USUÁRIO ADMINISTRADOR
###############################################################################
log_info "Criando usuário administrador..."

php artisan tinker --execute="
\$user = new App\Models\User();
\$user->name = 'Administrador';
\$user->email = '${ADMIN_EMAIL}';
\$user->password = bcrypt('${ADMIN_PASSWORD}');
\$user->role = 'admin';
\$user->inspection_credits = 999;
\$user->email_verified_at = now();
\$user->save();
echo 'Usuário criado com sucesso';
"

log_success "Administrador criado"

###############################################################################
# INSTALAR SSL (CERTBOT)
###############################################################################
if [[ "$INSTALL_SSL" =~ ^[Ss]$ ]]; then
    log_info "Instalando SSL/HTTPS..."
    apt install -y certbot python3-certbot-nginx
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email ${ADMIN_EMAIL} || log_warning "Certbot falhou. Configure SSL manualmente."
    log_success "SSL instalado"
fi

###############################################################################
# CONFIGURAR FIREWALL
###############################################################################
log_info "Configurando firewall..."
apt install -y ufw
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
log_success "Firewall configurado"

###############################################################################
# INSTALAR SUPERVISOR (PARA FILAS)
###############################################################################
log_info "Instalando Supervisor para filas..."
apt install -y supervisor

cat > /etc/supervisor/conf.d/vistoria-worker.conf << EOF
[program:vistoria-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/vistoria/artisan queue:work database --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/vistoria/storage/logs/worker.log
stopwaitsecs=3600
EOF

supervisorctl reread
supervisorctl update
supervisorctl start vistoria-worker:*

log_success "Supervisor configurado"

###############################################################################
# FINALIZAÇÃO
###############################################################################
clear
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║           INSTALAÇÃO CONCLUÍDA COM SUCESSO! ✅           ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 INFORMAÇÕES DO SISTEMA${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "🌐 URL do Sistema:     ${GREEN}http${INSTALL_SSL:+s}://${DOMAIN}${NC}"
echo -e "👤 Email Admin:        ${GREEN}${ADMIN_EMAIL}${NC}"
echo -e "🔑 Senha Admin:        ${GREEN}${ADMIN_PASSWORD}${NC}"
echo
if [[ "$DB_CONNECTION" == "mysql" ]]; then
    echo -e "💾 Banco de Dados:     ${GREEN}MySQL${NC}"
    echo -e "🔐 Senha MySQL:        ${GREEN}Salva em /root/.mysql_password${NC}"
else
    echo -e "💾 Banco de Dados:     ${GREEN}SQLite${NC}"
fi
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📝 PRÓXIMOS PASSOS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo "1. Acesse: http${INSTALL_SSL:+s}://${DOMAIN}"
echo "2. Faça login com as credenciais acima"
echo "3. Configure o e-mail em: /var/www/vistoria/.env"
echo "4. Teste o envio de uma vistoria"
echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚠️  IMPORTANTE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo "• Anote as credenciais acima em local seguro"
echo "• Configure o DNS do domínio para apontar para este servidor"
echo "• Edite /var/www/vistoria/.env para configurar e-mail"
echo
echo -e "${GREEN}Sistema pronto para uso! 🚀${NC}"
echo
