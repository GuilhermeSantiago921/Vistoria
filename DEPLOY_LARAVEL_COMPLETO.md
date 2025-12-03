# 🚀 Deploy Completo Laravel - HostGator

## 📋 Arquivos que DEVEM estar no servidor

Para o Laravel funcionar com autenticação padrão, você precisa fazer upload destes arquivos:

### 1️⃣ Arquivo Principal de Entrada
```
/home1/sist5700/grupoautocredcar.com.br/vistoria/index.php
```
**Status:** ✅ Atualizado (sem redirecionamento para simple-login)

---

### 2️⃣ HTTP Kernel (ESSENCIAL)
```
/home1/sist5700/sistema-vistoria/app/Http/Kernel.php
```
**Por que é necessário:** Este arquivo é o coração do sistema de rotas do Laravel. Sem ele, você vê erro "Target class [config] does not exist".

**Caminho local:** `/Users/guilherme/Documents/vistoria/app/Http/Kernel.php`

---

### 3️⃣ Middlewares (ESSENCIAIS - 11 arquivos)

Faça upload de TODOS estes arquivos para:
```
/home1/sist5700/sistema-vistoria/app/Http/Middleware/
```

#### Middlewares Core do Laravel:
1. **Authenticate.php** - Verificação de autenticação
2. **EncryptCookies.php** - Criptografia de cookies
3. **PreventRequestsDuringMaintenance.php** - Modo manutenção
4. **RedirectIfAuthenticated.php** - Redirecionamento se já autenticado
5. **TrimStrings.php** - Limpeza de strings
6. **TrustProxies.php** - Confiança em proxies
7. **ValidateSignature.php** - Validação de assinaturas
8. **VerifyCsrfToken.php** - Proteção CSRF

#### Middlewares Customizados:
9. **AdminMiddleware.php** - Verificação de admin
10. **AnalystMiddleware.php** - Verificação de analista
11. **CheckPaymentMiddleware.php** - Verificação de pagamento/créditos

**Caminho local:** `/Users/guilherme/Documents/vistoria/app/Http/Middleware/`

---

### 4️⃣ Configurações

Certifique-se que estes arquivos existem em:
```
/home1/sist5700/sistema-vistoria/config/
```

- ✅ `app.php`
- ✅ `auth.php`
- ✅ `database.php`
- ✅ `session.php`

---

### 5️⃣ Rotas

Certifique-se que estes arquivos existem em:
```
/home1/sist5700/sistema-vistoria/routes/
```

- ✅ `web.php` - Rotas web principais
- ✅ `auth.php` - Rotas de autenticação

---

### 6️⃣ Controllers

Verifique se os controllers de autenticação existem:
```
/home1/sist5700/sistema-vistoria/app/Http/Controllers/Auth/
```

---

### 7️⃣ Views de Autenticação

Certifique-se que existem em:
```
/home1/sist5700/sistema-vistoria/resources/views/auth/
```

- `login.blade.php`
- `register.blade.php`
- `forgot-password.blade.php`
- etc.

---

## 📦 Checklist de Upload para HostGator

Use este checklist ao fazer upload via FTP/cPanel:

### Arquivos Críticos (SEM ESTES, NÃO FUNCIONA):

- [ ] **index.php** atualizado
  - De: `/Users/guilherme/Documents/vistoria/index.php`
  - Para: `/home1/sist5700/grupoautocredcar.com.br/vistoria/index.php`

- [ ] **Kernel.php**
  - De: `/Users/guilherme/Documents/vistoria/app/Http/Kernel.php`
  - Para: `/home1/sist5700/sistema-vistoria/app/Http/Kernel.php`

- [ ] **Pasta completa de Middlewares** (11 arquivos)
  - De: `/Users/guilherme/Documents/vistoria/app/Http/Middleware/`
  - Para: `/home1/sist5700/sistema-vistoria/app/Http/Middleware/`

### Arquivos Complementares:

- [ ] Controllers de Auth
  - De: `/Users/guilherme/Documents/vistoria/app/Http/Controllers/`
  - Para: `/home1/sist5700/sistema-vistoria/app/Http/Controllers/`

- [ ] Views de Auth
  - De: `/Users/guilherme/Documents/vistoria/resources/views/auth/`
  - Para: `/home1/sist5700/sistema-vistoria/resources/views/auth/`

- [ ] Rotas
  - De: `/Users/guilherme/Documents/vistoria/routes/`
  - Para: `/home1/sist5700/sistema-vistoria/routes/`

---

## 🔧 Como Fazer Upload via cPanel

### Opção 1: Gerenciador de Arquivos do cPanel

1. **Login no cPanel**
   - Acesse: https://grupoautocredcar.com.br:2083
   - Entre com suas credenciais

2. **Abra o Gerenciador de Arquivos**
   - Procure por "Gerenciador de Arquivos" ou "File Manager"

3. **Navegue até a pasta correta:**
   - Para index.php: `/home1/sist5700/grupoautocredcar.com.br/vistoria/`
   - Para outros arquivos: `/home1/sist5700/sistema-vistoria/`

4. **Upload dos arquivos:**
   - Clique em "Upload" no topo
   - Arraste os arquivos
   - Aguarde o upload completar

5. **Verificar permissões:**
   - Clique com botão direito nos arquivos
   - "Change Permissions" ou "Alterar Permissões"
   - Defina como 644 para arquivos PHP

### Opção 2: FTP (FileZilla)

1. **Conecte via FTP:**
   - Host: `ftp.grupoautocredcar.com.br`
   - Usuário: (seu usuário cPanel)
   - Senha: (sua senha cPanel)
   - Porta: 21

2. **Navegue até as pastas corretas** no painel direito

3. **Arraste os arquivos** do painel esquerdo (local) para direito (servidor)

---

## 🧪 Teste Após Upload

### 1. Teste de Rota Raiz
```
http://grupoautocredcar.com.br/vistoria/
```
**Resultado esperado:** Redirecionamento automático para `/login`

### 2. Teste de Login
```
http://grupoautocredcar.com.br/vistoria/login
```
**Resultado esperado:** Tela de login do Laravel (Blade template)

### 3. Teste de Autenticação
- Email: `admin@admin.com`
- Senha: `admin123`

**Resultado esperado:** Login bem-sucedido e redirecionamento para dashboard

---

## 🐛 Troubleshooting

### Erro: "Target class [config] does not exist"
**Causa:** `Kernel.php` não está no servidor  
**Solução:** Faça upload do arquivo `app/Http/Kernel.php`

### Erro: "Class 'App\Http\Middleware\...' not found"
**Causa:** Middlewares não estão no servidor  
**Solução:** Faça upload de toda pasta `app/Http/Middleware/`

### Erro 500 após upload
**Causa:** Permissões incorretas ou arquivo corrompido  
**Solução:** 
1. Verifique permissões (644 para arquivos, 755 para pastas)
2. Re-faça upload em modo ASCII/texto para arquivos PHP

### Página em branco
**Causa:** Erro de sintaxe ou caminho errado  
**Solução:** 
1. Verifique logs em `/home1/sist5700/sistema-vistoria/storage/logs/`
2. Use script de debug: `http://grupoautocredcar.com.br/vistoria/test-final.php`

---

## 📁 Estrutura Final no Servidor

```
/home1/sist5700/
├── grupoautocredcar.com.br/
│   └── vistoria/                    ← PASTA PÚBLICA
│       ├── index.php               ← ATUALIZADO (SEM SIMPLE-LOGIN)
│       ├── debug-session.php
│       ├── test-final.php
│       └── storage/ (link)
│
└── sistema-vistoria/               ← PASTA PRIVADA (LARAVEL)
    ├── app/
    │   └── Http/
    │       ├── Kernel.php          ← ESSENCIAL!
    │       ├── Controllers/
    │       └── Middleware/         ← 11 ARQUIVOS ESSENCIAIS!
    │           ├── Authenticate.php
    │           ├── EncryptCookies.php
    │           ├── PreventRequestsDuringMaintenance.php
    │           ├── RedirectIfAuthenticated.php
    │           ├── TrimStrings.php
    │           ├── TrustProxies.php
    │           ├── ValidateSignature.php
    │           ├── VerifyCsrfToken.php
    │           ├── AdminMiddleware.php
    │           ├── AnalystMiddleware.php
    │           └── CheckPaymentMiddleware.php
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── resources/
    │   └── views/
    │       └── auth/               ← VIEWS DE LOGIN
    ├── routes/
    │   ├── web.php
    │   └── auth.php
    ├── storage/
    └── vendor/
```

---

## ✅ Validação Final

Após fazer todos os uploads, execute estes testes:

1. [ ] `http://grupoautocredcar.com.br/vistoria/` redireciona para login
2. [ ] `http://grupoautocredcar.com.br/vistoria/login` mostra tela de login
3. [ ] Login funciona com credenciais corretas
4. [ ] Logout funciona
5. [ ] Re-login funciona
6. [ ] Middleware admin funciona
7. [ ] Sistema de créditos acessível
8. [ ] Sem erros 500 ou "Target class"

---

## 💡 Dica Importante

**SEMPRE faça backup antes de fazer upload!**

```bash
# No servidor, via SSH:
cd /home1/sist5700/sistema-vistoria
tar -czf backup-$(date +%Y%m%d).tar.gz app/
```

---

**Data:** 12 de novembro de 2025  
**Status:** 📦 Pronto para deploy - Upload dos arquivos necessários
