#!/bin/bash

# =============================================================================
#  VERIFICADOR DE INSTALAÇÃO - SISTEMA DE VISTORIA
#  Valida se tudo está funcionando corretamente
# =============================================================================

set -euo pipefail

# Cores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# Funções
info()    { echo -e "  ${BLUE}ℹ${NC}  $1"; }
success() { echo -e "  ${GREEN}✔${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "  ${RED}✘${NC}  $1"; }
step()    { echo -e "\n${BOLD}${CYAN}═══ $1 ═══${NC}"; }

# Banner
clear
echo -e "${BOLD}${CYAN}"
cat << 'BANNER'
  ╔══════════════════════════════════════════════════════════════╗
  ║          🚗  VERIFICADOR DE INSTALAÇÃO                       ║
  ║              Sistema de Vistoria Veicular                    ║
  ╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

APP_DIR="/var/www/vistoria"
ERRORS=0
WARNINGS=0

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Serviços"
# ─────────────────────────────────────────────────────────────────────────────

# Nginx
if systemctl is-active nginx &>/dev/null; then
    success "Nginx está ativo"
else
    error "Nginx inativo"
    ((ERRORS++))
fi

# PHP-FPM
if systemctl is-active php8.2-fpm &>/dev/null; then
    success "PHP-FPM está ativo"
else
    error "PHP-FPM inativo"
    ((ERRORS++))
fi

# MySQL
if systemctl is-active mysql &>/dev/null; then
    success "MySQL está ativo"
else
    error "MySQL inativo"
    ((ERRORS++))
fi

# Supervisor
if systemctl is-active supervisor &>/dev/null; then
    success "Supervisor está ativo"
else
    warn "Supervisor não está ativo (não crítico)"
    ((WARNINGS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Arquivos"
# ─────────────────────────────────────────────────────────────────────────────

[[ -d "$APP_DIR" ]] && success "Diretório da aplicação existe" || { error "Diretório não encontrado"; ((ERRORS++)); }
[[ -f "$APP_DIR/.env" ]] && success "Arquivo .env existe" || { error ".env não encontrado"; ((ERRORS++)); }
[[ -f "$APP_DIR/artisan" ]] && success "Arquivo artisan existe" || { error "artisan não encontrado"; ((ERRORS++)); }
[[ -d "$APP_DIR/storage/logs" ]] && success "Diretório de logs existe" || { error "Diretório de logs não existe"; ((ERRORS++)); }

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Banco de Dados"
# ─────────────────────────────────────────────────────────────────────────────

if [[ -f /root/.vistoria_mysql_credentials ]]; then
    source /root/.vistoria_mysql_credentials
    if mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1" "$DB_DATABASE" &>/dev/null 2>&1; then
        success "Conexão com banco de dados OK"
        
        # Verificar tabelas
        TABLE_COUNT=$(mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" -e "SHOW TABLES;" 2>/dev/null | wc -l)
        if [[ $TABLE_COUNT -gt 1 ]]; then
            success "Banco de dados tem $(($TABLE_COUNT - 1)) tabelas"
        else
            error "Banco de dados vazio"
            ((ERRORS++))
        fi
    else
        error "Falha ao conectar ao banco de dados"
        ((ERRORS++))
    fi
else
    warn "Arquivo de credenciais do MySQL não encontrado"
    ((WARNINGS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Permissões"
# ─────────────────────────────────────────────────────────────────────────────

if [[ -O "$APP_DIR/storage" ]] || [[ $(stat -f%OL "$APP_DIR/storage" 2>/dev/null || stat -c%U "$APP_DIR/storage") == "www-data" ]] || [[ $(ls -ld "$APP_DIR/storage" | awk '{print $3}') == "www-data" ]]; then
    success "Permissões de storage OK"
else
    warn "Propriedade de storage pode estar incorreta"
    ((WARNINGS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Aplicação Laravel"
# ─────────────────────────────────────────────────────────────────────────────

cd "$APP_DIR"

# Verificar se consegue executar artisan
if php artisan --version &>/dev/null; then
    success "Laravel artisan OK"
else
    error "Não consegue executar artisan"
    ((ERRORS++))
fi

# Verificar cache
if [[ -d "$APP_DIR/bootstrap/cache" ]] && [[ -f "$APP_DIR/bootstrap/cache/config.php" ]]; then
    success "Cache de configuração gerado"
else
    warn "Cache de configuração não encontrado"
    ((WARNINGS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando Nginx"
# ─────────────────────────────────────────────────────────────────────────────

if [[ -f /etc/nginx/sites-enabled/vistoria ]]; then
    success "Virtual host Vistoria configurado"
else
    error "Virtual host não encontrado"
    ((ERRORS++))
fi

# Testar configuração
if nginx -t &>/dev/null; then
    success "Configuração do Nginx válida"
else
    error "Erro na configuração do Nginx"
    ((ERRORS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Verificando SSL"
# ─────────────────────────────────────────────────────────────────────────────

if grep -q "https://" "$APP_DIR/.env"; then
    success "SSL/HTTPS está ativado no .env"
    
    # Verificar certificado
    DOMAIN=$(grep "APP_URL" "$APP_DIR/.env" | cut -d'=' -f2 | sed 's|https\?://||' | sed 's|/.*||')
    if [[ -f "/etc/letsencrypt/live/${DOMAIN}/cert.pem" ]]; then
        EXPIRY=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/${DOMAIN}/cert.pem" 2>/dev/null || echo "não encontrado")
        success "Certificado SSL: $EXPIRY"
    else
        warn "Certificado Let's Encrypt não encontrado (pode estar usando HTTP)"
    fi
else
    info "SSL não está configurado (usando HTTP)"
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Teste de Requisição HTTP"
# ─────────────────────────────────────────────────────────────────────────────

APP_URL=$(grep "APP_URL=" "$APP_DIR/.env" | cut -d'=' -f2)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL" 2>/dev/null || echo "0")

if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "302" ]]; then
    success "Sistema respondendo com HTTP $HTTP_CODE"
else
    warn "Sistema respondeu com HTTP $HTTP_CODE (esperado 200 ou 302)"
    ((WARNINGS++))
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Resumo"
# ─────────────────────────────────────────────────────────────────────────────

echo
echo -e "  ${BOLD}Erros encontrados: ${RED}${ERRORS}${NC}"
echo -e "  ${BOLD}Avisos: ${YELLOW}${WARNINGS}${NC}"
echo

if [[ $ERRORS -eq 0 ]]; then
    echo -e "  ${GREEN}✓ Verificação concluída com sucesso!${NC}"
    echo -e "  ${GREEN}Sistema pronto para uso.${NC}"
    exit 0
else
    echo -e "  ${RED}✘ Há erros que precisam ser corrigidos.${NC}"
    echo -e "  ${RED}Verifique os logs: tail -f ${APP_DIR}/storage/logs/laravel.log${NC}"
    exit 1
fi
