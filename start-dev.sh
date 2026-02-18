#!/bin/bash

################################################################################
# Script de Desenvolvimento - Sistema de Vistoria
# Para macOS
# Inicia servidor PHP otimizado para upload de arquivos
################################################################################

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   SISTEMA DE VISTORIA - SERVIDOR DE DESENVOLVIMENTO   ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Verificar se está no diretório correto
if [[ ! -f "artisan" ]]; then
    echo -e "${YELLOW}⚠  Execute este script no diretório raiz do projeto${NC}"
    exit 1
fi

# Verificar se a porta 8000 está em uso
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}⚠  Porta 8000 já está em uso${NC}"
    echo -e "${YELLOW}   Deseja encerrar o processo? (s/n)${NC}"
    read -r response
    if [[ "$response" =~ ^([sS])$ ]]; then
        lsof -ti:8000 | xargs kill -9
        echo -e "${GREEN}✓ Processo encerrado${NC}"
    else
        exit 1
    fi
fi

# Limpar cache
echo -e "${BLUE}➜ Limpando cache...${NC}"
php artisan cache:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1
php artisan view:clear > /dev/null 2>&1

# Verificar storage
if [[ ! -d "storage/logs" ]]; then
    mkdir -p storage/logs
fi

if [[ ! -L "public/storage" ]]; then
    echo -e "${BLUE}➜ Criando link simbólico para storage...${NC}"
    php artisan storage:link
fi

# Definir permissões
chmod -R 775 storage bootstrap/cache

echo -e "${GREEN}✓ Configurações preparadas${NC}\n"

# Informações
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Servidor iniciando em: http://localhost:8000${NC}"
echo -e "${GREEN}✓ Upload configurado para: 50MB por foto${NC}"
echo -e "${GREEN}✓ Tempo máximo de execução: 300 segundos${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}💡 Dica: Use Ctrl+C para parar o servidor${NC}\n"

# Iniciar servidor com configurações otimizadas
php -d upload_max_filesize=50M \
    -d post_max_size=50M \
    -d memory_limit=256M \
    -d max_execution_time=300 \
    -d max_input_time=300 \
    -d ignore_user_abort=On \
    -d output_buffering=4096 \
    -d default_socket_timeout=300 \
    -S localhost:8000 \
    -t public \
    public/index.php
