# 👤 Como Criar Usuário Admin

## 🌐 Opção 1: Via Navegador (RECOMENDADO)

### Passo 1: Faça upload do arquivo

Faça upload de `create-admin.php` para:
```
/home1/sist5700/grupoautocredcar.com.br/vistoria/create-admin.php
```

### Passo 2: Acesse via navegador

```
https://grupoautocredcar.com.br/vistoria/create-admin.php
```

### Passo 3: Preencha o formulário

- **Nome:** Seu nome completo
- **Email:** seu@email.com
- **Senha:** Sua senha (mínimo 6 caracteres)
- **Função:** 
  - 👑 Administrador (acesso total)
  - 📊 Analista (aprova vistorias)
  - 👤 Cliente (solicita vistorias)
- **Créditos:** Quantidade inicial (R$ 25,00 cada)

### Passo 4: Clique em "Criar Usuário"

✅ Pronto! O usuário foi criado!

### Passo 5: Faça login

```
https://grupoautocredcar.com.br/vistoria/login
```

---

## 💻 Opção 2: Via Terminal/SSH

Se você tiver acesso SSH ao servidor:

### Passo 1: Acesse o servidor

```bash
ssh seu-usuario@grupoautocredcar.com.br
```

### Passo 2: Navegue até a pasta do projeto

```bash
cd /home1/sist5700/sistema-vistoria
```

### Passo 3: Execute o comando

```bash
php create-admin-cli.php
```

### Passo 4: Responda as perguntas

```
Nome completo: Admin Sistema
Email: admin@grupoautocredcar.com.br
Senha: SenhaSegura123
Função:
  1. Admin (Administrador)
  2. Analyst (Analista)
  3. Client (Cliente)
Escolha (1-3): 1
Créditos iniciais [0]: 100
```

✅ Usuário criado!

---

## 🚀 Opção 3: Criar Admin Padrão (Rápido)

Se você já fez upload do `create-admin.php`, pode criar um admin padrão rapidamente:

### Dados do Admin Padrão:

- **Email:** `admin@admin.com`
- **Senha:** `admin123`
- **Função:** Admin
- **Créditos:** 0

### Como criar:

1. Acesse: `https://grupoautocredcar.com.br/vistoria/create-admin.php`
2. Preencha:
   - Nome: `Administrador`
   - Email: `admin@admin.com`
   - Senha: `admin123`
   - Função: `Administrador`
   - Créditos: `0`
3. Clique em "Criar Usuário"

---

## 📋 Tipos de Usuário

### 👑 Administrador (admin)
- Acesso total ao sistema
- Gerencia usuários
- Gerencia créditos
- Visualiza relatórios
- Aprova/reprova vistorias

**Ideal para:** Dono do sistema, gerente

### 📊 Analista (analyst)
- Visualiza todas as vistorias
- Aprova/reprova vistorias
- Gera relatórios de vistorias
- Acessa sistema de agregados

**Ideal para:** Vistoriador, técnico responsável

### 👤 Cliente (client)
- Solicita novas vistorias
- Visualiza suas próprias vistorias
- Baixa PDFs de vistorias aprovadas
- Compra créditos

**Ideal para:** Empresas que solicitam vistorias

---

## 💰 Sistema de Créditos

- **Preço por crédito:** R$ 25,00
- **1 crédito = 1 vistoria**
- Clientes precisam ter créditos para solicitar vistorias
- Admin pode adicionar créditos gratuitamente

### Como adicionar créditos:

**Via Admin Dashboard:**
1. Faça login como admin
2. Acesse: "Gerenciar Créditos"
3. Selecione o usuário
4. Adicione ou defina créditos

---

## 🔍 Verificar Usuários Criados

O script `create-admin.php` mostra automaticamente todos os usuários cadastrados quando você acessa a página.

**Ou via terminal:**

```bash
cd /home1/sist5700/sistema-vistoria
sqlite3 database/database.sqlite "SELECT id, name, email, role, credits FROM users;"
```

---

## ⚠️ Segurança

### Após criar os usuários:

1. **Delete o arquivo `create-admin.php`** do servidor (por segurança)
2. **Ou renomeie** para algo difícil de adivinhar:
   ```bash
   mv create-admin.php admin-x7k2p9.php
   ```
3. **Ou proteja** com senha via .htaccess

### Não deixe o arquivo acessível publicamente após criar os usuários!

---

## 🧪 Teste de Login

Após criar o usuário:

1. Acesse: `https://grupoautocredcar.com.br/vistoria/login`
2. Digite email e senha
3. Clique em "Entrar"
4. ✅ Deve redirecionar para o dashboard

---

## 🐛 Solução de Problemas

### Erro: "Email já cadastrado"
**Solução:** Use outro email ou delete o usuário existente via SQL

### Erro: "Tabela users não encontrada"
**Solução:** Execute as migrations:
```bash
php artisan migrate
```

### Erro: "Permission denied"
**Solução:** Verifique permissões do SQLite:
```bash
chmod 664 database/database.sqlite
```

### Usuário criado mas não consegue fazer login
**Solução:** 
1. Verifique se o `.env` está com `DB_CONNECTION=sqlite`
2. Verifique se `SESSION_DRIVER=file`
3. Limpe o cache: acesse `/vistoria/clear-cache.php`

---

## 📁 Arquivos Criados

```
➕ /vistoria/create-admin.php       - Interface web (RECOMENDADO)
➕ /create-admin-cli.php            - Comando terminal
➕ CREATE_ADMIN_GUIDE.md            - Este guia
```

---

## ✅ Checklist

Após criar o admin:

- [ ] Usuário criado com sucesso
- [ ] Login funciona
- [ ] Redirecionamento para dashboard funciona
- [ ] Pode acessar área administrativa
- [ ] Arquivo create-admin.php foi deletado/protegido

---

**Data:** 12 de novembro de 2025  
**Sistema:** Laravel 12.30.1 - Sistema de Vistoria
