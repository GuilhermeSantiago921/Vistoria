# 🗄️ COMO PREPARAR O BANCO DE DADOS

## 📋 Escolha Seu Cenário

### 🎯 Cenário 1: Banco de Dados na MESMA máquina (Recomendado para começar)
**SQLite - Automático**
- ✅ **Mais simples**
- ✅ O instalador já faz tudo automaticamente
- ✅ Nenhuma configuração extra necessária

**Como instalar:**
```bash
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash
```

Quando perguntar: `Deseja instalar MySQL? (S/n)`
- Digite **n** ou apenas aperte **ENTER**

**PRONTO! Banco configurado automaticamente.**

---

### 🔵 Cenário 2: Banco de Dados em SERVIDOR SEPARADO
**MySQL em outro servidor**

#### PASSO 1: No Servidor de Banco de Dados

```bash
# Baixar e executar instalador MySQL
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-mysql-server.sh
sudo bash install-mysql-server.sh
```

**O script vai perguntar:**
1. Senha root do MySQL → `digite uma senha forte`
2. Nome do banco → `vistoria` (aperte ENTER)
3. Usuário → `vistoria_user` (aperte ENTER)
4. Senha do usuário → `digite uma senha`
5. IP do servidor de aplicação → `192.168.1.100` (ou IP do seu servidor web)

**Anote as informações que aparecerem no final!**

#### PASSO 2: No Servidor de Aplicação (Web)

```bash
# Instalar a aplicação
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash
```

Quando perguntar: `Deseja instalar MySQL? (S/n)`
- Digite **S** para usar MySQL remoto

Quando perguntar as informações do banco:
- **Host:** IP do servidor de banco (ex: `192.168.1.50`)
- **Porta:** `3306`
- **Banco:** `vistoria`
- **Usuário:** `vistoria_user`
- **Senha:** a senha que você criou no PASSO 1

**PRONTO! Aplicação conectada ao banco remoto.**

---

## 🚀 RESUMO RÁPIDO

### Para Instalação Simples (1 servidor):
```bash
# Execute e escolha SQLite (opção padrão)
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash
```

### Para Instalação com 2 Servidores:

**Servidor de Banco (execute primeiro):**
```bash
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-mysql-server.sh
sudo bash install-mysql-server.sh
```

**Servidor Web (execute depois):**
```bash
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash
# Escolha MySQL e informe os dados do servidor de banco
```

---

## 📊 Comparação: SQLite vs MySQL Separado

| Característica | SQLite (1 servidor) | MySQL (2 servidores) |
|----------------|---------------------|----------------------|
| **Facilidade** | ⭐⭐⭐⭐⭐ Muito fácil | ⭐⭐⭐ Médio |
| **Velocidade de instalação** | 10-15 minutos | 20-30 minutos |
| **Manutenção** | ⭐⭐⭐⭐⭐ Simples | ⭐⭐⭐ Requer mais atenção |
| **Performance (poucos usuários)** | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐⭐⭐ Muito boa |
| **Performance (muitos usuários)** | ⭐⭐⭐ Boa | ⭐⭐⭐⭐⭐ Excelente |
| **Backup** | ⭐⭐⭐⭐⭐ 1 arquivo | ⭐⭐⭐ Mysqldump |
| **Escalabilidade** | ⭐⭐⭐ Limitada | ⭐⭐⭐⭐⭐ Alta |
| **Custo** | 💰 1 servidor | 💰💰 2 servidores |

---

## 🤔 Qual Escolher?

### ✅ Use SQLite (1 servidor) SE:
- Está começando agora
- Tem até 50 usuários simultâneos
- Quer simplicidade
- Não quer gastar com servidor de banco separado
- **RECOMENDADO para maioria dos casos!**

### ✅ Use MySQL Separado (2 servidores) SE:
- Tem mais de 50 usuários simultâneos
- Precisa de alta disponibilidade
- Quer fazer replicação/backup avançado
- Tem orçamento para 2 servidores
- Planeja escalar muito

---

## 📝 Instruções Detalhadas por Cenário

### 🟢 CENÁRIO A: SQLite - Instalação Completa em 1 Servidor

```bash
# 1. Conectar no servidor via SSH
ssh root@seu-servidor.com

# 2. Executar instalador
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash

# 3. Responder as perguntas:
#    Domínio: vistoria.exemplo.com
#    Email admin: admin@exemplo.com
#    Senha admin: [sua senha]
#    Instalar MySQL? → n (ENTER)
#    Instalar SSL? → S (ENTER)

# 4. Aguardar 10-15 minutos

# 5. Acessar: https://vistoria.exemplo.com
```

**✅ PRONTO! Sistema funcionando com SQLite.**

---

### 🔵 CENÁRIO B: MySQL - 2 Servidores Separados

#### SERVIDOR 1: Banco de Dados

```bash
# 1. Conectar no servidor de banco
ssh root@banco.exemplo.com

# 2. Executar instalador MySQL
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-mysql-server.sh
sudo bash install-mysql-server.sh

# 3. Responder as perguntas:
#    Senha root MySQL: MinhaSenh@Forte123!
#    Nome banco: vistoria (ENTER)
#    Usuário: vistoria_user (ENTER)
#    Senha usuário: OutraSenh@123!
#    IP servidor app: 192.168.1.100 (IP do servidor web)

# 4. ANOTAR as informações que aparecerem!

# 5. Verificar se está funcionando:
mysql -u root -p
# Digite a senha e teste:
SHOW DATABASES;
USE vistoria;
SHOW TABLES;
EXIT;
```

#### SERVIDOR 2: Aplicação Web

```bash
# 1. Conectar no servidor web
ssh root@web.exemplo.com

# 2. Executar instalador
wget -O - https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install.sh | sudo bash

# 3. Responder as perguntas:
#    Domínio: vistoria.exemplo.com
#    Email admin: admin@exemplo.com
#    Senha admin: [sua senha]
#    Instalar MySQL? → S
#    Host MySQL: 192.168.1.50 (IP do servidor de banco)
#    Porta: 3306 (ENTER)
#    Nome banco: vistoria (ENTER)
#    Usuário: vistoria_user (ENTER)
#    Senha: OutraSenh@123! (a senha do SERVIDOR 1)
#    Instalar SSL? → S (ENTER)

# 4. Aguardar 15-20 minutos

# 5. Testar conexão com banco:
cd /var/www/vistoria
php artisan tinker
# No console PHP:
DB::select('SHOW TABLES');
exit

# 6. Acessar: https://vistoria.exemplo.com
```

**✅ PRONTO! Sistema funcionando com MySQL remoto.**

---

## 🧪 Testar Conexão com Banco de Dados

### SQLite:
```bash
cd /var/www/vistoria
sqlite3 database/database.sqlite "SELECT name FROM sqlite_master WHERE type='table';"
```

### MySQL (remoto):
```bash
mysql -h IP_DO_SERVIDOR_BANCO -u vistoria_user -p vistoria
# Digite a senha
SHOW TABLES;
EXIT;
```

---

## 🔧 Comandos Úteis

### Ver configuração atual do banco:
```bash
cd /var/www/vistoria
cat .env | grep DB_
```

### Verificar se banco tem tabelas:
```bash
cd /var/www/vistoria
php artisan db:show
```

### Rodar migrations (criar tabelas):
```bash
cd /var/www/vistoria
php artisan migrate
```

### Ver status das migrations:
```bash
cd /var/www/vistoria
php artisan migrate:status
```

---

## 🆘 Problemas Comuns

### Erro: "could not find driver"
```bash
# Instalar driver SQLite
sudo apt install php8.2-sqlite3  # Ubuntu/Debian
sudo dnf install php-pdo         # Rocky/CentOS
sudo systemctl restart php8.2-fpm
```

### Erro: "Access denied" (MySQL)
```bash
# Verificar usuário no servidor de banco:
mysql -u root -p
SELECT user, host FROM mysql.user WHERE user='vistoria_user';

# Se não aparecer o host correto:
CREATE USER 'vistoria_user'@'IP_SERVIDOR_WEB' IDENTIFIED BY 'senha';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'IP_SERVIDOR_WEB';
FLUSH PRIVILEGES;
```

### Erro: "Can't connect to MySQL server"
```bash
# No servidor de banco, verificar firewall:
sudo ufw status
sudo ufw allow 3306/tcp

# Verificar se MySQL está aceitando conexões remotas:
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Procurar: bind-address = 0.0.0.0
sudo systemctl restart mysql
```

### Banco sem tabelas:
```bash
cd /var/www/vistoria
php artisan migrate:fresh
# CUIDADO: Isso apaga todos os dados!
```

---

## 📦 Backup do Banco

### SQLite:
```bash
# Backup simples
cp /var/www/vistoria/database/database.sqlite ~/backup_$(date +%Y%m%d).sqlite

# Backup compactado
tar -czf ~/backup_$(date +%Y%m%d).tar.gz /var/www/vistoria/database/database.sqlite
```

### MySQL:
```bash
# Backup completo
mysqldump -u root -p vistoria > ~/backup_$(date +%Y%m%d).sql

# Backup compactado
mysqldump -u root -p vistoria | gzip > ~/backup_$(date +%Y%m%d).sql.gz

# Restaurar
mysql -u root -p vistoria < backup_20241208.sql
```

---

## 📞 Suporte

Se tiver dúvidas:
- **Email:** guilhermesantiago921@gmail.com
- **GitHub Issues:** https://github.com/GuilhermeSantiago921/Vistoria/issues

---

## ✅ Checklist Final

### Para SQLite (1 servidor):
- [ ] Instalador executado com sucesso
- [ ] Escolheu SQLite (respondeu 'n' para MySQL)
- [ ] Arquivo `database/database.sqlite` existe
- [ ] Comando `php artisan migrate:status` mostra tabelas
- [ ] Sistema acessível via navegador
- [ ] Login funciona

### Para MySQL (2 servidores):
- [ ] MySQL instalado no servidor de banco
- [ ] Porta 3306 liberada no firewall
- [ ] Usuário e senha criados
- [ ] Conexão testada do servidor web
- [ ] Instalador executado no servidor web
- [ ] Arquivo `.env` com configurações corretas
- [ ] Comando `php artisan migrate:status` mostra tabelas
- [ ] Sistema acessível via navegador
- [ ] Login funciona

---

**🎉 Banco de dados configurado e pronto para usar!**
