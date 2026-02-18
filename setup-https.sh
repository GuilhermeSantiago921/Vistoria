#!/bin/bash

# ============================================================
# Script para ativar HTTPS no projeto Vistoria
# Cria certificados SSL e configura Laravel para HTTPS
# Versão: 2.0 - Corrigido para compatibilidade com servidores
# ============================================================

set -e  # Para em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        🔒 CONFIGURAÇÃO HTTPS - VISTORIA LARAVEL            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================
# 0. Verificar dependências
# ============================================================
echo -e "${YELLOW}[0/4]${NC} Verificando dependências..."

# Verificar se openssl está instalado
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}❌ OpenSSL não está instalado!${NC}"
    echo ""
    echo "Instale com:"
    echo "  Ubuntu/Debian: sudo apt-get install openssl"
    echo "  CentOS/RHEL:   sudo yum install openssl"
    echo "  macOS:         brew install openssl"
    exit 1
fi
echo -e "${GREEN}✅ OpenSSL encontrado:${NC} $(openssl version)"

# ============================================================
# 1. Criar diretório de certificados
# ============================================================
echo ""
echo -e "${YELLOW}[1/4]${NC} Criando diretório de certificados..."

CERT_DIR="./certs"

# Criar diretório se não existir
if [ ! -d "$CERT_DIR" ]; then
    mkdir -p "$CERT_DIR"
    echo -e "${GREEN}✅ Diretório criado:${NC} $CERT_DIR"
else
    echo -e "${GREEN}✅ Diretório já existe:${NC} $CERT_DIR"
fi

# Verificar permissões de escrita
if [ ! -w "$CERT_DIR" ]; then
    echo -e "${RED}❌ Sem permissão de escrita em $CERT_DIR${NC}"
    echo "Execute: sudo chmod 755 $CERT_DIR"
    exit 1
fi

# ============================================================
# 2. Detectar hostname/domínio do servidor
# ============================================================
echo ""
echo -e "${YELLOW}[2/4]${NC} Detectando configuração do servidor..."

# Tentar detectar hostname
HOSTNAME=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "localhost")
IP_ADDRESS=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "127.0.0.1")

echo -e "${BLUE}Hostname detectado:${NC} $HOSTNAME"
echo -e "${BLUE}IP detectado:${NC} $IP_ADDRESS"

# Perguntar qual CN usar
echo ""
echo "Qual domínio/hostname usar no certificado?"
echo "  1) localhost (padrão - desenvolvimento local)"
echo "  2) $HOSTNAME (hostname do servidor)"
echo "  3) $IP_ADDRESS (IP do servidor)"
echo "  4) Personalizado (digite manualmente)"
echo ""
read -p "Escolha (1-4) [1]: " CHOICE

case $CHOICE in
    2) CN="$HOSTNAME" ;;
    3) CN="$IP_ADDRESS" ;;
    4) 
        read -p "Digite o domínio/hostname: " CN
        if [ -z "$CN" ]; then
            CN="localhost"
        fi
        ;;
    *) CN="localhost" ;;
esac

echo -e "${GREEN}✅ CN selecionado:${NC} $CN"

# ============================================================
# 3. Gerar certificado SSL auto-assinado
# ============================================================
echo ""
echo -e "${YELLOW}[3/4]${NC} Gerando certificado SSL..."

# Verificar se certificados já existem
if [ -f "$CERT_DIR/cert.pem" ] && [ -f "$CERT_DIR/key.pem" ]; then
    echo -e "${YELLOW}⚠️  Certificados já existem em $CERT_DIR${NC}"
    read -p "Deseja sobrescrever? (s/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}✅ Usando certificados existentes${NC}"
    else
        rm -f "$CERT_DIR/cert.pem" "$CERT_DIR/key.pem"
    fi
fi

# Gerar certificado se não existir
if [ ! -f "$CERT_DIR/cert.pem" ] || [ ! -f "$CERT_DIR/key.pem" ]; then
    
    # Criar arquivo de configuração temporário para OpenSSL
    CONFIG_FILE=$(mktemp)
    cat > "$CONFIG_FILE" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ext

[dn]
C = BR
ST = Sao Paulo
L = Sao Paulo
O = Vistoria
OU = TI
CN = $CN

[v3_ext]
subjectAltName = @alt_names
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = $CN
DNS.2 = localhost
DNS.3 = *.localhost
IP.1 = 127.0.0.1
IP.2 = $IP_ADDRESS
EOF

    echo "Gerando certificado para: $CN"
    echo "SANs incluídos: $CN, localhost, *.localhost, 127.0.0.1, $IP_ADDRESS"
    echo ""

    # Gerar certificado com configuração personalizada
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "$CERT_DIR/key.pem" \
        -out "$CERT_DIR/cert.pem" \
        -days 365 \
        -config "$CONFIG_FILE" \
        -extensions v3_ext
    
    RESULT=$?
    
    # Limpar arquivo temporário
    rm -f "$CONFIG_FILE"
    
    if [ $RESULT -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Certificados criados com sucesso!${NC}"
        echo -e "   📄 Certificado: $CERT_DIR/cert.pem"
        echo -e "   🔑 Chave privada: $CERT_DIR/key.pem"
        
        # Definir permissões corretas
        chmod 644 "$CERT_DIR/cert.pem"
        chmod 600 "$CERT_DIR/key.pem"
        echo -e "   🔒 Permissões configuradas (cert: 644, key: 600)"
        
        # Mostrar informações do certificado
        echo ""
        echo -e "${BLUE}Informações do certificado:${NC}"
        openssl x509 -in "$CERT_DIR/cert.pem" -noout -subject -dates 2>/dev/null || true
    else
        echo -e "${RED}❌ Erro ao criar certificados!${NC}"
        echo ""
        echo "Possíveis causas:"
        echo "  1. OpenSSL desatualizado"
        echo "  2. Permissões insuficientes"
        echo "  3. Disco cheio"
        echo ""
        echo "Tente manualmente:"
        echo "  openssl req -x509 -nodes -newkey rsa:2048 \\"
        echo "    -keyout $CERT_DIR/key.pem \\"
        echo "    -out $CERT_DIR/cert.pem \\"
        echo "    -days 365 \\"
        echo "    -subj \"/C=BR/ST=SP/L=SP/O=Vistoria/CN=$CN\""
        exit 1
    fi
fi

# ============================================================
# 4. Atualizar .env para HTTPS
# ============================================================
echo ""
echo -e "${YELLOW}[4/4]${NC} Atualizando configuração de ambiente..."

if [ -f ".env" ]; then
    # Fazer backup
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✅ Backup do .env criado${NC}"
    
    # Atualizar APP_URL - tentar várias variações
    if grep -q "^APP_URL=" .env; then
        # Detectar porta HTTPS (padrão 8443)
        HTTPS_PORT="8443"
        
        # Construir nova URL
        if [ "$CN" = "localhost" ] || [ "$CN" = "127.0.0.1" ]; then
            NEW_URL="https://localhost:$HTTPS_PORT"
        else
            NEW_URL="https://$CN:$HTTPS_PORT"
        fi
        
        # Usar sed compatível com Linux e macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|^APP_URL=.*|APP_URL=$NEW_URL|" .env
        else
            # Linux
            sed -i "s|^APP_URL=.*|APP_URL=$NEW_URL|" .env
        fi
        
        echo -e "${GREEN}✅ APP_URL atualizado para:${NC} $NEW_URL"
    else
        echo "APP_URL=https://$CN:8443" >> .env
        echo -e "${GREEN}✅ APP_URL adicionado ao .env${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado${NC}"
    echo "   Crie a partir do .env.example ou configure manualmente"
fi

# ============================================================
# Resultado final
# ============================================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✅ HTTPS CONFIGURADO COM SUCESSO!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📁 Arquivos criados:${NC}"
ls -lh "$CERT_DIR"/ 2>/dev/null || echo "   Erro ao listar diretório"

echo ""
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo ""
echo "1. Reconstrua os containers Docker:"
echo -e "   ${YELLOW}docker-compose down${NC}"
echo -e "   ${YELLOW}docker-compose up -d --build${NC}"
echo ""
echo "2. Acesse a aplicação:"
echo -e "   HTTP:  ${BLUE}http://$CN:8000${NC}"
echo -e "   HTTPS: ${GREEN}https://$CN:8443${NC}"
echo ""
echo -e "${YELLOW}⚠️  Aviso de Segurança:${NC}"
echo "   O certificado é auto-assinado (desenvolvimento)."
echo "   O navegador mostrará um aviso - clique em 'Aceitar risco'."
echo ""
echo -e "${YELLOW}📌 Para produção:${NC}"
echo "   Use Let's Encrypt para certificados válidos:"
echo "   sudo certbot certonly --standalone -d seu-dominio.com"
echo ""

# Verificar se Docker está disponível
if command -v docker-compose &> /dev/null; then
    echo ""
    read -p "Deseja reiniciar os containers agora? (s/N): " RESTART
    if [[ "$RESTART" =~ ^[Ss]$ ]]; then
        echo ""
        echo "Reiniciando containers..."
        docker-compose down 2>/dev/null || true
        docker-compose up -d --build
        echo ""
        echo -e "${GREEN}✅ Containers reiniciados!${NC}"
        echo ""
        docker-compose ps
    fi
fi

echo ""
echo -e "${GREEN}🎉 Configuração concluída!${NC}"
