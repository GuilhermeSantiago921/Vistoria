# 🚗 Sistema de Vistoria Veicular

Sistema completo de gestão de vistorias veiculares com integração ao banco de dados Agregados, desenvolvido em Laravel 12 + PHP 8.3.

## 📋 Índice

- [Características](#características)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Uso](#uso)
- [Deploy](#deploy)
- [Manutenção](#manutenção)
- [Suporte](#suporte)

---

## ✨ Características

### Para Clientes
- ✅ Upload de 10 fotos obrigatórias da vistoria
- ✅ Validação automática de placa (formato antigo e Mercosul)
- ✅ Preview instantâneo das fotos antes do envio
- ✅ Sistema de créditos para controle de vistorias
- ✅ Histórico completo de vistorias
- ✅ Download de laudos em PDF
- ✅ Notificações por e-mail

### Para Mesários (Analistas)
- ✅ Dashboard com métricas em tempo real
- ✅ Checklist completo de identificação (chassi, motor, etc.)
- ✅ Checklist estrutural (longarinas, colunas, etc.)
- ✅ Integração com base BIN Agregados (SQL Server)
- ✅ Aprovação/Reprovação com observações
- ✅ Visualização de todas as fotos enviadas
- ✅ Geração automática de PDF com resultado

### Para Administradores
- ✅ Gestão completa de usuários
- ✅ Controle de créditos por cliente
- ✅ Criação de mesários e administradores
- ✅ Painel de controle completo
- ✅ Logs detalhados do sistema

### Técnico
- ✅ Laravel 12.30.1 + PHP 8.3
- ✅ SQLite ou MySQL
- ✅ Tailwind CSS + Alpine.js
- ✅ Sistema de filas (Laravel Queue)
- ✅ Notificações por e-mail
- ✅ Upload de arquivos até 70MB
- ✅ Integração SQL Server (Microsoft)
- ✅ Responsive Design (Mobile First)
- ✅ PWA Ready

---

## 🔧 Requisitos

### Mínimos
- **PHP:** 8.1+
- **Composer:** 2.x
- **Node.js:** 18+
- **Banco de Dados:** SQLite 3 ou MySQL 8.0+
- **Servidor Web:** Nginx ou Apache
- **RAM:** 2GB
- **Disco:** 10GB

### Extensões PHP Necessárias
```
php-cli, php-fpm, php-mysql, php-sqlite3, php-xml, php-curl
php-mbstring, php-zip, php-gd, php-bcmath, php-intl, php-opcache
```

### Opcional (Para integração BIN Agregados)
```
php-sqlsrv, php-pdo_sqlsrv
```

---

## 🚀 Instalação

### Opção 1: Instalação Automática (Ubuntu/Debian)

```bash
# Baixar instalador
curl -o install.sh https://raw.githubusercontent.com/seu-repo/vistoria/main/install.sh

# Tornar executável
chmod +x install.sh

# Executar (como root)
sudo ./install.sh
```

O instalador irá:
- ✅ Instalar PHP 8.3, Nginx, Composer, Node.js
- ✅ Configurar banco de dados (SQLite ou MySQL)
- ✅ Instalar dependências
- ✅ Configurar servidor web
- ✅ Criar usuário administrador
- ✅ Instalar SSL (Certbot)
- ✅ Configurar firewall e supervisor

### Opção 2: Instalação Manual

Consulte o guia completo: [INSTALL_LINUX.md](INSTALL_LINUX.md)

---

## ⚙️ Configuração

### 1. Arquivo `.env`

```env
APP_NAME="Sistema de Vistoria"
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://seu-dominio.com.br

# Banco de Dados (SQLite)
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/vistoria/database/database.sqlite

# OU MySQL
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=vistoria
# DB_USERNAME=seu_usuario
# DB_PASSWORD=sua_senha

# E-mail (Gmail exemplo)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app
MAIL_ENCRYPTION=tls

# SQL Server Agregados (Opcional)
DB_AGREGADOS_CONNECTION=sqlsrv
DB_AGREGADOS_HOST=189.113.13.114
DB_AGREGADOS_PORT=1433
DB_AGREGADOS_DATABASE=VeiculosAgregados
DB_AGREGADOS_USERNAME=seu_usuario
DB_AGREGADOS_PASSWORD=sua_senha
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
```

### 2. Permissões

```bash
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 755 /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/bootstrap/cache
```

### 3. Migrações

```bash
cd /var/www/vistoria
php artisan migrate --force
```

### 4. Storage Link

```bash
php artisan storage:link
```

### 5. Cache

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 👥 Criar Usuários

### Administrador

```bash
php artisan tinker
```

```php
$user = new App\Models\User();
$user->name = 'Administrador';
$user->email = 'admin@vistoria.com';
$user->password = bcrypt('senha_segura_123');
$user->role = 'admin';
$user->inspection_credits = 999;
$user->email_verified_at = now();
$user->save();
exit;
```

### Cliente

```php
$user = new App\Models\User();
$user->name = 'Cliente Teste';
$user->email = 'cliente@teste.com';
$user->password = bcrypt('senha123');
$user->role = 'client';
$user->inspection_credits = 10;
$user->email_verified_at = now();
$user->save();
```

### Mesário (Analista)

```php
$user = new App\Models\User();
$user->name = 'João Mesário';
$user->email = 'mesario@vistoria.com';
$user->password = bcrypt('senha123');
$user->role = 'analyst';
$user->email_verified_at = now();
$user->save();
```

---

## 📱 Uso do Sistema

### Cliente

1. **Fazer Login**
   - Acessar: `https://seu-dominio.com.br/login`
   - Email e senha fornecidos pelo admin

2. **Enviar Vistoria**
   - Clicar em "Nova Vistoria"
   - Digitar placa do veículo
   - Fazer upload de 10 fotos:
     - Frente do veículo
     - Traseira do veículo
     - Lateral direita
     - Lateral esquerda
     - Gravação vidro direito
     - Gravação vidro esquerdo
     - Gravação do chassi
     - Etiqueta de identificação
     - Hodômetro
     - Motor

3. **Acompanhar Status**
   - Menu "Meus Laudos"
   - Status: Pendente / Aprovado / Reprovado

4. **Baixar PDF**
   - Após análise, clicar em "Gerar PDF"

### Mesário (Analista)

1. **Acessar Painel**
   - Login com credenciais de mesário
   - Dashboard com vistorias pendentes

2. **Analisar Vistoria**
   - Clicar em "Analisar"
   - Visualizar todas as fotos
   - Preencher checklists:
     - Identificação (chassi, motor, etc.)
     - Estrutural (longarinas, colunas, etc.)

3. **Puxar Dados BIN** (Opcional)
   - Botão "Puxar/Atualizar Dados da BIN Agregados"
   - Preenche automaticamente: chassi, motor, cor, combustível

4. **Aprovar/Reprovar**
   - Adicionar observações
   - Clicar em "Aprovar" ou "Reprovar"
   - Cliente recebe e-mail automático

### Administrador

1. **Gerenciar Usuários**
   - Menu "Gerenciar Usuários"
   - Criar/Editar/Excluir
   - Atribuir créditos

2. **Criar Mesários**
   - Novo usuário com role "analyst"

3. **Monitorar Sistema**
   - Ver logs em `storage/logs/laravel.log`
   - Verificar filas de jobs

---

## 🌐 Deploy

### HostGator (cPanel)

Consulte: [DEPLOY_HOSTGATOR.md](DEPLOY_HOSTGATOR.md)

### VPS Linux (Ubuntu/Debian)

```bash
# 1. Clonar repositório
cd /var/www
git clone https://github.com/seu-usuario/vistoria.git

# 2. Instalar dependências
cd vistoria
composer install --no-dev --optimize-autoloader
npm install && npm run build

# 3. Configurar .env
cp .env.example .env
nano .env  # Editar configurações
php artisan key:generate

# 4. Banco de dados
touch database/database.sqlite
php artisan migrate --force

# 5. Permissões
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 775 storage bootstrap/cache

# 6. Storage link
php artisan storage:link

# 7. Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 8. Configurar Nginx
sudo nano /etc/nginx/sites-available/vistoria
sudo ln -s /etc/nginx/sites-available/vistoria /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Atualização (Deploy)

```bash
sudo bash deploy.sh
```

---

## 🔧 Manutenção

### Backup

```bash
# Backup completo
tar -czf vistoria_backup_$(date +%Y%m%d).tar.gz \
    --exclude='node_modules' \
    --exclude='vendor' \
    /var/www/vistoria

# Backup apenas banco de dados (SQLite)
cp /var/www/vistoria/database/database.sqlite \
   /backups/vistoria_db_$(date +%Y%m%d).sqlite

# MySQL
mysqldump -u usuario -p vistoria > vistoria_db_$(date +%Y%m%d).sql
```

### Logs

```bash
# Laravel
tail -f /var/www/vistoria/storage/logs/laravel.log

# Nginx
sudo tail -f /var/log/nginx/error.log

# PHP-FPM
sudo tail -f /var/log/php8.3-fpm.log
```

### Limpar Cache

```bash
cd /var/www/vistoria
php artisan optimize:clear
```

### Reprocessar Fila

```bash
php artisan queue:work database --tries=3
```

---

## 🐛 Solução de Problemas

### Erro 500

```bash
# Ver logs
tail -100 storage/logs/laravel.log

# Verificar permissões
ls -la storage/
```

### Imagens não aparecem (404)

```bash
# Recriar link
rm public/storage
php artisan storage:link
chmod 755 storage/app/public
```

### Erro de Agregados

```bash
# Testar conexão
php artisan tinker

# No tinker:
DB::connection('sqlsrv_agregados')->getPdo();
```

### Cache não limpa

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan event:clear
```

---

## 📚 Documentação Adicional

- [Instalação Linux](INSTALL_LINUX.md)
- [Deploy HostGator](DEPLOY_HOSTGATOR.md)
- [Correção BIN Agregados](SOLUCAO_ERRO_AGREGADOS.md)
- [Imagens 404](SOLUCAO_IMAGENS_404.md)
- [Alteração Analista→Mesário](ALTERACAO_ANALISTA_MESARIO.md)
- [Criar Admin](CREATE_ADMIN_GUIDE.md)

---

## 🔐 Segurança

- ✅ Autenticação Laravel Breeze
- ✅ CSRF Protection
- ✅ SQL Injection Prevention (PDO)
- ✅ XSS Protection
- ✅ File Upload Validation
- ✅ Rate Limiting
- ✅ HTTPS (SSL/TLS)
- ✅ Environment Variables (.env)

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto é proprietário. Todos os direitos reservados.

---

## 👨‍💻 Autores

- **Desenvolvedor:** [Seu Nome]
- **Cliente:** Grupo Auto Credcar
- **Data:** 2025

---

## 📞 Suporte

- **Email:** suporte@vistoria.com
- **Documentação:** `/docs`
- **Issues:** GitHub Issues

---

## 🎯 Roadmap

### Versão Atual (1.0)
- ✅ Sistema completo de vistorias
- ✅ Integração BIN Agregados
- ✅ PDF com resultado
- ✅ Notificações por e-mail

### Futuro (2.0)
- ⏳ App mobile (React Native)
- ⏳ Assinatura digital
- ⏳ Dashboard analytics avançado
- ⏳ API REST pública
- ⏳ Integração Detran

---

**Sistema de Vistoria Veicular © 2025**
