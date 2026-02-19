#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                   VISTORIA DOCKER - SCRIPT DE INSTALAÇÃO                  ║
# ║                     Para Servidor Ubuntu/Debian                           ║
# ╚════════════════════════════════════════════════════════════════════════════╝

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
PROJECT_DIR="/var/www/vistoria"
BACKUP_DIR="/data/vistoria"
DOCKER_IMAGES_DIR="/tmp/images"

# Função para imprimir com cores
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Função para verificar se é root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Este script deve ser executado como root (use 'sudo')"
        exit 1
    fi
    print_success "Executando como root"
}

# Função para instalar Docker
install_docker() {
    print_info "Instalando Docker..."
    
    if command -v docker &> /dev/null; then
        print_success "Docker já está instalado"
    else
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        
        # Adicionar usuário ao grupo docker
        usermod -aG docker $SUDO_USER 2>/dev/null || true
        
        print_success "Docker instalado com sucesso"
    fi
    
    # Iniciar serviço Docker
    systemctl start docker
    systemctl enable docker
    print_success "Docker service ativado"
}

# Função para instalar Docker Compose
install_docker_compose() {
    print_info "Instalando Docker Compose..."
    
    if command -v docker-compose &> /dev/null; then
        print_success "Docker Compose já está instalado"
    else
        DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
        curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        print_success "Docker Compose instalado com sucesso"
    fi
}

# Função para carregar imagens Docker
load_docker_images() {
    print_info "Carregando imagens Docker..."
    
    if [ ! -d "$DOCKER_IMAGES_DIR" ]; then
        print_error "Diretório de imagens não encontrado: $DOCKER_IMAGES_DIR"
        print_warning "Pulando carregamento de imagens (serão baixadas do Docker Hub)"
        return
    fi
    
    for image in $DOCKER_IMAGES_DIR/*.tar; do
        if [ -f "$image" ]; then
            print_info "Carregando: $(basename $image)"
            docker load < "$image"
            print_success "Imagem carregada: $(basename $image)"
        fi
    done
}

# Função para descompactar projeto
extract_project() {
    print_info "Descompactando projeto..."
    
    # Procurar por arquivo tar.gz na pasta /tmp
    TAR_FILE=$(find /tmp -maxdepth 1 -name "vistoria-docker-*.tar.gz" | head -n 1)
    
    if [ -z "$TAR_FILE" ]; then
        print_error "Arquivo de projeto não encontrado em /tmp"
        print_warning "Procure por: vistoria-docker-complete.tar.gz"
        exit 1
    fi
    
    print_info "Usando arquivo: $TAR_FILE"
    
    # Criar diretório de projeto
    mkdir -p $PROJECT_DIR
    
    # Descompactar
    tar -xzf "$TAR_FILE" -C $PROJECT_DIR --strip-components=1
    
    print_success "Projeto descompactado em $PROJECT_DIR"
}

# Função para criar diretórios de persistência
create_volumes() {
    print_info "Criando diretórios de persistência..."
    
    mkdir -p $BACKUP_DIR/{mysql,redis,uploads}
    chmod -R 755 $BACKUP_DIR
    
    print_success "Diretórios criados"
}

# Função para configurar arquivo .env
configure_env() {
    print_info "Configurando arquivo .env..."
    
    cd $PROJECT_DIR
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.docker" ]; then
            cp .env.docker .env
            print_success "Arquivo .env criado de .env.docker"
        elif [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "Arquivo .env criado de .env.example"
        else
            print_error "Nenhum arquivo de exemplo encontrado"
            exit 1
        fi
    fi
    
    # Solicitar dados de produção
    print_warning "Configuração de Produção:"
    
    read -p "Domain/IP (padrão: localhost): " DOMAIN
    DOMAIN=${DOMAIN:-localhost}
    
    read -p "Email admin (padrão: admin@vistoria.com): " ADMIN_EMAIL
    ADMIN_EMAIL=${ADMIN_EMAIL:-admin@vistoria.com}
    
    read -sp "Senha do banco de dados (padrão: vistoria_pass): " DB_PASSWORD
    DB_PASSWORD=${DB_PASSWORD:-vistoria_pass}
    
    # Atualizar .env
    sed -i "s|APP_URL=.*|APP_URL=http://$DOMAIN|g" .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|g" .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|g" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|g" .env
    sed -i "s|ADMIN_EMAIL=.*|ADMIN_EMAIL=$ADMIN_EMAIL|g" .env
    
    print_success "Arquivo .env configurado"
}

# Função para iniciar containers
start_containers() {
    print_info "Iniciando containers Docker..."
    
    cd $PROJECT_DIR
    
    docker-compose down --remove-orphans 2>/dev/null || true
    docker-compose up -d
    
    # Aguardar containers ficarem healthy
    print_info "Aguardando containers ficarem pronto..."
    sleep 15
    
    docker-compose ps
    
    print_success "Containers iniciados"
}

# Função para executar migrações
run_migrations() {
    print_info "Executando migrações do banco de dados..."
    
    cd $PROJECT_DIR
    
    docker-compose exec -T app php artisan migrate --force || true
    
    print_success "Migrações executadas"
}

# Função para verificação final
final_check() {
    print_info "Realizando verificação final..."
    
    cd $PROJECT_DIR
    
    echo ""
    print_success "Status dos containers:"
    docker-compose ps
    
    echo ""
    print_success "URLs de acesso:"
    echo -e "  ${BLUE}Aplicação:${NC}        http://localhost:8000"
    echo -e "  ${BLUE}phpMyAdmin:${NC}       http://localhost:8080"
    echo -e "  ${BLUE}Redis Commander:${NC}  http://localhost:8081"
    echo -e "  ${BLUE}Mailhog:${NC}          http://localhost:8025"
    
    echo ""
    print_success "Credenciais do banco:"
    echo -e "  ${BLUE}Usuário:${NC}  vistoria"
    echo -e "  ${BLUE}Senha:${NC}    vistoria_pass"
    echo -e "  ${BLUE}Host:${NC}     vistoria-mysql"
    
    echo ""
    print_success "Próximos passos:"
    echo "  1. Configurar firewall: sudo ufw allow 80,443/tcp"
    echo "  2. Configurar Nginx reverso (opcional)"
    echo "  3. Instalar SSL com Let's Encrypt (opcional)"
    echo "  4. Agendar backups automáticos"
}

# Função principal
main() {
    clear
    
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                   VISTORIA DOCKER - INSTALAÇÃO                            ║"
    echo "║                     Para Servidor Ubuntu/Debian                           ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_root
    
    print_info "Iniciando instalação..."
    echo ""
    
    install_docker
    print_success "---"
    
    install_docker_compose
    print_success "---"
    
    load_docker_images
    print_success "---"
    
    extract_project
    print_success "---"
    
    create_volumes
    print_success "---"
    
    configure_env
    print_success "---"
    
    start_containers
    print_success "---"
    
    run_migrations
    print_success "---"
    
    final_check
    
    echo ""
    print_success "✨ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo ""
}

# Executar função principal
main
