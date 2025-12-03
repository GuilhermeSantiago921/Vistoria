#!/bin/bash

###############################################################################
# Script de Deploy/Atualização - Sistema de Vistoria
# Uso: sudo bash deploy.sh
###############################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# Verificar root
[[ $EUID -ne 0 ]] && log_error "Execute como root: sudo bash deploy.sh"

# Banner
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}   Sistema de Vistoria - Deploy${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo

# Confirmar
read -p "Deseja iniciar o deploy? (S/n): " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && { log_warning "Deploy cancelado"; exit 0; }

START_TIME=$(date +%s)

###############################################################################
# Modo Manutenção
###############################################################################
log_info "Ativando modo manutenção..."
cd /var/www/vistoria
php artisan down --message="Sistema em atualização. Voltamos em instantes." --retry=60
log_success "Modo manutenção ativado"

###############################################################################
# Backup
###############################################################################
log_info "Criando backup..."
BACKUP_DIR="/var/backups/vistoria"
BACKUP_FILE="${BACKUP_DIR}/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p ${BACKUP_DIR}

tar -czf ${BACKUP_FILE} \
    --exclude='node_modules' \
    --exclude='vendor' \
    --exclude='storage/logs/*' \
    -C /var/www vistoria

log_success "Backup criado: ${BACKUP_FILE}"

###############################################################################
# Atualizar Código
###############################################################################
log_info "Atualizando código do repositório..."
cd /var/www/vistoria

# Se usar Git
if [ -d ".git" ]; then
    git fetch origin
    git pull origin main
    log_success "Código atualizado via Git"
else
    log_warning "Não é um repositório Git. Pulando..."
fi

###############################################################################
# Instalar Dependências
###############################################################################
log_info "Atualizando dependências PHP..."
sudo -u www-data composer install --no-dev --optimize-autoloader --no-interaction
log_success "Dependências PHP atualizadas"

log_info "Atualizando dependências Node.js..."
npm install
npm run build
log_success "Assets compilados"

###############################################################################
# Executar Migrações
###############################################################################
log_info "Executando migrações do banco de dados..."
php artisan migrate --force
log_success "Migrações executadas"

###############################################################################
# Limpar Caches
###############################################################################
log_info "Limpando caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
log_success "Caches limpos"

###############################################################################
# Recriar Caches
###############################################################################
log_info "Recriando caches otimizados..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
log_success "Caches recriados"

###############################################################################
# Otimizar Autoload
###############################################################################
log_info "Otimizando autoload..."
composer dump-autoload --optimize --no-dev
log_success "Autoload otimizado"

###############################################################################
# Atualizar Storage Link
###############################################################################
log_info "Verificando storage link..."
if [ ! -L "public/storage" ]; then
    php artisan storage:link
    log_success "Storage link criado"
else
    log_success "Storage link já existe"
fi

###############################################################################
# Permissões
###############################################################################
log_info "Corrigindo permissões..."
chown -R www-data:www-data /var/www/vistoria
chmod -R 755 /var/www/vistoria
chmod -R 775 /var/www/vistoria/storage
chmod -R 775 /var/www/vistoria/bootstrap/cache
log_success "Permissões corrigidas"

###############################################################################
# Reiniciar Serviços
###############################################################################
log_info "Reiniciando serviços..."

# PHP-FPM
systemctl restart php8.3-fpm
log_success "PHP-FPM reiniciado"

# Nginx
systemctl reload nginx
log_success "Nginx recarregado"

# Supervisor (workers)
if systemctl is-active --quiet supervisor; then
    supervisorctl restart vistoria-worker:*
    log_success "Workers reiniciados"
fi

###############################################################################
# Desativar Modo Manutenção
###############################################################################
log_info "Desativando modo manutenção..."
php artisan up
log_success "Site online novamente"

###############################################################################
# Verificações Pós-Deploy
###############################################################################
log_info "Executando verificações..."

# Verificar se o site responde
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" == "200" ]; then
    log_success "Site respondendo (HTTP $HTTP_CODE)"
else
    log_warning "Site respondeu com HTTP $HTTP_CODE"
fi

# Verificar logs de erro recentes
if [ -f "storage/logs/laravel.log" ]; then
    ERROR_COUNT=$(tail -100 storage/logs/laravel.log | grep -i "error" | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        log_warning "Encontrados $ERROR_COUNT erros nos últimos logs"
    else
        log_success "Sem erros nos últimos logs"
    fi
fi

###############################################################################
# Estatísticas
###############################################################################
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}   Deploy Concluído com Sucesso! ✅${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo
echo -e "⏱️  Tempo total: ${DURATION}s"
echo -e "📦 Backup salvo em: ${BACKUP_FILE}"
echo -e "📊 Logs em: /var/www/vistoria/storage/logs/"
echo
echo -e "${YELLOW}Comandos úteis:${NC}"
echo -e "  • Ver logs:        tail -f /var/www/vistoria/storage/logs/laravel.log"
echo -e "  • Ver fila:        php artisan queue:work"
echo -e "  • Limpar cache:    php artisan optimize:clear"
echo -e "  • Reverter backup: tar -xzf ${BACKUP_FILE} -C /var/www"
echo

log_success "Deploy finalizado!"
