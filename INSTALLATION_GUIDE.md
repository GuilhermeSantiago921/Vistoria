# 📖 GUIA FINAL DE INSTALAÇÃO - UBUNTU

## 🎯 COMECE AQUI

Este é o guia definitivo para instalar o Vistoria em um servidor Ubuntu diretamente do GitHub.

---

## 🚀 INSTALAÇÃO EM 1 MINUTO (Ultra-Rápida)

Copie e execute esta linha:

```bash
curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh | sudo bash
```

**Pronto!** O script cuidará de tudo. Responda as perguntas interativas e aguarde.

---

## 📚 ESCOLHA SEU GUIA

### 🔥 **Para Iniciantes**: Use o Sumário Executivo
👉 [`INSTALL_SUMMARY.md`](./INSTALL_SUMMARY.md) ⏱️ 5 minutos

### ⚡ **Para Intermediários**: Use o Guia Rápido  
👉 [`QUICK_START_UBUNTU.md`](./QUICK_START_UBUNTU.md) ⏱️ 10 minutos

### 🔬 **Para Profissionais**: Use o Guia Completo
👉 [`INSTALL_FROM_GITHUB.md`](./INSTALL_FROM_GITHUB.md) ⏱️ 30 minutos

---

## 📦 ARQUIVOS DE INSTALAÇÃO DISPONÍVEIS

| Arquivo | Tipo | Tempo | Público |
|---------|------|-------|---------|
| **install-from-github.sh** | Script automático | 5-10 min | Sim |
| **INSTALL_SUMMARY.md** | Resumo executivo | 5 min | Sim |
| **QUICK_START_UBUNTU.md** | Guia rápido | 10 min | Sim |
| **INSTALL_FROM_GITHUB.md** | Guia completo | 30 min | Sim |
| **GITHUB_INSTALL_README.md** | README geral | - | Sim |
| **.env.example.documented** | Exemplo .env | - | Sim |

---

## ✅ CHECKLIST PRÉ-INSTALAÇÃO

- [ ] Servidor Ubuntu 20.04+ preparado
- [ ] Acesso SSH com sudo disponível
- [ ] Domínio apontado para o servidor (recomendado)
- [ ] Conexão com internet ativa
- [ ] Backup de dados anterior (se houver)
- [ ] Repositório clonado: https://github.com/GuilhermeSantiago921/Vistoria

---

## 🎬 COMEÇAR INSTALAÇÃO

### Passo 1: Conectar ao Servidor

```bash
ssh root@seu-servidor-ip
```

### Passo 2: Executar Instalação Automática

**Opção A - Uma linha:**
```bash
curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh | sudo bash
```

**Opção B - Download primeiro:**
```bash
cd /tmp
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh
sudo bash install-from-github.sh
```

### Passo 3: Responder Perguntas

O script perguntará por:

| Pergunta | Exemplo | Padrão |
|----------|---------|--------|
| Caminho de instalação | `/var/www/vistoria` | `/var/www/vistoria` |
| Domínio | `vistoria.seu-dominio.com` | Obrigatório |
| Banco de dados | `mysql` ou `postgresql` | `mysql` |
| Host do banco | `localhost` | `localhost` |
| Nome do banco | `vistoria` | `vistoria` |
| Usuário do banco | `vistoria_user` | `vistoria_user` |
| Senha do banco | `sua_senha_muito_segura` | Obrigatório |
| Email admin | `admin@seu-dominio.com` | Obrigatório |
| Senha admin | `senha_super_segura` | Obrigatório |
| Usar HTTPS | `s` ou `n` | Recomendado: `s` |

### Passo 4: Aguardar Conclusão

O script instalará:
- ✅ Sistema operacional atualizado
- ✅ PHP 8.2 com todas as extensões
- ✅ Nginx web server
- ✅ Node.js e npm
- ✅ Composer (gerenciador PHP)
- ✅ Banco de dados escolhido
- ✅ Repositório clonado
- ✅ Dependências instaladas
- ✅ Certificado SSL
- ✅ Usuário admin criado

⏱️ **Tempo estimado: 10-15 minutos**

### Passo 5: Acessar a Aplicação

```
URL: https://seu-dominio.com
Email: admin@seu-dominio.com
Senha: (a que você definiu)
```

---

## 🔍 VERIFICAR INSTALAÇÃO

### 1. Verificar Status dos Serviços

```bash
# Nginx
sudo systemctl status nginx
# Deve exibir: "active (running)"

# PHP-FPM
sudo systemctl status php8.2-fpm
# Deve exibir: "active (running)"

# Banco de dados
sudo systemctl status mysql
# Ou para PostgreSQL:
sudo systemctl status postgresql
# Deve exibir: "active (running)"
```

### 2. Verificar Conexão com Banco

```bash
cd /var/www/vistoria

php artisan tinker
>>> DB::connection()->getPdo();
>>> exit
# Deve retornar um objeto PDO sem erros
```

### 3. Acessar Aplicação

Abra no navegador:
```
https://seu-dominio.com
```

Você deve ver a página de login.

### 4. Testar Login

Faça login com:
- **Email**: admin@seu-dominio.com
- **Senha**: A que você definiu durante a instalação

---

## 🆘 SOLUÇÃO DE PROBLEMAS

### Erro: "Nginx: Connection refused"

```bash
# Reiniciar Nginx
sudo systemctl restart nginx

# Verificar se está rodando
sudo systemctl status nginx
```

### Erro: "502 Bad Gateway"

```bash
# Reiniciar PHP-FPM
sudo systemctl restart php8.2-fpm

# Ver logs
sudo tail -f /var/log/php8.2-fpm.log
```

### Erro: "Database connection refused"

```bash
# Editar arquivo .env
nano /var/www/vistoria/.env

# Verificar valores:
# DB_HOST=127.0.0.1 (ou IP correto)
# DB_PORT=3306 (MySQL) ou 5432 (PostgreSQL)
# DB_USERNAME=vistoria_user
# DB_PASSWORD=sua_senha

# Testar conexão
cd /var/www/vistoria
php artisan tinker
>>> DB::connection()->getPdo();
>>> exit
```

### Erro: "HTTPS não funciona"

```bash
# Renovar certificado
sudo certbot renew --force-renewal

# Verificar certificados
sudo certbot certificates

# Reiniciar Nginx
sudo systemctl restart nginx
```

### Erro: "Permissão negada"

```bash
# Corrigir permissões
cd /var/www/vistoria
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 775 storage/ bootstrap/cache/
```

---

## 📊 ESTRUTURA DO PROJETO

```
/var/www/vistoria/
├── app/                      # Código-fonte da aplicação
│   ├── Http/
│   │   ├── Controllers/      # Controllers
│   │   └── Middleware/       # Middlewares
│   ├── Models/               # Modelos
│   ├── Database/             # Conexão com banco
│   └── Providers/            # Service Providers
├── config/                   # Arquivos de configuração
├── database/
│   ├── migrations/           # Migrações
│   └── seeders/              # Dados iniciais
├── public/                   # Raiz pública (CSS, JS, imagens)
├── resources/                # Views e assets
│   ├── views/                # Templates Blade
│   └── js/                   # JavaScript
├── routes/                   # Rotas da aplicação
├── storage/                  # Logs, cache, uploads
│   └── logs/                 # Arquivo laravel.log
├── vendor/                   # Dependências PHP (gerado)
├── node_modules/             # Dependências Node (gerado)
├── .env                      # Variáveis de ambiente
├── .env.example              # Exemplo .env
├── artisan                   # CLI Laravel
├── composer.json             # Dependências PHP
├── package.json              # Dependências Node
└── vite.config.js            # Build tool

```

---

## 🔄 ATUALIZAR SISTEMA

Para trazer atualizações do GitHub:

```bash
cd /var/www/vistoria

# 1. Fazer backup (segurança)
sudo cp -r . ../vistoria-backup-$(date +%Y%m%d)

# 2. Puxar atualizações
git pull origin main

# 3. Instalar novas dependências
composer install --no-dev
npm install
npm run build

# 4. Executar migrações (se houver)
php artisan migrate --force

# 5. Limpar cache
php artisan cache:clear
php artisan config:clear

# 6. Reiniciar serviços
sudo systemctl restart nginx php8.2-fpm
```

---

## 🔐 SEGURANÇA

### Após Instalação

```bash
# 1. Configurar firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# 2. Proteger arquivo .env
sudo chmod 600 /var/www/vistoria/.env

# 3. Desabilitar acesso a arquivos sensíveis
sudo nano /etc/nginx/sites-available/vistoria
# Adicionar no bloco server:
# location ~ /\.env { deny all; }

# 4. Atualizar sistema regularmente
sudo apt update && sudo apt upgrade -y
```

### Backup Automático

```bash
# Criar script de backup
sudo nano /var/www/vistoria/backup.sh
```

Cole:

```bash
#!/bin/bash
BACKUP_DIR="/backups"
APP_DIR="/var/www/vistoria"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/vistoria-$DATE.tar.gz $APP_DIR
find $BACKUP_DIR -type f -mtime +7 -delete  # Manter apenas 7 dias
```

Ativar:

```bash
sudo chmod +x /var/www/vistoria/backup.sh
sudo crontab -e
# Adicionar: 0 2 * * * /var/www/vistoria/backup.sh
```

---

## 📞 MONITORAMENTO

### Ver Logs em Tempo Real

```bash
# Log da aplicação
tail -f /var/www/vistoria/storage/logs/laravel.log

# Erros do Nginx
sudo tail -f /var/log/nginx/error.log

# Erros do PHP
sudo tail -f /var/log/php8.2-fpm.log
```

### Verificar Recursos

```bash
# Espaço em disco
df -h

# Memória RAM
free -h

# Uso de CPU
top
# ou
htop
```

---

## 🎯 PRÓXIMOS PASSOS

Após instalação bem-sucedida:

1. ✅ **DNS**: Apontar domínio para o servidor
2. ✅ **Acesso**: Testar login como admin
3. ✅ **Email**: Configurar SMTP em .env
4. ✅ **Backup**: Fazer primeiro backup
5. ✅ **Usuários**: Adicionar outros usuários
6. ✅ **Customização**: Personalizar conforme necessário
7. ✅ **Monitoramento**: Configurar alertas e logs

---

## 📈 ESCALABILIDADE

Para um servidor em produção com alto tráfego:

```bash
# 1. Instalar Redis (cache distribuído)
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Editar .env:
# CACHE_DRIVER=redis
# QUEUE_CONNECTION=redis

# 2. Usar pool de conexões PHP-FPM
sudo nano /etc/php/8.2/fpm/pool.d/www.conf
# Aumentar: pm.max_children = 128

# 3. Usar CDN para arquivos estáticos
# Usar cache headers em public/

# 4. Configurar replicação do banco de dados
# Use MySQL replication ou PostgreSQL streaming replication

# 5. Load balancer (se múltiplos servidores)
# Use Nginx ou HAProxy
```

---

## 📚 REFERÊNCIAS

- 📖 [Laravel Docs](https://laravel.com/docs)
- 🐧 [Ubuntu Docs](https://ubuntu.com/server/docs)
- 🔐 [Let's Encrypt](https://letsencrypt.org)
- 🗄️ [MySQL Docs](https://dev.mysql.com/doc/)
- 🐘 [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

## 📝 INFORMAÇÕES DO PROJETO

**Repositório**: https://github.com/GuilhermeSantiago921/Vistoria  
**Branch**: main  
**Linguagem**: PHP/Laravel 11  
**Banco**: MySQL/PostgreSQL/SQL Server  
**Última atualização**: 18 de fevereiro de 2026

---

## 🎓 DOCUMENTAÇÃO ADICIONAL

- **INSTALL_SUMMARY.md** - Resumo executivo (5 min)
- **QUICK_START_UBUNTU.md** - Guia rápido (10 min)
- **INSTALL_FROM_GITHUB.md** - Guia completo (30 min)
- **GITHUB_INSTALL_README.md** - README detalhado

---

## ❓ FAQ

**P: Posso usar outro banco de dados?**  
R: Sim! O script suporta MySQL, PostgreSQL e SQL Server.

**P: Quanto custa?**  
R: Gratuito! Código aberto sob licença MIT.

**P: Funciona em Windows?**  
R: Não diretamente. Use WSL2 (Windows Subsystem for Linux 2) ou máquina virtual Ubuntu.

**P: E no macOS?**  
R: Sim, use Docker ou máquina virtual Ubuntu.

**P: Preciso de domínio?**  
R: Não é obrigatório, mas altamente recomendado para HTTPS.

**P: Quanto tempo leva?**  
R: Com script automático: 10-15 minutos. Manual: 20-30 minutos.

---

## 🎉 PRONTO!

Você está pronto para instalar! 

👉 **Comece agora**: Execute o comando de instalação automática acima.

Qualquer dúvida, consulte os guias disponíveis ou verifique os logs.

**Boa instalação!** 🚀
