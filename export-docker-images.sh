#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║           VISTORIA DOCKER - SCRIPT DE EXPORTAÇÃO DE IMAGENS               ║
# ║                     Para Transferência de Servidor                        ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     EXPORTANDO IMAGENS DOCKER PARA TRANSFERÊNCIA              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Criar diretório de imagens
IMAGES_DIR="./images"
mkdir -p $IMAGES_DIR

echo -e "${GREEN}📦 Salvando imagens Docker...${NC}"
echo ""

# Lista de imagens
IMAGES=(
    "php:8.2-cli-alpine"
    "mysql:8.0"
    "redis:7-alpine"
    "phpmyadmin:latest"
    "mailhog/mailhog:latest"
    "rediscommander/redis-commander:latest"
)

# Salvar cada imagem
for image in "${IMAGES[@]}"; do
    filename=$(echo $image | tr '/:' '-').tar
    filepath="$IMAGES_DIR/$filename"
    
    echo -e "${BLUE}▶ Salvando: $image${NC}"
    echo "  Arquivo: $filepath"
    
    docker save "$image" > "$filepath"
    
    size=$(du -h "$filepath" | cut -f1)
    echo -e "${GREEN}✅ Salvo ($size)${NC}"
    echo ""
done

echo -e "${GREEN}📦 Criando pacote completo do projeto...${NC}"
echo ""

# Criar pacote tar.gz do projeto
PACKAGE="vistoria-docker-complete.tar.gz"

echo -e "${BLUE}▶ Compactando projeto${NC}"

tar -czf "$PACKAGE" \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='vendor' \
  --exclude='.env' \
  --exclude='storage/logs/*' \
  --exclude='storage/framework/cache/*' \
  --exclude='bootstrap/cache/*' \
  --exclude='.docker' \
  --exclude='*.tar.gz' \
  --exclude='*.tar' \
  --exclude='.DS_Store' \
  --exclude='.vscode' \
  .

size=$(du -h "$PACKAGE" | cut -f1)
echo -e "${GREEN}✅ Projeto compactado ($size)${NC}"
echo ""

# Criar script de transferência
echo -e "${GREEN}📋 Criando script de transferência...${NC}"
echo ""

cat > transfer-to-server.sh << 'EOF'
#!/bin/bash

# Script para transferir arquivos para servidor

if [ $# -lt 2 ]; then
    echo "Uso: ./transfer-to-server.sh <usuario@host> <porta>"
    echo "Exemplo: ./transfer-to-server.sh root@192.168.1.100 22"
    exit 1
fi

SERVER=$1
PORT=${2:-22}

echo "Transferindo arquivos para: $SERVER"
echo ""

# Transferir pacote do projeto
echo "▶ Transferindo pacote do projeto..."
scp -P $PORT vistoria-docker-complete.tar.gz $SERVER:/tmp/

# Transferir script de instalação
echo "▶ Transferindo script de instalação..."
scp -P $PORT install-docker-server.sh $SERVER:/tmp/

# Transferir imagens Docker
echo "▶ Transferindo imagens Docker..."
mkdir -p /tmp/docker-images-transfer
cp images/*.tar /tmp/docker-images-transfer/ 2>/dev/null

scp -P $PORT -r /tmp/docker-images-transfer $SERVER:/tmp/images

# Limpeza
rm -rf /tmp/docker-images-transfer

echo ""
echo "✅ Transferência concluída!"
echo ""
echo "Próximos passos no servidor:"
echo "  1. ssh -p $PORT $SERVER"
echo "  2. sudo bash /tmp/install-docker-server.sh"

EOF

chmod +x transfer-to-server.sh

echo -e "${GREEN}✅ Script de transferência criado: transfer-to-server.sh${NC}"
echo ""

# Resumo
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    RESUMO DA EXPORTAÇÃO                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}📦 Arquivos preparados:${NC}"
echo "  • Imagens Docker: $IMAGES_DIR/ (6 imagens)"
echo "  • Pacote do projeto: $PACKAGE"
echo "  • Script de instalação: install-docker-server.sh"
echo "  • Script de transferência: transfer-to-server.sh"
echo ""

total_size=$(du -sh . | cut -f1 | awk '{print $1}')
echo -e "${BLUE}💾 Espaço total: $total_size${NC}"
echo ""

echo -e "${GREEN}🚀 Para transferir para o servidor:${NC}"
echo "  ./transfer-to-server.sh root@seu-servidor-ip 22"
echo ""

echo -e "${GREEN}📖 Ou transferir manualmente:${NC}"
echo "  scp vistoria-docker-complete.tar.gz root@seu-servidor-ip:/tmp/"
echo "  scp install-docker-server.sh root@seu-servidor-ip:/tmp/"
echo "  scp -r images/ root@seu-servidor-ip:/tmp/"
echo ""

echo -e "${GREEN}✅ Exportação concluída com sucesso!${NC}"
