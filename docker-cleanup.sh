#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping and removing containers...${NC}"
docker-compose down

echo -e "${BLUE}🗑️  Removing volumes...${NC}"
docker volume rm vistoria_mysql_data vistoria_redis_data 2>/dev/null || true

echo -e "${GREEN}✅ Cleanup completed!${NC}"
