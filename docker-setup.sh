#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 VISTORIA VEICULAR - SETUP DOCKER                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Starting Docker containers...${NC}"
docker-compose down 2>/dev/null || true
docker-compose up -d

echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 10

echo -e "${YELLOW}🔧 Running migrations...${NC}"
docker-compose exec -T app php artisan migrate:fresh --seed

echo -e "${YELLOW}🎨 Generating symlink for storage...${NC}"
docker-compose exec -T app php artisan storage:link || true

echo -e "${YELLOW}🗑️  Clearing caches...${NC}"
docker-compose exec -T app php artisan cache:clear
docker-compose exec -T app php artisan config:clear
docker-compose exec -T app php artisan view:clear

echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  📋 URLS E CREDENCIAIS                                ║${NC}"
echo -e "${BLUE}╠════════════════════════════════════════════════════════╣${NC}"
echo -e "${BLUE}║  🌐 Application       → http://localhost:8000         ║${NC}"
echo -e "${BLUE}║  🗄️  PhpMyAdmin       → http://localhost:8080         ║${NC}"
echo -e "${BLUE}║  📊 Redis Commander  → http://localhost:8081         ║${NC}"
echo -e "${BLUE}║  📧 MailHog          → http://localhost:8025         ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║  Database:                                             ║${NC}"
echo -e "${BLUE}║    Host: mysql                                         ║${NC}"
echo -e "${BLUE}║    User: vistoria                                      ║${NC}"
echo -e "${BLUE}║    Pass: vistoria_pass                                 ║${NC}"
echo -e "${BLUE}║    DB:   vistoria                                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}🎯 Useful commands:${NC}"
echo "  View logs:          docker-compose logs -f app"
echo "  Run artisan:        docker-compose exec app php artisan <command>"
echo "  Tinker:             docker-compose exec app php artisan tinker"
echo "  Stop containers:    docker-compose down"
echo "  Reset database:     docker-compose exec app php artisan migrate:fresh --seed"
echo ""
