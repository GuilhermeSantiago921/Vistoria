#!/bin/bash

################################################################################
# INSTALAÇÃO AUTOMÁTICA - DRIVERS SQL SERVER PARA PHP 8.2
# Sistema de Vistoria Veicular
# Para Ubuntu/Debian
################################################################################

set -e  # Parar em caso de erro

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                            ║"
echo "║        INSTALAÇÃO DRIVERS SQL SERVER PARA PHP 8.2                          ║"
echo "║                                                                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗ Este script precisa ser executado como root (sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1. DETECTANDO SISTEMA OPERACIONAL${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
    echo "Sistema: $PRETTY_NAME"
    echo "Versão: $VER"
else
    echo -e "${RED}✗ Não foi possível detectar o sistema operacional${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2. INSTALANDO DEPENDÊNCIAS BÁSICAS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

apt-get update
apt-get install -y curl apt-transport-https gnupg2 lsb-release software-properties-common

echo -e "${GREEN}✓ Dependências instaladas${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}3. ADICIONANDO REPOSITÓRIO MICROSOFT${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Adicionar chave GPG da Microsoft
if [ ! -f /usr/share/keyrings/microsoft-prod.gpg ]; then
    echo "→ Baixando chave GPG da Microsoft..."
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
    echo -e "${GREEN}✓ Chave GPG adicionada${NC}"
else
    echo -e "${YELLOW}⚠ Chave GPG já existe, pulando...${NC}"
fi

# Adicionar repositório baseado na versão do Ubuntu
if [ "$OS" = "ubuntu" ]; then
    case $VER in
        "22.04")
            REPO_VER="22.04"
            ;;
        "20.04")
            REPO_VER="20.04"
            ;;
        "24.04")
            REPO_VER="22.04"  # Usar 22.04 como fallback
            ;;
        *)
            echo -e "${YELLOW}⚠ Versão não reconhecida, usando 22.04 como padrão${NC}"
            REPO_VER="22.04"
            ;;
    esac
    
    echo "→ Adicionando repositório para Ubuntu $REPO_VER..."
    
    if [ ! -f /etc/apt/sources.list.d/mssql-release.list ]; then
        curl -fsSL https://packages.microsoft.com/config/ubuntu/$REPO_VER/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
        echo -e "${GREEN}✓ Repositório adicionado${NC}"
    else
        echo -e "${YELLOW}⚠ Repositório já existe, pulando...${NC}"
    fi
    
elif [ "$OS" = "debian" ]; then
    case $VER in
        "11")
            REPO_VER="11"
            ;;
        "12")
            REPO_VER="12"
            ;;
        *)
            echo -e "${YELLOW}⚠ Versão não reconhecida, usando 11 como padrão${NC}"
            REPO_VER="11"
            ;;
    esac
    
    echo "→ Adicionando repositório para Debian $REPO_VER..."
    
    if [ ! -f /etc/apt/sources.list.d/mssql-release.list ]; then
        curl -fsSL https://packages.microsoft.com/config/debian/$REPO_VER/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
        echo -e "${GREEN}✓ Repositório adicionado${NC}"
    else
        echo -e "${YELLOW}⚠ Repositório já existe, pulando...${NC}"
    fi
else
    echo -e "${RED}✗ Sistema operacional não suportado: $OS${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}4. ATUALIZANDO LISTA DE PACOTES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

apt-get update
echo -e "${GREEN}✓ Lista de pacotes atualizada${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}5. INSTALANDO DRIVER ODBC 18 SQL SERVER${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "→ Instalando msodbcsql18..."
ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Também instalar unixodbc-dev (necessário para compilar extensões)
apt-get install -y unixodbc-dev

echo -e "${GREEN}✓ Driver ODBC instalado${NC}"
echo ""

# Verificar instalação
echo "Drivers ODBC instalados:"
odbcinst -q -d | grep -i "SQL Server" || echo "  (nenhum encontrado)"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}6. INSTALANDO FERRAMENTAS DE DESENVOLVIMENTO PHP${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Detectar versão do PHP instalada
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;" 2>/dev/null || echo "8.2")
echo "Versão do PHP detectada: $PHP_VERSION"

apt-get install -y php${PHP_VERSION}-dev php-pear build-essential

echo -e "${GREEN}✓ Ferramentas instaladas${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}7. INSTALANDO EXTENSÕES PHP VIA PECL${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Verificar se já está instalado
if php -m | grep -qi "pdo_sqlsrv"; then
    echo -e "${YELLOW}⚠ pdo_sqlsrv já está instalado, pulando...${NC}"
else
    echo "→ Instalando sqlsrv via PECL..."
    printf "\n" | pecl install sqlsrv
    echo -e "${GREEN}✓ sqlsrv instalado${NC}"
    
    echo "→ Instalando pdo_sqlsrv via PECL..."
    printf "\n" | pecl install pdo_sqlsrv
    echo -e "${GREEN}✓ pdo_sqlsrv instalado${NC}"
fi
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}8. CONFIGURANDO EXTENSÕES NO PHP${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Criar arquivos de configuração
echo "→ Criando arquivos .ini..."

# Para CLI
CLI_INI_DIR="/etc/php/${PHP_VERSION}/cli/conf.d"
if [ -d "$CLI_INI_DIR" ]; then
    echo "extension=sqlsrv.so" > ${CLI_INI_DIR}/30-sqlsrv.ini
    echo "extension=pdo_sqlsrv.so" > ${CLI_INI_DIR}/30-pdo_sqlsrv.ini
    echo -e "${GREEN}✓ Configurado para CLI${NC}"
fi

# Para FPM
FPM_INI_DIR="/etc/php/${PHP_VERSION}/fpm/conf.d"
if [ -d "$FPM_INI_DIR" ]; then
    echo "extension=sqlsrv.so" > ${FPM_INI_DIR}/30-sqlsrv.ini
    echo "extension=pdo_sqlsrv.so" > ${FPM_INI_DIR}/30-pdo_sqlsrv.ini
    echo -e "${GREEN}✓ Configurado para FPM${NC}"
fi

# Para Apache (se houver)
APACHE_INI_DIR="/etc/php/${PHP_VERSION}/apache2/conf.d"
if [ -d "$APACHE_INI_DIR" ]; then
    echo "extension=sqlsrv.so" > ${APACHE_INI_DIR}/30-sqlsrv.ini
    echo "extension=pdo_sqlsrv.so" > ${APACHE_INI_DIR}/30-pdo_sqlsrv.ini
    echo -e "${GREEN}✓ Configurado para Apache${NC}"
fi

echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}9. REINICIANDO SERVIÇOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

# Reiniciar PHP-FPM
if systemctl is-active --quiet php${PHP_VERSION}-fpm; then
    echo "→ Reiniciando PHP-FPM..."
    systemctl restart php${PHP_VERSION}-fpm
    echo -e "${GREEN}✓ PHP-FPM reiniciado${NC}"
fi

# Reiniciar Apache (se houver)
if systemctl is-active --quiet apache2; then
    echo "→ Reiniciando Apache..."
    systemctl restart apache2
    echo -e "${GREEN}✓ Apache reiniciado${NC}"
fi

# Reiniciar Nginx (se houver)
if systemctl is-active --quiet nginx; then
    echo "→ Reiniciando Nginx..."
    systemctl restart nginx
    echo -e "${GREEN}✓ Nginx reiniciado${NC}"
fi

echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}10. VERIFICANDO INSTALAÇÃO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Extensões PHP carregadas:"
php -m | grep -i sqlsrv

if php -m | grep -qi "pdo_sqlsrv"; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║                    ✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!                     ║${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Extensões instaladas:"
    echo "  • sqlsrv"
    echo "  • pdo_sqlsrv"
    echo ""
    echo "Driver ODBC:"
    odbcinst -q -d | grep -i "SQL Server"
    echo ""
    echo -e "${GREEN}PRÓXIMOS PASSOS:${NC}"
    echo "1. Limpar cache do Laravel:"
    echo "   cd /var/www/vistoria"
    echo "   php artisan config:clear"
    echo "   php artisan cache:clear"
    echo ""
    echo "2. Testar conexão:"
    echo "   ./diagnostico-sqlserver.sh"
    echo ""
    echo "3. Ou testar via HTTP:"
    echo "   curl https://autocredcarcloud.com.br/test-db-connection"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                            ║${NC}"
    echo -e "${RED}║                    ✗ ERRO NA INSTALAÇÃO                                    ║${NC}"
    echo -e "${RED}║                                                                            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "A extensão pdo_sqlsrv não foi carregada."
    echo ""
    echo "POSSÍVEIS SOLUÇÕES:"
    echo "1. Verificar logs de erro do PHP:"
    echo "   tail -50 /var/log/php${PHP_VERSION}-fpm.log"
    echo ""
    echo "2. Verificar se os arquivos .so existem:"
    echo "   find /usr -name 'pdo_sqlsrv.so' 2>/dev/null"
    echo ""
    echo "3. Tentar instalação manual:"
    echo "   pecl install pdo_sqlsrv"
    echo ""
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════════════════"
echo "Instalação concluída em $(date '+%d/%m/%Y %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
