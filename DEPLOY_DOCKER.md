# 🚀 Guia de Deploy do Sistema de Vistoria com Docker em Servidor Ubuntu

## 📋 Sumário
1. [Preparação da Imagem Docker Localmente](#preparação)
2. [Transferência para o Servidor](#transferência)
3. [Instalação no Servidor Ubuntu](#instalação)
4. [Configuração e Inicialização](#configuração)
5. [Verificação e Testes](#verificação)

---

## 1. Preparação da Imagem Docker Localmente {#preparação}

### Passo 1.1: Salvar a imagem Docker

```bash
# Salvar todas as imagens necessárias
cd /Users/guilherme/Documents/bkp72vistoria/vistoria

# Salvar imagens em formato tar
docker save php:8.2-cli-alpine > images/php-8.2-cli-alpine.tar
docker save mysql:8.0 > images/mysql-8.0.tar
docker save redis:7-alpine > images/redis-7-alpine.tar
docker save phpmyadmin:latest > images/phpmyadmin-latest.tar
docker save mailhog/mailhog:latest > images/mailhog-latest.tar
docker save rediscommander/redis-commander:latest > images/redis-commander-latest.tar
```

### Passo 1.2: Criar arquivo de exportação do projeto

```bash
# Criar arquivo tar comprimido do projeto inteiro
tar -czf vistoria-docker-complete.tar.gz \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='vendor' \
  --exclude='storage/logs/*' \
  --exclude='storage/framework/cache/*' \
  --exclude='.docker/*' \
  --exclude='docker-compose.override.yml' \
  .

# Verificar tamanho
ls -lh vistoria-docker-complete.tar.gz
```

### Passo 1.3: Criar script de instalação

Veja o arquivo `install-docker-server.sh` incluído neste pacote.

---

## 2. Transferência para o Servidor {#transferência}

### Via SCP (Secure Copy):

```bash
# Transferir arquivo comprimido
scp -P 22 vistoria-docker-complete.tar.gz root@seu-servidor-ip:/tmp/

# Transferir script de instalação
scp -P 22 install-docker-server.sh root@seu-servidor-ip:/tmp/
```

### Via FTP/SFTP:
Use um cliente SFTP como FileZilla para transferir os arquivos.

---

## 3. Instalação no Servidor Ubuntu {#instalação}

### Conexão SSH ao Servidor

```bash
ssh root@seu-servidor-ip
```

### Executar script de instalação

```bash
cd /tmp

# Dar permissão de execução
chmod +x install-docker-server.sh

# Executar script
./install-docker-server.sh
```

O script irá:
- ✅ Instalar Docker e Docker Compose
- ✅ Descompactar o projeto
- ✅ Carregar as imagens Docker
- ✅ Criar diretórios necessários
- ✅ Configurar permissões

### Instalação Manual (Alternativa)

Se preferir fazer manualmente:

```bash
# 1. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash get-docker.sh
sudo usermod -aG docker $USER

# 2. Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Descompactar projeto
cd /var/www
tar -xzf /tmp/vistoria-docker-complete.tar.gz
cd vistoria

# 4. Carregar imagens Docker
docker load < images/php-8.2-cli-alpine.tar
docker load < images/mysql-8.0.tar
docker load < images/redis-7-alpine.tar
docker load < images/phpmyadmin-latest.tar
docker load < images/mailhog-latest.tar
docker load < images/redis-commander-latest.tar
```

---

## 4. Configuração e Inicialização {#configuração}

### Passo 4.1: Configurar variáveis de ambiente

```bash
cd /var/www/vistoria

# Copiar e editar arquivo de configuração
cp .env.example .env
# ou usar o .env já configurado
# cp .env.docker .env

# Editar .env conforme necessário
nano .env
```

**Importante:** Altere as seguintes variáveis para o servidor:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com

# Banco de dados (alterar senha)
DB_PASSWORD=sua_senha_forte_aqui

# Email (configurar se necessário)
MAIL_HOST=seu-smtp.com
MAIL_USERNAME=seu-email@dominio.com
MAIL_PASSWORD=sua_senha_smtp

# Integração SQL Server (se usar)
DB_AGREGADOS_HOST=seu-servidor-sql
```

### Passo 4.2: Criar volumes de dados

```bash
# Criar diretórios para persistência de dados
mkdir -p /data/vistoria/{mysql,redis}
chmod 755 /data/vistoria/{mysql,redis}
```

### Passo 4.3: Iniciar os containers

```bash
cd /var/www/vistoria

# Iniciar todos os serviços
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs da aplicação
docker-compose logs -f app
```

### Passo 4.4: Executar migrações (se necessário)

```bash
# Executar migrações do banco de dados
docker-compose exec app php artisan migrate --force

# Criar usuário administrador
docker-compose exec app php artisan tinker
# Dentro do tinker:
# >>> User::create(['name' => 'Admin', 'email' => 'admin@vistoria.com', 'password' => bcrypt('senha123'), 'role' => 'admin'])
```

---

## 5. Verificação e Testes {#verificação}

### Verificar se tudo está funcionando

```bash
# Verificar status dos containers
docker-compose ps

# Testar conectividade do banco
docker-compose exec app php artisan tinker
# >>> DB::connection()->getPdo()

# Verificar logs
docker-compose logs app
docker-compose logs mysql
docker-compose logs redis
```

### URLs de acesso

- **Aplicação**: http://seu-servidor-ip:8000
- **phpMyAdmin**: http://seu-servidor-ip:8080
- **Redis Commander**: http://seu-servidor-ip:8081
- **Mailhog**: http://seu-servidor-ip:8025

---

## 🔒 Segurança para Produção

### 1. Configurar Nginx Reverso

```bash
# Instalar Nginx
sudo apt-get update
sudo apt-get install nginx

# Criar configuração reversa
sudo nano /etc/nginx/sites-available/vistoria
```

**Exemplo de configuração:**

```nginx
server {
    listen 80;
    server_name seu-dominio.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. Configurar SSL (Let's Encrypt)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

### 3. Limitar portas abertas

```bash
# Liberar apenas portas necessárias
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable
```

### 4. Backups automáticos

```bash
# Criar script de backup
cat > /usr/local/bin/backup-vistoria.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/vistoria"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)

# Backup do banco de dados
docker-compose -f /var/www/vistoria/docker-compose.yml exec -T mysql mysqldump -u vistoria -pvistoria_pass vistoria > $BACKUP_DIR/db_$DATE.sql

# Backup dos uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /var/www/vistoria/storage/

# Manter apenas últimos 7 dias
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /usr/local/bin/backup-vistoria.sh

# Agendar backup diário (crontab)
0 2 * * * /usr/local/bin/backup-vistoria.sh
```

---

## 📞 Troubleshooting

### Container não inicia

```bash
# Ver logs detalhados
docker-compose logs app

# Verificar recursos
docker stats

# Reiniciar container
docker-compose restart app
```

### Problema de conexão com banco de dados

```bash
# Testar conectividade MySQL
docker-compose exec app mysql -h vistoria-mysql -u vistoria -p vistoria

# Verificar se MySQL está healthy
docker-compose exec mysql mysql -u vistoria -p -e "SELECT 1"
```

### Permissões de arquivo

```bash
# Corrigir permissões
sudo chown -R www-data:www-data /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/bootstrap/cache
```

---

## 🔄 Atualizações e Manutenção

### Atualizar aplicação

```bash
cd /var/www/vistoria

# Parar containers
docker-compose down

# Puxar nova versão do código
git pull origin main

# Reconstruir e iniciar
docker-compose up -d

# Executar migrações
docker-compose exec app php artisan migrate --force
```

### Limpeza de espaço

```bash
# Remover containers parados
docker container prune -f

# Remover imagens não usadas
docker image prune -a -f

# Remover volumes não usados
docker volume prune -f
```

---

## 📊 Monitoramento

### Verificar uso de recursos

```bash
# Monitoramento em tempo real
docker stats

# Verificar logs da aplicação
docker-compose logs -f --tail=100 app
```

### Health Check

```bash
# Testar saúde dos serviços
curl http://localhost:8000/api/health
curl http://localhost:8080  # phpMyAdmin
curl http://localhost:8081  # Redis Commander
```

---

## ✅ Checklist de Deploy

- [ ] Docker instalado no servidor
- [ ] Imagens carregadas com sucesso
- [ ] Projeto descompactado em `/var/www/vistoria`
- [ ] Arquivo `.env` configurado para produção
- [ ] Volumes de dados criados
- [ ] Containers iniciados e healthy
- [ ] Migrações executadas
- [ ] Nginx configurado como reverso proxy
- [ ] SSL certificado instalado
- [ ] Firewall configurado
- [ ] Backups automáticos agendados
- [ ] Sistema testado e validado

---

**Última atualização:** 18 de fevereiro de 2026
**Versão:** 1.0
