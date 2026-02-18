#!/bin/bash

###############################################################################
# Script de Limpeza - Sistema de Vistoria
# Remove todos os arquivos desnecessários, de debug e temporários
# Uso: bash cleanup.sh
###############################################################################

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}   Limpeza de Arquivos Desnecessários${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo

# Confirmar
read -p "Deseja remover TODOS os arquivos de debug/teste? (S/n): " CONFIRM
[[ "$CONFIRM" =~ ^[Nn]$ ]] && { log_warning "Limpeza cancelada"; exit 0; }

REMOVED=0

###############################################################################
# RAIZ DO PROJETO
###############################################################################
log_info "Limpando raiz do projeto..."

FILES=(
    "sqlite-setup.php"
    "clear-cache.php"
    "create-admin-cli.php"
    "safe-mode.php"
    "debug-complete.php"
    "test-final.php"
    "test-bootstrap.php"
    "simple-login.php"
    "test-new-user.php"
    "test-hosts.php"
    "test.php"
    "auto-create-admin.php"
    "debug.php"
    "test-ip.php"
    "test-complete.php"
    "debug-errors.php"
    "logout.php"
    "cpanel-test.php"
    "generate-key.php"
    "index.php"
    "check.php"
    "debug-welcome.php"
    "debug-system.php"
    "dashboard-admin.php"
    "index.php.final"
    "index.php.fixed"
    "index.php.hostgator"
    "index.php.manual"
    "index.php.safe"
    "index.php.smart"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_success "Removido: $file"
        ((REMOVED++))
    fi
done

###############################################################################
# PUBLIC/
###############################################################################
log_info "Limpando public/..."

PUBLIC_FILES=(
    "public/get-server-ip.php"
    "public/create-admin.php"
    "public/test-agregados.php"
    "public/debug-system.php"
    "public/fix-vehicles-table.php"
    "public/clear-cache-agregados.php"
    "public/test-upload.php"
    "public/debug-session.php"
    "public/fix-database.php"
    "public/fix-database-complete.php"
    "public/fix-storage-link.php"
    "public/auto-create-admin.php"
)

for file in "${PUBLIC_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_success "Removido: $file"
        ((REMOVED++))
    fi
done

###############################################################################
# SCRIPTS/
###############################################################################
log_info "Limpando scripts/..."

if [ -f "scripts/update_vehicle_2.php" ]; then
    rm -f "scripts/update_vehicle_2.php"
    log_success "Removido: scripts/update_vehicle_2.php"
    ((REMOVED++))
fi

###############################################################################
# ARQUIVOS MARKDOWN DE DEBUG
###############################################################################
log_info "Limpando documentação temporária..."

MD_FILES=(
    "CORRECAO_ERRO_500.md"
    "FIX_ENV_SESSION.txt"
    "FIXES_CSP_ALPINE.md"
    "MELHORIAS_CONTRASTE_MOBILE.md"
    "MELHORIAS_CONTRASTE.md"
    "MENU_MOBILE_FONTE_PRETA.md"
    "MOBILE_UX_COMPLETE_GUIDE.md"
    "SOLUCAO_RAPIDA.md"
)

for file in "${MD_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_success "Removido: $file"
        ((REMOVED++))
    fi
done

###############################################################################
# BACKUPS DO BOOTSTRAP
###############################################################################
log_info "Limpando backups..."

BACKUP_FILES=(
    "bootstrap/app.php.WITH_SECURITY"
)

for file in "${BACKUP_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_success "Removido: $file"
        ((REMOVED++))
    fi
done

###############################################################################
# ARQUIVOS DE TEXTO/LOGS TEMPORÁRIOS
###############################################################################
log_info "Limpando arquivos temporários..."

TEMP_FILES=(
    "upload-list.txt"
    "php-server.log"
)

for file in "${TEMP_FILES[@]}"; do
    if [ -f "$file" ]; then
        rm -f "$file"
        log_success "Removido: $file"
        ((REMOVED++))
    fi
done

###############################################################################
# INSPECTION_1.PDF (arquivo de teste)
###############################################################################
if [ -f "inspection_1.pdf" ]; then
    rm -f "inspection_1.pdf"
    log_success "Removido: inspection_1.pdf"
    ((REMOVED++))
fi

###############################################################################
# LIMPAR CACHES
###############################################################################
log_info "Limpando caches..."

if [ -d "bootstrap/cache" ]; then
    find bootstrap/cache -type f -name "*.php" ! -name ".gitignore" -delete 2>/dev/null
    log_success "Cache do bootstrap limpo"
fi

if [ -d "storage/framework/cache" ]; then
    find storage/framework/cache -type f ! -name ".gitignore" -delete 2>/dev/null
    log_success "Cache do framework limpo"
fi

if [ -d "storage/framework/sessions" ]; then
    find storage/framework/sessions -type f ! -name ".gitignore" -delete 2>/dev/null
    log_success "Sessões limpas"
fi

if [ -d "storage/framework/views" ]; then
    find storage/framework/views -type f ! -name ".gitignore" -delete 2>/dev/null
    log_success "Views compiladas limpas"
fi

###############################################################################
# LIMPAR LOGS ANTIGOS
###############################################################################
log_info "Limpando logs antigos..."

if [ -d "storage/logs" ]; then
    find storage/logs -name "*.log" -mtime +30 -delete 2>/dev/null
    log_success "Logs com mais de 30 dias removidos"
fi

###############################################################################
# REMOVER NODE_MODULES E VENDOR EM PRODUÇÃO (OPCIONAL)
###############################################################################
read -p "Remover node_modules? (S/n - economiza espaço): " REMOVE_NODE
if [[ "$REMOVE_NODE" =~ ^[Ss]$ ]]; then
    if [ -d "node_modules" ]; then
        log_warning "Removendo node_modules (pode demorar)..."
        rm -rf node_modules
        log_success "node_modules removido"
        ((REMOVED++))
    fi
fi

###############################################################################
# LIMPAR GIT (OPCIONAL)
###############################################################################
if [ -d ".git" ]; then
    read -p "Executar git garbage collection? (S/n): " GIT_GC
    if [[ "$GIT_GC" =~ ^[Ss]$ ]]; then
        git gc --aggressive --prune=now 2>/dev/null
        log_success "Git garbage collection executado"
    fi
fi

###############################################################################
# RESUMO
###############################################################################
echo
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}   Limpeza Concluída! ✅${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo
echo -e "📊 Total de arquivos removidos: ${GREEN}${REMOVED}${NC}"
echo
echo -e "${YELLOW}Arquivos mantidos (importantes):${NC}"
echo -e "  ✅ install.sh - Script de instalação"
echo -e "  ✅ deploy.sh - Script de deploy"
echo -e "  ✅ INSTALL_LINUX.md - Guia de instalação"
echo -e "  ✅ README_COMPLETO.md - Documentação"
echo -e "  ✅ DEPLOY_HOSTGATOR.md - Deploy HostGator"
echo -e "  ✅ CREATE_ADMIN_GUIDE.md - Criar admin"
echo -e "  ✅ ALTERACAO_ANALISTA_MESARIO.md - Mudanças"
echo -e "  ✅ SOLUCAO_ERRO_AGREGADOS.md - Fix agregados"
echo -e "  ✅ SOLUCAO_IMAGENS_404.md - Fix imagens"
echo
echo -e "${BLUE}Próximos passos:${NC}"
echo -e "  1. Testar o sistema: php artisan serve"
echo -e "  2. Verificar logs: tail -f storage/logs/laravel.log"
echo -e "  3. Fazer commit: git add . && git commit -m 'Limpeza de arquivos'"
echo

log_success "Sistema limpo e pronto para produção! 🚀"
