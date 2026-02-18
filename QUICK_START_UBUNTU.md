# ⚡ Guia Rápido de Instalação - Ubuntu

Se você quer instalar rapidamente sem detalhes, siga este guia.

## 🚀 Instalação Rápida (5 minutos)

### 1. Conectar ao servidor via SSH

```bash
ssh root@seu-servidor-ip
```

### 2. Executar script de instalação automática

```bash
cd /tmp
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-from-github.sh
sudo bash install-from-github.sh
```

O script perguntará por:
- Caminho de instalação
- Domínio
- Tipo de banco (mysql/postgresql/sqlserver)
- Email e senha do admin
- Se deseja HTTPS

Pronto! Tudo instalado automaticamente.

---

## 📝 Instalação Manual Rápida (10 minutos)

Se preferir passo a passo:

```bash
# 1. Atualizar e instalar dependências
sudo apt update && sudo apt upgrade -y
sudo apt install -y php8.2-cli php8.2-fpm php8.2-mysql nginx git composer nodejs npm

# 2. Clonar repositório
cd /var/www
sudo git clone https://github.com/GuilhermeSantiago921/Vistoria.git vistoria
cd vistoria

# 3. Configurar .env
cp .env.example .env
# Edite: nano .env
# Defina: DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD, APP_URL

# 4. Instalar dependências
composer install --no-dev
npm install && npm run build

# 5. Gerar chave
php artisan key:generate

# 6. Migrar banco
php artisan migrate --force

# 7. Permissões
sudo chown -R www-data:www-data .
sudo chmod -R 755 . && sudo chmod -R 775 storage/ bootstrap/cache/

# 8. Pronto! Acesse seu domínio
```

---

## 🗂️ Estrutura de Pastas

```
/var/www/vistoria/
├── app/              # Código da aplicação
├── config/           # Configurações
├── database/         # Migrações e seeds
├── public/           # Arquivos públicos (CSS, JS, imagens)
├── resources/        # Views e assets
├── routes/           # Rotas da aplicação
├── storage/          # Logs e uploads
├── .env              # Configurações do banco
└── artisan           # CLI do Laravel
```

---

## 🔄 Atualizar Sistema

```bash
cd /var/www/vistoria

# Backup
sudo cp -r . ../vistoria-backup-$(date +%Y%m%d)

# Atualizar
git pull origin main
composer install --no-dev
npm install && npm run build
php artisan migrate --force

# Limpar cache
php artisan cache:clear
php artisan config:clear

# Reiniciar
sudo systemctl restart nginx php8.2-fpm
```

---

## 🆘 Problemas Comuns

### Erro 502 Bad Gateway
```bash
sudo systemctl restart php8.2-fpm
```

### Erro de permissões
```bash
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage
```

### Banco de dados não conecta
```bash
# Editar .env
nano /var/www/vistoria/.env

# Testar conexão
cd /var/www/vistoria
php artisan tinker
>>> DB::connection()->getPdo();
```

### Certificado SSL não renova
```bash
sudo certbot renew
```

---

## 📞 Verificar Status

```bash
# Ver se tudo está rodando
systemctl status nginx
systemctl status php8.2-fpm
systemctl status mysql

# Ver logs de erro
tail -f /var/www/vistoria/storage/logs/laravel.log
tail -f /var/log/nginx/error.log
```

---

## ✅ Checklist Pós-Instalação

- [ ] Domínio aponta para o servidor
- [ ] HTTPS funcionando
- [ ] Banco de dados conectado
- [ ] Consegue acessar a URL
- [ ] Login funciona
- [ ] Uploads funcionam
- [ ] Emails funcionam (testar)

---

**Suporte**: Consulte `INSTALL_FROM_GITHUB.md` para instruções detalhadas.
