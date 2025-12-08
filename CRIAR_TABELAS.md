# 🗄️ COMO CRIAR AS TABELAS NO SEU BANCO EXISTENTE

## 📋 Você Já Tem MySQL Instalado?

Perfeito! Use este guia para criar apenas as tabelas necessárias.

---

## 🚀 MÉTODO 1: Executar via Terminal (RECOMENDADO)

### Passo 1: Fazer download do arquivo SQL

```bash
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/create-tables.sql
```

### Passo 2: Executar no MySQL

**Opção A: Se você tem um banco chamado `vistoria`:**
```bash
mysql -u root -p vistoria < create-tables.sql
```

**Opção B: Se o banco tem outro nome (ex: `meu_banco`):**
```bash
mysql -u root -p meu_banco < create-tables.sql
```

**Opção C: Com usuário específico:**
```bash
mysql -u vistoria_user -p vistoria < create-tables.sql
```

### Passo 3: Verificar se deu certo

```bash
mysql -u root -p vistoria -e "SHOW TABLES;"
```

Deve mostrar 14 tabelas! ✅

---

## 🖥️ MÉTODO 2: Copiar e Colar no phpMyAdmin

### Passo 1: Abrir o arquivo

```bash
cat create-tables.sql
```

### Passo 2: Copiar todo o conteúdo

### Passo 3: No phpMyAdmin:
1. Selecione seu banco de dados
2. Clique na aba **SQL**
3. Cole o conteúdo completo
4. Clique em **Executar**

✅ Pronto!

---

## 💻 MÉTODO 3: Executar Direto no Console MySQL

### Passo 1: Entrar no MySQL

```bash
mysql -u root -p
```

### Passo 2: Selecionar o banco

```sql
USE vistoria;
-- ou
USE seu_banco;
```

### Passo 3: Executar o arquivo

```sql
SOURCE /caminho/para/create-tables.sql;
-- ou
\. /caminho/para/create-tables.sql
```

### Passo 4: Verificar

```sql
SHOW TABLES;
EXIT;
```

---

## 📊 Tabelas Criadas (14 tabelas)

Após executar, você terá:

1. ✅ **users** - Usuários (admin, analyst, client)
2. ✅ **vehicles** - Veículos cadastrados
3. ✅ **inspections** - Vistorias realizadas
4. ✅ **inspection_details** - Fotos das vistorias (10 fotos)
5. ✅ **credit_transactions** - Histórico de créditos
6. ✅ **sessions** - Sessões de usuários
7. ✅ **cache** - Cache do Laravel
8. ✅ **cache_locks** - Locks do cache
9. ✅ **jobs** - Fila de jobs
10. ✅ **job_batches** - Batches de jobs
11. ✅ **failed_jobs** - Jobs com falha
12. ✅ **password_reset_tokens** - Tokens de reset
13. ✅ **migrations** - Controle de versão
14. ✅ **password_reset_tokens** - Reset de senha

---

## 🔍 COMANDOS ÚTEIS

### Ver todas as tabelas:
```bash
mysql -u root -p vistoria -e "SHOW TABLES;"
```

### Ver estrutura de uma tabela:
```bash
mysql -u root -p vistoria -e "DESCRIBE users;"
```

### Contar registros:
```bash
mysql -u root -p vistoria -e "SELECT COUNT(*) FROM users;"
```

### Ver todas as tabelas com detalhes:
```sql
mysql -u root -p
USE vistoria;
SHOW TABLE STATUS;
EXIT;
```

---

## 🆘 PROBLEMAS COMUNS

### Erro: "Access denied"
```bash
# Verificar usuário e senha
mysql -u root -p
# Digite a senha correta
```

### Erro: "Unknown database"
```bash
# Criar o banco primeiro
mysql -u root -p
CREATE DATABASE vistoria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Depois executar o script
mysql -u root -p vistoria < create-tables.sql
```

### Erro: "Table already exists"
**Não tem problema!** O script usa `CREATE TABLE IF NOT EXISTS`, então não vai dar erro se a tabela já existe.

### Erro: "Foreign key constraint fails"
```bash
# Desabilitar verificação de foreign keys temporariamente
mysql -u root -p vistoria
SET FOREIGN_KEY_CHECKS = 0;
SOURCE create-tables.sql;
SET FOREIGN_KEY_CHECKS = 1;
EXIT;
```

---

## 🔄 RECRIAR TABELAS (ATENÇÃO: APAGA DADOS!)

Se quiser **apagar tudo e recriar**:

```bash
mysql -u root -p vistoria
```

```sql
-- CUIDADO: Isso apaga TODOS os dados!
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS credit_transactions;
DROP TABLE IF EXISTS inspection_details;
DROP TABLE IF EXISTS inspections;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS cache;
DROP TABLE IF EXISTS cache_locks;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS job_batches;
DROP TABLE IF EXISTS failed_jobs;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS migrations;
SET FOREIGN_KEY_CHECKS = 1;
EXIT;
```

Depois executar novamente:
```bash
mysql -u root -p vistoria < create-tables.sql
```

---

## ✅ VERIFICAÇÃO COMPLETA

### Script de verificação:

```bash
mysql -u root -p vistoria << 'EOF'
SELECT 'Verificando tabelas...' AS status;

SELECT 
    TABLE_NAME as 'Tabela',
    TABLE_ROWS as 'Linhas',
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS 'Tamanho (MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;

SELECT CONCAT('Total de tabelas: ', COUNT(*)) AS resultado
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE();
EOF
```

Deve mostrar **14 tabelas**! ✅

---

## 📦 BACKUP (ANTES DE CRIAR)

**Recomendado fazer backup antes:**

```bash
# Backup completo
mysqldump -u root -p vistoria > backup_antes_$(date +%Y%m%d_%H%M%S).sql

# Backup compactado
mysqldump -u root -p vistoria | gzip > backup_antes_$(date +%Y%m%d_%H%M%S).sql.gz
```

---

## 🎯 RESUMO RÁPIDO

```bash
# 1. Download do arquivo
wget https://raw.githubusercontent.com/GuilhermeSantiago921/Vistoria/main/create-tables.sql

# 2. Executar
mysql -u root -p vistoria < create-tables.sql

# 3. Verificar
mysql -u root -p vistoria -e "SHOW TABLES;"

# Deve mostrar 14 tabelas!
```

---

## 📞 Suporte

- **Email:** guilhermesantiago921@gmail.com
- **GitHub:** https://github.com/GuilhermeSantiago921/Vistoria/issues

---

**✅ Tabelas criadas e prontas para uso!** 🎉
