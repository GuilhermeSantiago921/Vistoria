# 🗄️ INSTALAÇÃO MYSQL - PASSO A PASSO COMPLETO

## 📋 Guia Detalhado para Instalar MySQL do Zero

---

## 🎯 CENÁRIO 1: Ubuntu / Debian (Recomendado para Iniciantes)

### ✅ PASSO 1: Atualizar o Sistema

```bash
sudo apt update
sudo apt upgrade -y
```

**O que faz:** Atualiza a lista de pacotes e o sistema.

---

### ✅ PASSO 2: Instalar MySQL Server

```bash
sudo apt install mysql-server -y
```

**Aguarde:** 2-5 minutos dependendo da conexão.

---

### ✅ PASSO 3: Verificar se MySQL Está Rodando

```bash
sudo systemctl status mysql
```

**Deve aparecer:** `active (running)` em verde ✅

Se não estiver rodando:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

---

### ✅ PASSO 4: Configurar Segurança do MySQL

```bash
sudo mysql_secure_installation
```

**Responda as perguntas:**

1. `Would you like to setup VALIDATE PASSWORD component?`
   - Digite: **n** (não precisa para começar)

2. `Please set the password for root`
   - Digite: **sua senha forte** (exemplo: `MySenha@123!`)
   - Confirme: **mesma senha**

3. `Remove anonymous users?`
   - Digite: **Y** (sim)

4. `Disallow root login remotely?`
   - Digite: **Y** (sim, por segurança)

5. `Remove test database?`
   - Digite: **Y** (sim)

6. `Reload privilege tables now?`
   - Digite: **Y** (sim)

✅ **MySQL configurado com segurança!**

---

### ✅ PASSO 5: Testar Acesso ao MySQL

```bash
sudo mysql -u root -p
```

Digite a senha que você criou.

**Se entrou no MySQL, aparecerá:**
```
mysql>
```

---

### ✅ PASSO 6: Criar Banco de Dados

**Dentro do MySQL (no prompt `mysql>`):**

```sql
CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

**Verificar se foi criado:**
```sql
SHOW DATABASES;
```

Deve aparecer `vistoria` na lista! ✅

---

### ✅ PASSO 7: Criar Usuário para o Sistema

**Ainda dentro do MySQL:**

```sql
CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY 'SuaSenhaAqui123!';
```

**Dar permissões ao usuário:**
```sql
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';
FLUSH PRIVILEGES;
```

**Sair do MySQL:**
```sql
EXIT;
```

---

### ✅ PASSO 8: Criar as Tabelas

**Baixar o script de criação:**
```bash
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/create-tables.sql
```

**Executar o script:**
```bash
mysql -u root -p vistoria < create-tables.sql
```

Digite a senha root e aguarde.

---

### ✅ PASSO 9: Verificar se Tabelas Foram Criadas

```bash
mysql -u root -p vistoria -e "SHOW TABLES;"
```

**Deve mostrar 14 tabelas:**
- cache
- cache_locks
- credit_transactions
- failed_jobs
- inspection_details
- inspections
- job_batches
- jobs
- migrations
- password_reset_tokens
- sessions
- users
- vehicles

✅ **MySQL instalado e configurado com sucesso!**

---

## 🎯 CENÁRIO 2: Rocky Linux / CentOS / AlmaLinux

### ✅ PASSO 1: Atualizar o Sistema

```bash
sudo dnf update -y
```

---

### ✅ PASSO 2: Instalar MySQL Server

```bash
sudo dnf install mysql-server -y
```

---

### ✅ PASSO 3: Iniciar e Habilitar MySQL

```bash
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

**Verificar status:**
```bash
sudo systemctl status mysqld
```

---

### ✅ PASSO 4: Configurar Segurança

```bash
sudo mysql_secure_installation
```

**Siga as mesmas respostas do Cenário 1.**

---

### ✅ PASSO 5 a 9: Igual ao Cenário 1

Continue a partir do **PASSO 5** do Cenário 1 acima.

---

## 🎯 CENÁRIO 3: Fedora

### ✅ Comandos Rápidos:

```bash
sudo dnf install community-mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
```

Depois continue do **PASSO 5** do Cenário 1.

---

## 📊 RESUMO DOS COMANDOS (Ubuntu/Debian)

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar MySQL
sudo apt install mysql-server -y

# 3. Iniciar MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# 4. Configurar segurança
sudo mysql_secure_installation

# 5. Criar banco e usuário
sudo mysql -u root -p
# Dentro do MySQL:
CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'vistoria_user'@'localhost' IDENTIFIED BY 'SuaSenha123!';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 6. Criar tabelas
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/create-tables.sql
mysql -u root -p vistoria < create-tables.sql

# 7. Verificar
mysql -u root -p vistoria -e "SHOW TABLES;"
```

---

## 🔧 CONFIGURAÇÃO PARA ACESSO REMOTO (Opcional)

Se você quer acessar o MySQL de **outro servidor**:

### PASSO 1: Editar Configuração

**Ubuntu/Debian:**
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

**Rocky/CentOS:**
```bash
sudo nano /etc/my.cnf
```

### PASSO 2: Encontrar e Alterar

Procure a linha:
```
bind-address = 127.0.0.1
```

Altere para:
```
bind-address = 0.0.0.0
```

**Salvar:** `Ctrl+O`, `Enter`, `Ctrl+X`

### PASSO 3: Criar Usuário para Acesso Remoto

```bash
sudo mysql -u root -p
```

**Dentro do MySQL:**
```sql
CREATE USER 'vistoria_user'@'%' IDENTIFIED BY 'SuaSenha123!';
GRANT ALL PRIVILEGES ON vistoria.* TO 'vistoria_user'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### PASSO 4: Liberar Firewall

**Ubuntu/Debian:**
```bash
sudo ufw allow 3306/tcp
```

**Rocky/CentOS:**
```bash
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

### PASSO 5: Reiniciar MySQL

```bash
sudo systemctl restart mysql
# ou
sudo systemctl restart mysqld
```

---

## 🆘 PROBLEMAS COMUNS

### ❌ Erro: "Access denied for user 'root'@'localhost'"

**Solução:**
```bash
sudo mysql
# Dentro do MySQL:
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'NovaSenha123!';
FLUSH PRIVILEGES;
EXIT;
```

---

### ❌ Erro: "Can't connect to local MySQL server"

**Solução:**
```bash
sudo systemctl start mysql
sudo systemctl status mysql
```

---

### ❌ Erro: "mysql: command not found"

**Solução (Ubuntu/Debian):**
```bash
sudo apt install mysql-client -y
```

**Solução (Rocky/CentOS):**
```bash
sudo dnf install mysql -y
```

---

### ❌ MySQL não inicia

**Ver logs de erro:**
```bash
sudo tail -f /var/log/mysql/error.log
# ou
sudo journalctl -u mysql -n 50
```

**Resetar MySQL:**
```bash
sudo systemctl stop mysql
sudo rm -rf /var/lib/mysql/*
sudo mysqld --initialize
sudo systemctl start mysql
```

---

## 📝 INFORMAÇÕES IMPORTANTES

### 🔐 Senhas Criadas (ANOTE!)

1. **Senha root do MySQL:** `_______________`
2. **Senha do vistoria_user:** `_______________`

### 📊 Informações do Banco

- **Host:** `localhost` (ou `127.0.0.1`)
- **Porta:** `3306`
- **Banco:** `vistoria`
- **Usuário:** `vistoria_user`
- **Charset:** `utf8mb4`

### 📦 Configuração .env (Laravel)

Adicione no arquivo `.env` do seu projeto Laravel:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vistoria
DB_USERNAME=vistoria_user
DB_PASSWORD=SuaSenha123!
```

---

## ✅ CHECKLIST FINAL

Marque conforme for completando:

- [ ] MySQL Server instalado
- [ ] MySQL rodando (`systemctl status mysql`)
- [ ] Senha root configurada
- [ ] Banco `vistoria` criado
- [ ] Usuário `vistoria_user` criado
- [ ] Permissões concedidas
- [ ] Script `create-tables.sql` executado
- [ ] 14 tabelas criadas (`SHOW TABLES`)
- [ ] Teste de conexão OK
- [ ] Senhas anotadas em local seguro
- [ ] Arquivo `.env` configurado (se for usar Laravel)

---

## 🎓 COMANDOS ÚTEIS PARA O DIA A DIA

### Ver status do MySQL:
```bash
sudo systemctl status mysql
```

### Iniciar MySQL:
```bash
sudo systemctl start mysql
```

### Parar MySQL:
```bash
sudo systemctl stop mysql
```

### Reiniciar MySQL:
```bash
sudo systemctl restart mysql
```

### Acessar MySQL:
```bash
mysql -u root -p
# ou
mysql -u vistoria_user -p vistoria
```

### Ver todos os bancos:
```sql
SHOW DATABASES;
```

### Usar um banco:
```sql
USE vistoria;
```

### Ver tabelas:
```sql
SHOW TABLES;
```

### Ver estrutura de uma tabela:
```sql
DESCRIBE users;
```

### Ver registros:
```sql
SELECT * FROM users;
```

### Fazer backup:
```bash
mysqldump -u root -p vistoria > backup_$(date +%Y%m%d).sql
```

### Restaurar backup:
```bash
mysql -u root -p vistoria < backup_20241208.sql
```

---

## 🚀 SCRIPT AUTOMATIZADO (MÉTODO RÁPIDO)

Se quiser instalar **tudo automaticamente** (MySQL + criar banco + tabelas):

```bash
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/install-mysql-server.sh
sudo bash install-mysql-server.sh
```

Responda as perguntas e pronto! ✅

---

## 📞 Suporte

- **Email:** guilhermesantiago921@gmail.com
- **GitHub:** https://github.com/GuilhermeSantiago921/Vistoria/issues

---

## 🎉 PRONTO!

Seu MySQL está instalado e configurado! Agora você pode:

1. ✅ Conectar sua aplicação Laravel
2. ✅ Começar a usar o sistema de vistoria
3. ✅ Inserir dados e fazer vistorias

**Boa sorte com seu projeto!** 🚀
