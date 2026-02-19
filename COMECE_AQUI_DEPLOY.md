# 🚀 DEPLOY DOCKER - INSTRUÇÕES RÁPIDAS

## 📌 O Que Você Precisa Fazer

### Passo 1: Preparar o Pacote de Exportação

No seu computador local, execute:

```bash
cd ~/Documents/bkp72vistoria/vistoria

# Dar permissão e executar script de exportação
./export-docker-images.sh
```

Isso irá:
- ✅ Salvar todas as imagens Docker necessárias
- ✅ Compactar o projeto inteiro
- ✅ Criar script de transferência automática

**Tempo estimado:** 5-10 minutos

---

### Passo 2: Transferir para o Servidor

Você tem 3 opções:

#### **Opção A: Transferência Automática (Recomendado)**

```bash
./transfer-to-server.sh root@seu-servidor-ip 22
```

#### **Opção B: Transferência Manual**

```bash
scp vistoria-docker-complete.tar.gz root@seu-servidor-ip:/tmp/
scp install-docker-server.sh root@seu-servidor-ip:/tmp/
scp -r images/ root@seu-servidor-ip:/tmp/
```

#### **Opção C: Usar Panel/sFTP**

Se seu servidor tem um painel de controle, faça upload manual dos arquivos.

---

### Passo 3: Instalar no Servidor

Conecte-se ao servidor Ubuntu via SSH:

```bash
ssh root@seu-servidor-ip
```

Execute o script de instalação:

```bash
bash /tmp/install-docker-server.sh
```

O script irá automaticamente:
- ✅ Instalar Docker e Docker Compose
- ✅ Carregar as imagens
- ✅ Descompactar o projeto
- ✅ Configurar variáveis de ambiente
- ✅ Iniciar os containers
- ✅ Executar migrações do banco

**Tempo estimado:** 10-15 minutos

---

### Passo 4: Acessar o Sistema

Após a instalação, acesse:

```
🌐 Aplicação:       http://seu-servidor-ip:8000
📊 phpMyAdmin:      http://seu-servidor-ip:8080
🎛️ Redis Commander:  http://seu-servidor-ip:8081
📧 MailHog:         http://seu-servidor-ip:8025
```

---

## 📋 Requisitos do Servidor

- **SO:** Ubuntu 20.04+ ou Debian 11+
- **RAM:** Mínimo 2GB (4GB recomendado)
- **Disco:** Mínimo 20GB livres
- **Rede:** Conexão estável com internet
- **Acesso:** SSH como root

---

## 🔐 Informações Importantes

### Credenciais Padrão

```
Banco de Dados MySQL:
  Host: vistoria-mysql
  Usuário: vistoria
  Senha: vistoria_pass
  Banco: vistoria

phpMyAdmin:
  Usuário: vistoria
  Senha: vistoria_pass
```

### O que foi gerado

```
✓ vistoria-docker-complete.tar.gz     (Projeto completo ~500MB)
✓ install-docker-server.sh            (Script de instalação)
✓ transfer-to-server.sh               (Script de transferência)
✓ images/                             (Imagens Docker ~3-5GB)
```

---

## 🔧 Após a Instalação

### 1. Configurar Segurança

```bash
# No servidor, liberar portas
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Configurar Domínio (Recomendado)

```bash
# Instalar Nginx como reverso proxy
sudo apt install nginx

# Configurar DNS apontando para IP do servidor
# Depois gerar SSL com Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

### 3. Agendar Backups

```bash
# Criar script de backup
nano /usr/local/bin/backup-vistoria.sh

# Adicionar ao crontab
crontab -e
# 0 2 * * * /usr/local/bin/backup-vistoria.sh
```

---

## 📊 Monitoramento

### Ver Status

```bash
cd /var/www/vistoria
docker-compose ps
```

### Ver Logs

```bash
docker-compose logs -f app
docker-compose logs -f mysql
```

### Testar Saúde

```bash
curl http://localhost:8000/
curl http://localhost:8080/
```

---

## ❌ Problemas Comuns

### "Docker command not found"

```bash
# Solução: Fazer logout e login novamente
# Ou usar:
sudo usermod -aG docker $USER
newgrp docker
```

### "Port already in use"

```bash
# Liberar porta (exemplo porta 8000)
sudo lsof -i :8000
sudo kill -9 <PID>
```

### "No space left on device"

```bash
# Limpar espaço
docker system prune -a -f
docker volume prune -f
```

### Containers não iniciam

```bash
# Ver logs detalhados
docker-compose logs
docker logs vistoria-app

# Reiniciar
docker-compose restart
```

---

## 📚 Documentação Completa

Para detalhes completos de deployment, consulte:
- **`DEPLOY_DOCKER.md`** - Guia completo de deploy
- **`DEPLOY_RAPIDO.md`** - Guia rápido com comandos
- **`README.md`** - Documentação do projeto

---

## 🆘 Suporte

### Verificar Versões

```bash
docker --version
docker-compose --version
php -v
mysql --version
```

### Verificar Conectividade

```bash
# Testar conexão com banco
docker-compose exec app mysql -h vistoria-mysql -u vistoria -p

# Testar Redis
docker-compose exec redis redis-cli ping

# Testar aplicação
curl -I http://localhost:8000
```

---

## ✅ Checklist

- [ ] Scripts em ~/Documents/bkp72vistoria/vistoria/
- [ ] Executei `export-docker-images.sh`
- [ ] Transferi arquivos para o servidor
- [ ] Executei `install-docker-server.sh` no servidor
- [ ] Acessei http://servidor-ip:8000
- [ ] Configurei firewall
- [ ] Agendar backups
- [ ] Configurar SSL/Domínio

---

**Tudo pronto?** 🎉 Seu sistema está rodando em produção!

**Data:** 18 de fevereiro de 2026
**Versão:** Docker Deploy v1.0
