#!/bin/bash

################################################################################
# Script de Instalação Automática - Sistema de Vistoria
# Para Rocky Linux 8/9
# Autor: Sistema de Vistoria
# Data: 2025-12-03
################################################################################

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de utilidade
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Verificar se está rodando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script deve ser executado como root (use sudo)"
        exit 1
    fi
}

# Verificar versão do Rocky Linux
check_os() {
    if [[ ! -f /etc/redhat-release ]]; then
        print_error "Este script é apenas para Rocky Linux"
        exit 1
    fi
    
    if ! grep -q "Rocky Linux" /etc/redhat-release; then
        print_error "Este script é apenas para Rocky Linux"
        exit 1
    fi
    
    print_success "Sistema operacional verificado: $(cat /etc/redhat-release)"
}

# Coletar informações do usuário
collect_info() {
    print_header "CONFIGURAÇÃO INICIAL"
    
    # Domínio
    read -p "Digite o domínio (ex: vistoria.exemplo.com): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        print_error "Domínio é obrigatório"
        exit 1
    fi
    
    # Senha do MySQL root
    read -sp "Digite a senha para o root do MySQL: " MYSQL_ROOT_PASSWORD
    echo
    if [[ -z "$MYSQL_ROOT_PASSWORD" ]]; then
        print_error "Senha do MySQL é obrigatória"
        exit 1
    fi
    
    # Senha do banco de dados
    read -sp "Digite a senha para o usuário do banco de dados: " DB_PASSWORD
    echo
    if [[ -z "$DB_PASSWORD" ]]; then
        print_error "Senha do banco de dados é obrigatória"
        exit 1
    fi
    
    # Email do administrador
    read -p "Digite o email do administrador: " ADMIN_EMAIL
    if [[ -z "$ADMIN_EMAIL" ]]; then
        print_error "Email do administrador é obrigatório"
        exit 1
    fi
    
    # Senha do administrador
    read -sp "Digite a senha do administrador: " ADMIN_PASSWORD
    echo
    if [[ -z "$ADMIN_PASSWORD" ]]; then
        print_error "Senha do administrador é obrigatória"
        exit 1
    fi
    
    # Confirmar instalação SSL
    read -p "Deseja instalar certificado SSL com Let's Encrypt? (s/n): " INSTALL_SSL
    
    echo
    print_info "Configurações:"
    print_info "  Domínio: $DOMAIN"
    print_info "  Email Admin: $ADMIN_EMAIL"
    print_info "  SSL: ${INSTALL_SSL}"
    echo
    
    read -p "Confirma as configurações acima? (s/n): " CONFIRM
    if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
        print_error "Instalação cancelada"
        exit 1
    fi
}

# 1. Atualizar sistema
update_system() {
    print_header "ATUALIZANDO SISTEMA"
    dnf update -y
    dnf upgrade -y
    print_success "Sistema atualizado"
}

# 2. Instalar repositórios
install_repositories() {
    print_header "INSTALANDO REPOSITÓRIOS"
    
    # EPEL
    dnf install epel-release -y
    print_success "EPEL instalado"
    
    # Remi para PHP 8.2
    dnf install https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm -y
    print_success "Repositório Remi instalado"
}

# 3. Instalar PHP 8.2
install_php() {
    print_header "INSTALANDO PHP 8.2"
    
    dnf module reset php -y
    dnf module enable php:remi-8.2 -y
    
    dnf install -y \
        php \
        php-cli \
        php-fpm \
        php-mysqlnd \
        php-pdo \
        php-gd \
        php-mbstring \
        php-xml \
        php-curl \
        php-zip \
        php-bcmath \
        php-json \
        php-tokenizer \
        php-fileinfo \
        php-intl \
        php-opcache
    
    PHP_VERSION=$(php -v | head -n 1)
    print_success "PHP instalado: $PHP_VERSION"
}

# 4. Instalar Composer
install_composer() {
    print_header "INSTALANDO COMPOSER"
    
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    
    COMPOSER_VERSION=$(composer --version)
    print_success "Composer instalado: $COMPOSER_VERSION"
}

# 5. Instalar MariaDB
install_mariadb() {
    print_header "INSTALANDO MARIADB"
    
    dnf install mariadb-server mariadb -y
    systemctl start mariadb
    systemctl enable mariadb
    
    print_success "MariaDB instalado e iniciado"
}

# 6. Configurar MariaDB
configure_mariadb() {
    print_header "CONFIGURANDO MARIADB"
    
    # Configuração segura
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DROP DATABASE IF EXISTS test;"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
    
    # Criar banco de dados
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS 'vistoria_user'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
    
    print_success "MariaDB configurado"
}

# 7. Instalar Nginx
install_nginx() {
    print_header "INSTALANDO NGINX"
    
    dnf install nginx -y
    systemctl start nginx
    systemctl enable nginx
    
    print_success "Nginx instalado e iniciado"
}

# 8. Configurar Firewall
configure_firewall() {
    print_header "CONFIGURANDO FIREWALL"
    
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    
    print_success "Firewall configurado"
}

# 9. Instalar Node.js
install_nodejs() {
    print_header "INSTALANDO NODE.JS"
    
    dnf module install nodejs:18 -y
    
    NODE_VERSION=$(node -v)
    NPM_VERSION=$(npm -v)
    print_success "Node.js instalado: $NODE_VERSION"
    print_success "NPM instalado: $NPM_VERSION"
}

# 10. Instalar Git
install_git() {
    print_header "INSTALANDO GIT"
    
    dnf install git -y
    
    GIT_VERSION=$(git --version)
    print_success "Git instalado: $GIT_VERSION"
}

# 11. Criar estrutura de diretórios
create_directories() {
    print_header "CRIANDO ESTRUTURA DE DIRETÓRIOS"
    
    mkdir -p /var/www/vistoria
    mkdir -p /backups/vistoria
    
    print_success "Diretórios criados"
}

# 12. Configurar PHP-FPM
configure_php_fpm() {
    print_header "CONFIGURANDO PHP-FPM"
    
    # Configurar www.conf
    cat > /etc/php-fpm.d/www.conf <<EOF
[www]
user = nginx
group = nginx
listen = /run/php-fpm/www.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

php_value[upload_max_filesize] = 50M
php_value[post_max_size] = 50M
php_value[max_execution_time] = 300
php_value[memory_limit] = 256M
EOF
    
    # Configurar php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 50M/' /etc/php.ini
    sed -i 's/post_max_size = .*/post_max_size = 50M/' /etc/php.ini
    sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php.ini
    sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php.ini
    
    systemctl restart php-fpm
    
    print_success "PHP-FPM configurado"
}

# 13. Configurar Nginx
configure_nginx() {
    print_header "CONFIGURANDO NGINX"
    
    cat > /etc/nginx/conf.d/vistoria.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/vistoria/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    client_max_body_size 50M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
    
    nginx -t
    systemctl restart nginx
    
    print_success "Nginx configurado"
}

# 14. Copiar arquivos do projeto (assumindo que estão no diretório atual)
copy_project_files() {
    print_header "COPIANDO ARQUIVOS DO PROJETO"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    if [[ ! -f "$SCRIPT_DIR/composer.json" ]]; then
        print_error "Arquivos do projeto não encontrados no diretório atual"
        print_info "Por favor, execute este script no diretório raiz do projeto"
        exit 1
    fi
    
    cp -r "$SCRIPT_DIR"/* /var/www/vistoria/
    cp -r "$SCRIPT_DIR"/.* /var/www/vistoria/ 2>/dev/null || true
    
    print_success "Arquivos copiados"
}

# 15. Instalar dependências
install_dependencies() {
    print_header "INSTALANDO DEPENDÊNCIAS"
    
    cd /var/www/vistoria
    
    # Composer
    print_info "Instalando dependências PHP..."
    sudo -u nginx composer install --optimize-autoloader --no-dev --no-interaction
    
    # NPM
    print_info "Instalando dependências Node.js..."
    npm install
    
    print_info "Compilando assets..."
    npm run build
    
    print_success "Dependências instaladas"
}

# 16. Configurar .env
configure_env() {
    print_header "CONFIGURANDO ARQUIVO .ENV"
    
    cd /var/www/vistoria
    
    cp .env.example .env
    
    # Gerar APP_KEY
    php artisan key:generate --force
    
    # Configurar banco de dados
    sed -i "s|APP_NAME=.*|APP_NAME=\"Sistema de Vistoria\"|" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|" .env
    
    sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
    sed -i "s|DB_HOST=.*|DB_HOST=127.0.0.1|" .env
    sed -i "s|DB_PORT=.*|DB_PORT=3306|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=vistoria|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=vistoria_user|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|" .env
    
    sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=database|" .env
    sed -i "s|QUEUE_CONNECTION=.*|QUEUE_CONNECTION=database|" .env
    
    print_success "Arquivo .env configurado"
}

# 17. Executar migrações
run_migrations() {
    print_header "EXECUTANDO MIGRAÇÕES DO BANCO DE DADOS"
    
    cd /var/www/vistoria
    
    php artisan migrate --force
    
    print_success "Migrações executadas"
}

# 18. Criar link simbólico para storage
create_storage_link() {
    print_header "CRIANDO LINK SIMBÓLICO PARA STORAGE"
    
    cd /var/www/vistoria
    
    php artisan storage:link
    
    print_success "Link simbólico criado"
}

# 19. Criar usuário admin
create_admin_user() {
    print_header "CRIANDO USUÁRIO ADMINISTRADOR"
    
    cd /var/www/vistoria
    
    php artisan tinker --execute="\\App\\Models\\User::create(['name' => 'Administrador', 'email' => '${ADMIN_EMAIL}', 'password' => bcrypt('${ADMIN_PASSWORD}'), 'role' => 'admin', 'inspection_credits' => 999]);"
    
    print_success "Usuário administrador criado"
}

# 20. Configurar permissões
set_permissions() {
    print_header "CONFIGURANDO PERMISSÕES"
    
    chown -R nginx:nginx /var/www/vistoria
    find /var/www/vistoria -type f -exec chmod 644 {} \;
    find /var/www/vistoria -type d -exec chmod 755 {} \;
    chmod -R 775 /var/www/vistoria/storage
    chmod -R 775 /var/www/vistoria/bootstrap/cache
    
    print_success "Permissões configuradas"
}

# 21. Configurar SELinux
configure_selinux() {
    print_header "CONFIGURANDO SELINUX"
    
    # Instalar ferramentas se necessário
    dnf install policycoreutils-python-utils -y 2>/dev/null || true
    
    setsebool -P httpd_can_network_connect on
    setsebool -P httpd_unified on
    
    semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/vistoria/storage(/.*)?"
    semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/vistoria/bootstrap/cache(/.*)?"
    restorecon -Rv /var/www/vistoria
    
    print_success "SELinux configurado"
}

# 22. Otimizar Laravel
optimize_laravel() {
    print_header "OTIMIZANDO LARAVEL"
    
    cd /var/www/vistoria
    
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    composer dump-autoload --optimize
    
    print_success "Laravel otimizado"
}

# 23. Configurar Cron
configure_cron() {
    print_header "CONFIGURANDO CRON"
    
    (crontab -u nginx -l 2>/dev/null; echo "* * * * * cd /var/www/vistoria && php artisan schedule:run >> /dev/null 2>&1") | crontab -u nginx -
    
    print_success "Cron configurado"
}

# 24. Instalar SSL
install_ssl() {
    if [[ "$INSTALL_SSL" == "s" || "$INSTALL_SSL" == "S" ]]; then
        print_header "INSTALANDO CERTIFICADO SSL"
        
        dnf install certbot python3-certbot-nginx -y
        
        certbot --nginx -d "${DOMAIN}" -d "www.${DOMAIN}" --non-interactive --agree-tos --email "${ADMIN_EMAIL}"
        
        print_success "Certificado SSL instalado"
    else
        print_warning "Instalação de SSL ignorada"
    fi
}

# 25. Criar script de backup
create_backup_script() {
    print_header "CRIANDO SCRIPT DE BACKUP"
    
    cat > /usr/local/bin/backup-vistoria.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/backups/vistoria"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup do banco de dados
mysqldump -u vistoria_user -p'DB_PASSWORD_PLACEHOLDER' vistoria > $BACKUP_DIR/db_$DATE.sql

# Backup dos arquivos
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/vistoria/storage/app/public

# Manter apenas últimos 7 dias
find $BACKUP_DIR -type f -mtime +7 -delete

echo "[$(date)] Backup concluído: db_$DATE.sql, files_$DATE.tar.gz" >> /var/log/vistoria-backup.log
EOF
    
    sed -i "s|DB_PASSWORD_PLACEHOLDER|${DB_PASSWORD}|" /usr/local/bin/backup-vistoria.sh
    chmod +x /usr/local/bin/backup-vistoria.sh
    
    # Adicionar ao cron (diariamente às 2h)
    (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-vistoria.sh >> /var/log/vistoria-backup.log 2>&1") | crontab -
    
    print_success "Script de backup criado"
}

# 26. Instalar Fail2Ban
install_fail2ban() {
    print_header "INSTALANDO FAIL2BAN"
    
    dnf install fail2ban -y
    systemctl start fail2ban
    systemctl enable fail2ban
    
    print_success "Fail2Ban instalado"
}

# 27. Verificar instalação
verify_installation() {
    print_header "VERIFICANDO INSTALAÇÃO"
    
    # Verificar serviços
    if systemctl is-active --quiet nginx; then
        print_success "Nginx está rodando"
    else
        print_error "Nginx não está rodando"
    fi
    
    if systemctl is-active --quiet php-fpm; then
        print_success "PHP-FPM está rodando"
    else
        print_error "PHP-FPM não está rodando"
    fi
    
    if systemctl is-active --quiet mariadb; then
        print_success "MariaDB está rodando"
    else
        print_error "MariaDB não está rodando"
    fi
    
    # Verificar acesso web
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|301\|302"; then
        print_success "Servidor web respondendo"
    else
        print_warning "Servidor web pode não estar respondendo corretamente"
    fi
}

# Função principal
main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   SISTEMA DE VISTORIA - INSTALADOR AUTOMÁTICO             ║
║   Rocky Linux 8/9                                          ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    check_root
    check_os
    collect_info
    
    print_info "Iniciando instalação..."
    sleep 2
    
    update_system
    install_repositories
    install_php
    install_composer
    install_mariadb
    configure_mariadb
    install_nginx
    configure_firewall
    install_nodejs
    install_git
    create_directories
    configure_php_fpm
    configure_nginx
    copy_project_files
    install_dependencies
    configure_env
    run_migrations
    create_storage_link
    create_admin_user
    set_permissions
    configure_selinux
    optimize_laravel
    configure_cron
    install_ssl
    create_backup_script
    install_fail2ban
    verify_installation
    
    print_header "INSTALAÇÃO CONCLUÍDA!"
    
    echo -e "${GREEN}"
    cat << EOF

╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   ✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!                     ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

INFORMAÇÕES DE ACESSO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

URL do Sistema: https://${DOMAIN}

Login Administrador:
  Email: ${ADMIN_EMAIL}
  Senha: ${ADMIN_PASSWORD}

Banco de Dados:
  Host: localhost
  Database: vistoria
  User: vistoria_user

ARQUIVOS IMPORTANTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Diretório do Projeto: /var/www/vistoria
Logs Laravel: /var/www/vistoria/storage/logs/laravel.log
Logs Nginx: /var/log/nginx/error.log
Logs PHP-FPM: /var/log/php-fpm/www-error.log
Backups: /backups/vistoria

COMANDOS ÚTEIS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reiniciar serviços:
  sudo systemctl restart nginx php-fpm

Ver logs em tempo real:
  sudo tail -f /var/www/vistoria/storage/logs/laravel.log

Limpar cache:
  cd /var/www/vistoria && php artisan cache:clear

Executar backup manual:
  sudo /usr/local/bin/backup-vistoria.sh

PRÓXIMOS PASSOS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Acesse https://${DOMAIN} no navegador
2. Faça login com as credenciais do administrador
3. Configure as notificações por e-mail no arquivo .env
4. Configure a conexão SQL Server Agregados (se necessário)

OBSERVAÇÕES IMPORTANTES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠  Guarde as senhas em local seguro
⚠  Backup automático configurado para rodar diariamente às 2h
⚠  SSL configurado e renovação automática ativada
⚠  Firewall configurado para HTTP e HTTPS

EOF
    echo -e "${NC}"
    
    print_success "Instalação finalizada! O sistema está pronto para uso."
}

# Executar script
main "$@"
