# 📦 INSTRUÇÕES DE INSTALAÇÃO NO UBUNTU - RESUMO EXECUTIVO

**Sistema**: Vistoria  
**Repositório**: https://github.com/GuilhermeSantiago921/Vistoria  
**Data**: 18 de fevereiro de 2026

---

## 🎯 3 Formas de Instalar

### ✨ FORMA 1: AUTOMÁTICA (Recomendada - 5 minutos)

```bash
# Copie e cole uma única linha:
curl -fsSL https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh | sudo bash
```

**O script fará automaticamente:**
- ✅ Atualizar sistema Ubuntu
- ✅ Instalar PHP 8.2, Nginx, Node.js, Composer
- ✅ Instalar banco de dados (MySQL/PostgreSQL/SQL Server)
- ✅ Clonar repositório do GitHub
- ✅ Configurar .env
- ✅ Instalar dependências (PHP e Node)
- ✅ Executar migrações
- ✅ Configurar SSL Let's Encrypt
- ✅ Criar usuário admin

---

### 📝 FORMA 2: RÁPIDA (Manual simplificado - 10 minutos)

Se preferir controlar cada passo:

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências essenciais
sudo apt install -y php8.2-cli php8.2-fpm php8.2-mysql nginx git composer nodejs npm

# 3. Clonar repositório
cd /var/www
sudo git clone https://github.com/GuilhermeSantiago921/Vistoria.git vistoria
cd vistoria

# 4. Configurar .env (editar arquivo)
cp .env.example.documented .env
nano .env
# Preencher: DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD, APP_URL

# 5. Instalar dependências
composer install --no-dev
npm install && npm run build

# 6. Gerar chave e migrar banco
php artisan key:generate
php artisan migrate --force

# 7. Configurar permissões
sudo chown -R www-data:www-data .
sudo chmod -R 775 storage/ bootstrap/cache/

# 8. Pronto! Acesse seu domínio
```

---

### 🔬 FORMA 3: COMPLETA (Detalhada - 30 minutos)

Para aprender cada etapa:

📄 **Ver arquivo**: [`INSTALL_FROM_GITHUB.md`](./INSTALL_FROM_GITHUB.md)

---

## 📋 PRÉ-REQUISITOS

✅ Servidor Ubuntu 20.04, 22.04 ou 24.04  
✅ Acesso SSH com permissões sudo  
✅ Domínio (recomendado para HTTPS)  
✅ Conexão com internet  

---

## 🚀 COMEÇAR AGORA

### Opção A: Via Terminal SSH

```bash
# 1. Conectar ao seu servidor
ssh root@seu-servidor-ip

# 2. Executar instalação
sudo bash < <(curl -s https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh)

# 3. Responder perguntas (domínio, email, senha, etc)

# 4. Aguardar conclusão

# 5. Acessar https://seu-dominio.com
```

### Opção B: Download Manual

```bash
cd /tmp
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh
sudo bash install-from-github.sh
```

---

## ⚙️ DURANTE A INSTALAÇÃO

O script perguntará:

```
1. Caminho de instalação (padrão: /var/www/vistoria)
2. Seu domínio (ex: vistoria.seu-dominio.com.br)
3. Tipo de banco: mysql | postgresql | sqlserver
4. Host do banco (padrão: localhost)
5. Nome do banco (padrão: vistoria)
6. Usuário do banco (padrão: vistoria_user)
7. Senha do banco (escolha uma segura!)
8. Email admin para login
9. Senha admin
10. Usar HTTPS? (recomendado: sim)
```

---

## ✅ APÓS A INSTALAÇÃO

### 1. Verificar Status

```bash
# Ver se Nginx está rodando
sudo systemctl status nginx

# Ver se PHP-FPM está rodando
sudo systemctl status php8.2-fpm

# Ver se banco está rodando
sudo systemctl status mysql  # ou postgresql
```

### 2. Acessar Aplicação

```
URL: https://seu-dominio.com
Email: admin@seu-dominio.com
Senha: (a que você definiu)
```

### 3. Verificar Logs

```bash
# Logs da aplicação
tail -f /var/www/vistoria/storage/logs/laravel.log

# Erros do servidor
sudo tail -f /var/log/nginx/error.log
```

---

## 🔧 COMANDOS ÚTEIS

```bash
# Ver status de todos os serviços
sudo systemctl status nginx php8.2-fpm mysql

# Reiniciar tudo
sudo systemctl restart nginx php8.2-fpm mysql

# Ver logs em tempo real
tail -f /var/www/vistoria/storage/logs/laravel.log

# Atualizar do GitHub
cd /var/www/vistoria
git pull origin main
composer install --no-dev
npm run build
php artisan migrate --force

# Entrar no banco de dados
mysql -u vistoria_user -p vistoria
# ou
psql -U vistoria_user -d vistoria
```

---

## 🆘 PROBLEMAS COMUNS

### ❌ "502 Bad Gateway"
```bash
sudo systemctl restart php8.2-fpm
```

### ❌ "Conexão com banco falhou"
```bash
# Editar .env
nano /var/www/vistoria/.env

# Testar conexão
cd /var/www/vistoria
php artisan tinker
>>> DB::connection()->getPdo();
>>> exit
```

### ❌ "Erro de permissões"
```bash
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage
```

### ❌ "HTTPS não funciona"
```bash
sudo certbot renew --force-renewal
sudo nginx -t
sudo systemctl restart nginx
```

---

## 📚 DOCUMENTAÇÃO COMPLETA

| Arquivo | Descrição |
|---------|-----------|
| **INSTALL_FROM_GITHUB.md** | Guia ultra-completo (30 páginas) |
| **QUICK_START_UBUNTU.md** | Guia rápido (5 páginas) |
| **install-from-github.sh** | Script de instalação automática |
| **.env.example.documented** | Exemplo de .env com comentários |
| **GITHUB_INSTALL_README.md** | README da instalação |

👉 **Todos no repositório**: https://github.com/GuilhermeSantiago921/Vistoria

---

## 🔒 SEGURANÇA - IMPORTANTE!

```bash
# 1. Configurar firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# 2. Proteger .env
sudo chmod 600 /var/www/vistoria/.env

# 3. Usar senhas fortes (20+ caracteres)

# 4. Manter sistema atualizado
sudo apt update && sudo apt upgrade -y

# 5. Fazer backups regulares
sudo cp -r /var/www/vistoria /backup/vistoria-$(date +%Y%m%d)
```

---

## 📊 APÓS INSTALAR COM SUCESSO

✅ Acesso a https://seu-dominio.com funcionando  
✅ Login como admin funcionando  
✅ Banco de dados conectado  
✅ Certificado SSL ativo  
✅ Nginx respondendo corretamente  
✅ Emails podem ser testados  

---

## 🆘 PRECISA DE AJUDA?

### Verificar Logs
```bash
# Log principal
tail -f /var/www/vistoria/storage/logs/laravel.log

# Erros do Nginx
sudo tail -f /var/log/nginx/error.log

# Erros do PHP
sudo tail -f /var/log/php8.2-fpm.log
```

### Testar Conexão com Banco
```bash
cd /var/www/vistoria
php artisan tinker
>>> DB::connection()->getPdo();  # Deve retornar um objeto PDO
>>> exit
```

### Força Reiniciar Tudo
```bash
sudo systemctl restart nginx php8.2-fpm mysql
php artisan cache:clear
php artisan config:clear
```

---

## 📞 SUPORTE

- **Documentação**: Consulte os arquivos .md no repositório
- **Erros do Laravel**: Veja `storage/logs/laravel.log`
- **Erros do Servidor**: Veja `/var/log/nginx/error.log`
- **Repositório**: https://github.com/GuilhermeSantiago921/Vistoria

---

## 🎉 PRÓXIMOS PASSOS

1. ✅ Apontar domínio DNS para o servidor
2. ✅ Fazer login e verificar funcionamento
3. ✅ Configurar email SMTP (verificar .env)
4. ✅ Fazer primeiro backup
5. ✅ Configurar monitoramento
6. ✅ Adicionar usuários
7. ✅ Personalizar conforme necessário

---

**Versão**: 1.0  
**Data**: 18 de fevereiro de 2026  
**Mantido por**: GuilhermeSantiago921  
**Repositório**: https://github.com/GuilhermeSantiago921/Vistoria
