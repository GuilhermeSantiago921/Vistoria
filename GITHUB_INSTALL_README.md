# 📖 README - Instruções de Instalação do GitHub

> Versão: 1.0 | Atualizado: 18 de fevereiro de 2026

## 🚀 Comece Aqui

Este documento fornece as instruções para instalar o **Vistoria** em um servidor Ubuntu, clonando diretamente do GitHub.

---

## 📋 Opções de Instalação

Escolha a opção que melhor se adequa ao seu caso:

### 🔥 **Opção 1: Instalação Automática (Recomendada)**

A forma mais rápida! O script faz tudo automaticamente.

**Tempo estimado: 5-10 minutos**

```bash
cd /tmp
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh -O install.sh
sudo bash install.sh
```

**Vantagens:**
- ✅ Instalação completa automatizada
- ✅ Perguntas interativas
- ✅ Configuração de SSL incluída
- ✅ Criação de usuário admin
- ✅ Sem erros manuais

**Veja:** [`install-from-github.sh`](./install-from-github.sh)

---

### 📝 **Opção 2: Guia Rápido (Manual Simplificado)**

Passo a passo mais conciso para usuários familiarizados com Linux.

**Tempo estimado: 10-15 minutos**

```bash
# Clonar e instalar em 8 passos simples
git clone https://github.com/GuilhermeSantiago921/Vistoria.git /var/www/vistoria
cd /var/www/vistoria
# ... siga os passos no arquivo QUICK_START_UBUNTU.md
```

**Veja:** [`QUICK_START_UBUNTU.md`](./QUICK_START_UBUNTU.md)

---

### 🔬 **Opção 3: Guia Completo Detalhado**

Instruções passo a passo com explicações detalhadas de cada etapa.

**Tempo estimado: 20-30 minutos**

Perfeito para aprender e customizar cada parte da instalação.

**Veja:** [`INSTALL_FROM_GITHUB.md`](./INSTALL_FROM_GITHUB.md)

---

## 🎯 Recomendações por Perfil

### Para Iniciantes ❓
👉 Use a **Opção 1 (Instalação Automática)**

### Para Usuários Intermediários 📊
👉 Use a **Opção 2 (Guia Rápido)**

### Para Administradores de Sistemas 🔧
👉 Use a **Opção 3 (Guia Completo)** ou personalize a Opção 1

---

## ✅ Pré-requisitos

- **Servidor Ubuntu** 20.04, 22.04 ou 24.04
- **Acesso SSH** com permissões sudo
- **Domínio** (opcional, mas recomendado para HTTPS)
- **Conexão com a internet**

---

## 🏃 Início Rápido (Menos de 5 minutos)

```bash
# 1. Conectar ao servidor
ssh root@seu-servidor

# 2. Executar instalação automática
curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh | sudo bash

# 3. Responder às perguntas interativas
# 4. Aguardar conclusão
# 5. Acessar https://seu-dominio.com
```

---

## 📊 O que será instalado

### Componentes do Sistema
- ✅ PHP 8.2 com extensões Laravel
- ✅ Nginx (Web Server)
- ✅ Node.js 20
- ✅ Composer
- ✅ Git

### Banco de Dados (escolha um)
- ✅ MySQL 8.0
- ✅ PostgreSQL 14+
- ✅ SQL Server (via ODBC)

### Segurança
- ✅ Certificado SSL Let's Encrypt
- ✅ Firewall UFW configurado
- ✅ Permissões corretas
- ✅ .env protegido

---

## 🔧 Configuração Pós-Instalação

### 1. Verificar Status

```bash
# Nginx
sudo systemctl status nginx

# PHP-FPM
sudo systemctl status php8.2-fpm

# Banco de dados
sudo systemctl status mysql  # ou postgresql
```

### 2. Acessar a Aplicação

```
https://seu-dominio.com
```

Login com:
- **Email**: admin@seu-dominio.com (ou o que você definiu)
- **Senha**: A que você definiu durante a instalação

### 3. Verificar Logs

```bash
# Log da aplicação
tail -f /var/www/vistoria/storage/logs/laravel.log

# Erros do Nginx
sudo tail -f /var/log/nginx/error.log

# Erros do PHP
sudo tail -f /var/log/php8.2-fpm.log
```

---

## 🆘 Problemas Comuns

### ❌ "Erro de conexão com banco de dados"

```bash
# Verificar .env
cat /var/www/vistoria/.env | grep DB_

# Testar conexão
cd /var/www/vistoria
php artisan tinker
>>> DB::connection()->getPdo();
>>> exit
```

### ❌ "502 Bad Gateway"

```bash
# Reiniciar PHP-FPM
sudo systemctl restart php8.2-fpm

# Verificar logs
sudo tail -f /var/log/php8.2-fpm.log
```

### ❌ "Erro de permissões"

```bash
cd /var/www/vistoria
sudo chown -R www-data:www-data .
sudo chmod -R 775 storage/ bootstrap/cache/
```

### ❌ "HTTPS não funciona"

```bash
# Renovar certificado
sudo certbot renew --force-renewal

# Verificar
sudo certbot certificates
```

**Para mais soluções:** Ver a seção "Troubleshooting" em [`INSTALL_FROM_GITHUB.md`](./INSTALL_FROM_GITHUB.md)

---

## 🔄 Atualizar Aplicação

Para trazer as atualizações mais recentes do GitHub:

```bash
cd /var/www/vistoria

# Fazer backup (segurança)
sudo cp -r . ../vistoria-backup-$(date +%Y%m%d)

# Puxar atualizações
git pull origin main

# Atualizar dependências
composer install --no-dev
npm install
npm run build

# Executar migrações (se houver)
php artisan migrate --force

# Limpar cache
php artisan cache:clear
php artisan config:clear

# Reiniciar serviços
sudo systemctl restart nginx php8.2-fpm
```

---

## 📱 Conectar com Banco de Dados Remoto

Se usar banco de dados em outro servidor:

```bash
# Editar .env
nano /var/www/vistoria/.env

# Alterar para o IP/host do servidor remoto
DB_HOST=seu-banco.exemplo.com
DB_USERNAME=usuario
DB_PASSWORD=senha
```

---

## 🔒 Segurança

### Recomendações

1. **Firewall**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Backup Regular**
   ```bash
   # Criar script de backup automático
   sudo crontab -e
   # Adicionar: 0 2 * * * /var/www/vistoria/backup.sh
   ```

3. **Monitorar Logs**
   ```bash
   tail -f /var/www/vistoria/storage/logs/laravel.log
   ```

4. **Manter Sistema Atualizado**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 📞 Suporte e Documentação

### Arquivos de Referência

| Arquivo | Descrição |
|---------|-----------|
| [`INSTALL_FROM_GITHUB.md`](./INSTALL_FROM_GITHUB.md) | Guia completo e detalhado |
| [`QUICK_START_UBUNTU.md`](./QUICK_START_UBUNTU.md) | Guia rápido simplificado |
| [`install-from-github.sh`](./install-from-github.sh) | Script de instalação automática |
| [`README.md`](./README.md) | Documentação geral do projeto |

### Recursos Úteis

- 📚 [Laravel Documentation](https://laravel.com/docs)
- 🐧 [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- 🔐 [Let's Encrypt](https://letsencrypt.org)
- 🗄️ [MySQL](https://dev.mysql.com/doc/) | [PostgreSQL](https://www.postgresql.org/docs/)

---

## 🎓 Próximas Etapas

Após a instalação bem-sucedida:

1. ✅ Configurar domínio apontando para o servidor
2. ✅ Acessar a aplicação e fazer login
3. ✅ Configurar email (SMTP)
4. ✅ Fazer primeiro backup
5. ✅ Configurar monitoramento
6. ✅ Adicionar certificado SSL (se não feito automaticamente)
7. ✅ Configurar backups automáticos

---

## 📊 Informações Técnicas

### Versões Suportadas

| Componente | Versão | Status |
|-----------|--------|--------|
| PHP | 8.2+ | ✅ Suportado |
| Laravel | 11.x | ✅ Suportado |
| Node.js | 20+ | ✅ Suportado |
| Ubuntu | 20.04, 22.04, 24.04 | ✅ Suportado |
| MySQL | 8.0+ | ✅ Suportado |
| PostgreSQL | 13+ | ✅ Suportado |

### Estrutura de Diretórios

```
/var/www/vistoria/
├── app/                      # Código-fonte
├── bootstrap/                # Inicialização
├── config/                   # Configurações
├── database/                 # Migrações e seeds
├── public/                   # Arquivos públicos
├── resources/                # Views e assets
├── routes/                   # Rotas
├── storage/                  # Logs, cache, uploads
├── vendor/                   # Dependências PHP
├── node_modules/             # Dependências NPM
├── .env                      # Variáveis de ambiente
├── artisan                   # CLI Laravel
├── composer.json             # Dependências PHP
└── package.json              # Dependências Node
```

---

## ✨ Checklist de Instalação Bem-Sucedida

- [ ] Sistema Ubuntu atualizado
- [ ] PHP 8.2 instalado
- [ ] Nginx configurado
- [ ] Banco de dados funcionando
- [ ] Repositório clonado do GitHub
- [ ] Arquivo .env configurado
- [ ] Dependências instaladas (PHP e Node)
- [ ] Migrações executadas
- [ ] Certificado SSL ativo
- [ ] Usuário admin criado
- [ ] Acesso a https://seu-dominio.com funcionando
- [ ] Login com admin funcionando

---

## 🎉 Parabéns!

Sua instalação está completa! Agora você pode:

✅ Acessar a aplicação Vistoria  
✅ Gerenciar usuários e dados  
✅ Receber atualizações via Git  
✅ Escalar a aplicação conforme necessário  

---

## 📝 Changelog

### v1.0 (18 de fevereiro de 2026)
- ✨ Instalação automática via script
- ✨ Guias de instalação completos
- ✨ Suporte a múltiplos bancos de dados
- ✨ Configuração automática de SSL
- ✨ Troubleshooting detalhado

---

## 📄 Licença

Este projeto está sob a licença [MIT](./LICENSE).

---

**Última atualização**: 18 de fevereiro de 2026  
**Mantido por**: GuilhermeSantiago921  
**Repositório**: https://github.com/GuilhermeSantiago921/Vistoria
