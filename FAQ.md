# ❓ FAQ — Perguntas Frequentes

## Instalação

### P: O instalador pode ser interrompido?
**R:** Não é recomendado. Se for interrompido, a instalação pode ficar inconsistente. Recomenda-se:
1. Fazer backup de `/var/www/vistoria`
2. Remover: `rm -rf /var/www/vistoria`
3. Executar o instalador novamente

---

### P: Qual é a senha padrão?
**R:** Não há! O instalador gera senhas aleatórias:
- **MySQL root**: Gerada aleatoriamente
- **MySQL vistoria_user**: Senha configurada durante instalação
- **Admin do sistema**: Senha configurada durante instalação

Guarde as credenciais em local seguro!

---

### P: O instalador suporta CentOS, Debian ou outras distros?
**R:** O script é otimizado para **Ubuntu 22.04 LTS** e **24.04 LTS**. Para outras distros:
- Debian 11/12: Deve funcionar (mesma base que Ubuntu)
- CentOS/RHEL: Requer modificações (use gerenciador `yum` em vez de `apt`)
- Alpine: Não é suportado

---

### P: Como desfazer a instalação?
**R:** Para remover completamente:

```bash
# Parar serviços
sudo systemctl stop nginx php8.2-fpm mysql supervisor

# Remover diretórios
sudo rm -rf /var/www/vistoria
sudo rm -rf /etc/nginx/sites-available/vistoria
sudo rm -rf /etc/nginx/sites-enabled/vistoria
sudo rm -f /etc/supervisor/conf.d/vistoria-worker.conf

# Remover banco de dados (CUIDADO!)
sudo mysql -e "DROP DATABASE vistoria;"
sudo mysql -e "DROP USER 'vistoria_user'@'localhost';"

# Reiniciar serviços
sudo systemctl start nginx php8.2-fpm mysql
sudo supervisorctl reread
sudo supervisorctl update
```

---

## Acesso e Login

### P: Esqueci a senha do admin
**R:** Redefina via CLI:

```bash
cd /var/www/vistoria
php artisan tinker
# No prompt, execute:
$user = App\Models\User::find(1);
$user->password = Hash::make('nova_senha');
$user->save();
exit;
```

---

### P: Não consigo acessar o sistema
**R:** Verifique:

1. **Nginx está rodando?**
   ```bash
   sudo systemctl status nginx
   ```

2. **PHP-FPM está ativo?**
   ```bash
   sudo systemctl status php8.2-fpm
   ```

3. **Firewall bloqueou a porta?**
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```

4. **DNS apontado corretamente?**
   ```bash
   nslookup seu-dominio.com.br
   # Deve retornar o IP do servidor
   ```

5. **Verifique os logs**
   ```bash
   tail -f /var/log/nginx/error.log
   tail -f /var/www/vistoria/storage/logs/laravel.log
   ```

---

### P: "Erro 502 Bad Gateway"
**R:** O PHP-FPM caiu. Reinicie:

```bash
sudo systemctl restart php8.2-fpm
```

Se persistir, verifique o log:
```bash
sudo journalctl -u php8.2-fpm -n 50
```

---

### P: "Erro 403 Forbidden"
**R:** Problema de permissões. Corrija:

```bash
sudo chown -R www-data:www-data /var/www/vistoria
sudo chmod -R 755 /var/www/vistoria
sudo chmod -R 775 /var/www/vistoria/storage
sudo chmod -R 775 /var/www/vistoria/bootstrap/cache
```

---

## Banco de Dados

### P: Como fazer backup do banco?
**R:** Use `mysqldump`:

```bash
# Backup completo
mysqldump -uroot -p vistoria > /backup/vistoria_$(date +%Y%m%d).sql

# Com credenciais do arquivo
source /root/.vistoria_mysql_credentials
mysqldump -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} > /backup/vistoria_$(date +%Y%m%d).sql
```

---

### P: Como restaurar um backup?
**R:**

```bash
mysql -uroot -p vistoria < /backup/vistoria_20260220.sql
```

---

### P: Banco ficou corrompido
**R:** Repare o banco:

```bash
# Ver tabelas corrompidas
mysqlcheck -u root -p vistoria

# Reparar
mysqlcheck -u root -p --repair vistoria

# Se não funcionar, restaure do backup
```

---

### P: Preciso aumentar limites de conexão MySQL
**R:** Edite `/etc/mysql/mysql.conf.d/mysqld.cnf`:

```bash
[mysqld]
max_connections = 1000
max_allowed_packet = 256M
```

Reinicie: `sudo systemctl restart mysql`

---

## Performance e Otimização

### P: Site está lento
**R:** Verifique:

1. **Uso de CPU/RAM**
   ```bash
   htop
   ```

2. **Verificar workers de fila**
   ```bash
   sudo supervisorctl status
   ```

3. **Cache está ativado?**
   ```bash
   ls -la /var/www/vistoria/bootstrap/cache/
   ```

4. **OPcache do PHP está ativo?**
   ```bash
   php -i | grep opcache
   ```

5. **Aumentar workers Supervisor**
   ```bash
   # Editar /etc/supervisor/conf.d/vistoria-worker.conf
   # Aumentar: numprocs=4 (em vez de 2)
   sudo supervisorctl reread
   sudo supervisorctl update
   ```

---

### P: Banco está lento
**R:** Crie índices em colunas frequentemente consultadas:

```bash
cd /var/www/vistoria
php artisan tinker
# No prompt:
DB::statement('CREATE INDEX idx_column ON table(column)');
```

---

## SSL e Segurança

### P: Como instalar SSL depois?
**R:**

```bash
sudo certbot --nginx -d seu-dominio.com.br -d www.seu-dominio.com.br
```

---

### P: Certificado SSL expirou
**R:** Renove:

```bash
# Testar renovação
sudo certbot renew --dry-run

# Renovar de verdade
sudo certbot renew
```

A renovação automática está configurada no cron (diário às 03:00).

---

### P: Como desabilitar SSL?
**R:**

```bash
# Editar .env
nano /var/www/vistoria/.env

# Mudar APP_URL de https para http
APP_URL=http://seu-dominio.com.br

# Recarregar cache
cd /var/www/vistoria
php artisan config:cache

# Recarregar Nginx
sudo systemctl reload nginx
```

---

## E-mail e Notificações

### P: Como configurar e-mail?
**R:** Edite `/var/www/vistoria/.env`:

**Gmail:**
```bash
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app (não a senha do Gmail!)
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@seu-dominio.com"
```

**SendGrid:**
```bash
MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=sua-chave-sendgrid
MAIL_ENCRYPTION=tls
```

Depois execute:
```bash
cd /var/www/vistoria
php artisan config:cache
```

---

### P: Testes de e-mail no terminal
**R:**

```bash
cd /var/www/vistoria
php artisan tinker

# Enviar e-mail de teste
Mail::raw('Teste de e-mail', function($msg) {
    $msg->to('seu-email@exemplo.com');
    $msg->subject('Teste');
});
```

---

## Atualizações e Manutenção

### P: Como atualizar o sistema?
**R:** Atualize Linux:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
```

Atualize o código da aplicação:
```bash
cd /var/www/vistoria
git pull origin main
composer install --no-dev
npm install
npm run build
php artisan migrate --force
```

---

### P: Como fazer backup completo?
**R:**

```bash
# Criar diretório de backup
mkdir -p /backup

# Backup do banco
mysqldump -uroot -p vistoria > /backup/vistoria_db_$(date +%Y%m%d_%H%M%S).sql

# Backup dos arquivos
tar -czf /backup/vistoria_files_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/vistoria

# Backup do .env (importante!)
cp /var/www/vistoria/.env /backup/vistoria_env_$(date +%Y%m%d_%H%M%S)

# Listar backups
ls -lh /backup/
```

---

## Monitoramento

### P: Como monitorar a saúde do sistema?
**R:** Use ferramentas como Prometheus, Grafana ou simples scripts:

```bash
# Ver status geral
cd /var/www/vistoria
php artisan verify

# Ver tamanho do banco
mysql -uroot -p -e "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size MB' FROM information_schema.TABLES WHERE table_schema = 'vistoria';"

# Ver espaço em disco
df -h /var/www

# Ver uso de memória
free -h

# Ver processos PHP/MySQL
ps aux | grep php
ps aux | grep mysql
```

---

### P: Log fica muito grande
**R:** Faça rotação de logs. Crie `/etc/logrotate.d/vistoria`:

```bash
/var/www/vistoria/storage/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload php8.2-fpm > /dev/null 2>&1 || true
    endscript
}
```

---

## Segurança

### P: Como melhorar segurança?
**R:** Checklist de segurança:

- [ ] Firewall configurado e restritivo
- [ ] SSH com chaves públicas (desabilitar password auth)
- [ ] Fail2Ban instalado para bloquear brute-force
- [ ] Backup regular do banco
- [ ] .env não versionado no Git
- [ ] Permissões corretas (www-data owner)
- [ ] SSL/HTTPS ativado
- [ ] Regular: `apt update && apt upgrade`
- [ ] Monitorar logs: `/var/log/auth.log`, `/var/log/nginx/`

---

### P: Como desabilitar acesso SSH via password?
**R:** Edite `/etc/ssh/sshd_config`:

```bash
sudo nano /etc/ssh/sshd_config

# Encontre e comente:
#PasswordAuthentication yes

# Adicione:
PasswordAuthentication no
PubkeyAuthentication yes
```

Reinicie: `sudo systemctl restart ssh`

---

## Suporte Técnico

Não encontrou sua pergunta? Consulte:

1. **Log de instalação**: `/tmp/vistoria-install-*.log`
2. **Logs do Laravel**: `/var/www/vistoria/storage/logs/laravel.log`
3. **Logs do Nginx**: `/var/log/nginx/error.log`
4. **GitHub Issues**: https://github.com/GuilhermeSantiago921/Vistoria/issues

---

**Última atualização**: Fevereiro 2026
