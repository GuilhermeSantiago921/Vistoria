# 🚀 Guia Rápido de Deploy - Sistema de Vistoria Docker

## ⚡ Deploy em 5 Minutos

### Opção 1: Deploy Automático (Recomendado)

#### No seu computador local:

```bash
cd ~/Documents/bkp72vistoria/vistoria

# 1. Dar permissão de execução
chmod +x export-docker-images.sh

# 2. Exportar imagens e criar pacote
./export-docker-images.sh

# 3. Transferir para o servidor
./transfer-to-server.sh root@seu-servidor-ip 22
```

#### No servidor Ubuntu:

```bash
# 1. Conectar ao servidor
ssh root@seu-servidor-ip

# 2. Executar instalação automática
sudo bash /tmp/install-docker-server.sh

# 3. Pronto! Sistema está rodando
docker-compose -f /var/www/vistoria/docker-compose.yml ps
```

---

### Opção 2: Deploy Manual (Passo a Passo)

#### Local:

```bash
# 1. Exportar imagens
docker save php:8.2-cli-alpine > php-8.2-cli-alpine.tar
docker save mysql:8.0 > mysql-8.0.tar
docker save redis:7-alpine > redis-7-alpine.tar
docker save phpmyadmin:latest > phpmyadmin-latest.tar
docker save mailhog/mailhog:latest > mailhog-latest.tar
docker save rediscommander/redis-commander:latest > redis-commander-latest.tar

# 2. Criar pacote do projeto
tar -czf vistoria-docker.tar.gz \
  --exclude='.git' \
  --exclude='vendor' \
  --exclude='node_modules' \
  .

# 3. Enviar para servidor
scp vistoria-docker.tar.gz root@seu-servidor:/tmp/
scp *.tar root@seu-servidor:/tmp/
scp install-docker-server.sh root@seu-servidor:/tmp/
```

#### Servidor:

```bash
# 1. Instalar Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER

# 2. Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Carregar imagens
docker load < php-8.2-cli-alpine.tar
docker load < mysql-8.0.tar
docker load < redis-7-alpine.tar
docker load < phpmyadmin-latest.tar
docker load < mailhog-latest.tar
docker load < redis-commander-latest.tar

# 4. Descompactar projeto
mkdir -p /var/www/vistoria
tar -xzf vistoria-docker.tar.gz -C /var/www/vistoria --strip-components=1
cd /var/www/vistoria

# 5. Configurar .env para produção
nano .env
# Alterar:
# APP_ENV=production
# APP_DEBUG=false
# APP_URL=https://seu-dominio.com

# 6. Iniciar containers
docker-compose up -d

# 7. Executar migrações
docker-compose exec app php artisan migrate --force

# ✅ Pronto!
```

---

## 🔗 Acessar o Sistema

Após o deploy:

```
Aplicação:      http://seu-servidor-ip:8000
phpMyAdmin:     http://seu-servidor-ip:8080
Redis:          http://seu-servidor-ip:8081
Email (MailHog): http://seu-servidor-ip:8025
```

---

## 🔐 Configuração de Produção Essencial

### 1. Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Nginx Reverso

```bash
sudo apt install nginx

# Criar arquivo de configuração
sudo nano /etc/nginx/sites-available/vistoria

# Adicionar:
server {
    listen 80;
    server_name seu-dominio.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# Habilitar site
sudo ln -s /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 3. SSL (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

### 4. Backups Automáticos

```bash
# Criar script de backup
cat > /usr/local/bin/backup-vistoria.sh << 'EOF'
#!/bin/bash
cd /var/www/vistoria
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p /backups/vistoria

# Backup DB
docker-compose exec -T mysql mysqldump -u vistoria -pvistoria_pass vistoria > /backups/vistoria/db_$DATE.sql

# Backup uploads
tar -czf /backups/vistoria/uploads_$DATE.tar.gz storage/

# Manter 7 dias
find /backups/vistoria -type f -mtime +7 -delete
EOF

chmod +x /usr/local/bin/backup-vistoria.sh

# Agendar (crontab -e)
0 2 * * * /usr/local/bin/backup-vistoria.sh
```

---

## 📊 Monitoramento

```bash
# Status dos containers
docker-compose -f /var/www/vistoria/docker-compose.yml ps

# Ver logs
docker-compose -f /var/www/vistoria/docker-compose.yml logs -f app

# Uso de recursos
docker stats

# Teste de saúde
curl http://localhost:8000/
```

---

## 🔄 Atualizar Aplicação

```bash
cd /var/www/vistoria

# Parar containers
docker-compose down

# Puxar novo código
git pull origin main

# Iniciar novamente
docker-compose up -d

# Executar migrações
docker-compose exec app php artisan migrate --force
```

---

## ❌ Troubleshooting

### Containers não iniciam

```bash
docker-compose logs app
docker-compose logs mysql
```

### Sem conexão com banco

```bash
docker-compose exec app php artisan tinker
>>> DB::connection()->getPdo()
```

### Sem espaço em disco

```bash
# Limpeza
docker system prune -a -f
docker volume prune -f
```

---

## ✅ Checklist Final

- [ ] Docker instalado
- [ ] Imagens carregadas
- [ ] Projeto descompactado
- [ ] `.env` configurado
- [ ] Containers iniciados
- [ ] Migrações executadas
- [ ] Firewall configurado
- [ ] Nginx/SSL instalado
- [ ] Backups agendados
- [ ] Teste funcional realizado

---

**Precisa de ajuda?** Consulte `DEPLOY_DOCKER.md` para guia completo.
