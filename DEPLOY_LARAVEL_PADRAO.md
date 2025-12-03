# 🚀 Deploy Laravel Padrão no HostGator

## 📋 Arquivos Essenciais que DEVEM estar no Servidor

Para o sistema Laravel funcionar com autenticação padrão, você precisa fazer upload destes arquivos:

### 1️⃣ Kernel HTTP (ESSENCIAL)
```
/home1/sist5700/sistema-vistoria/app/Http/Kernel.php
```

### 2️⃣ Middlewares (ESSENCIAIS - 11 arquivos)
```
/home1/sist5700/sistema-vistoria/app/Http/Middleware/
├── Authenticate.php
├── EncryptCookies.php
├── TrustProxies.php
├── VerifyCsrfToken.php
├── RedirectIfAuthenticated.php
├── PreventRequestsDuringMaintenance.php
├── TrimStrings.php
├── ValidateSignature.php
├── AdminMiddleware.php
├── AnalystMiddleware.php
└── CheckPaymentMiddleware.php
```

### 3️⃣ Index.php Atualizado
```
/home1/sist5700/grupoautocredcar.com.br/vistoria/index.php
```

### 4️⃣ Configuração de Ambiente
```
/home1/sist5700/sistema-vistoria/.env
```

---

## 📦 Estrutura Completa no HostGator

```
/home1/sist5700/
├── sistema-vistoria/              ← Laravel (PRIVADO)
│   ├── app/
│   │   └── Http/
│   │       ├── Kernel.php         ✅ FAZER UPLOAD
│   │       ├── Controllers/
│   │       └── Middleware/        ✅ FAZER UPLOAD (11 arquivos)
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   │   └── database.sqlite        ✅ Já existe
│   ├── routes/
│   ├── vendor/
│   └── .env                       ✅ Já existe
│
└── grupoautocredcar.com.br/
    └── vistoria/                  ← Público
        └── index.php              ✅ FAZER UPLOAD (atualizado)
```

---

## 🔧 Passo a Passo do Upload

### Opção A: Via cPanel File Manager

1. **Acesse o cPanel do HostGator**
2. **Abra o File Manager**

3. **Upload do Kernel.php:**
   - Navegue até: `/home1/sist5700/sistema-vistoria/app/Http/`
   - Faça upload de: `Kernel.php`

4. **Upload dos Middlewares:**
   - Navegue até: `/home1/sist5700/sistema-vistoria/app/Http/Middleware/`
   - Faça upload de TODOS os 11 arquivos .php da pasta Middleware

5. **Upload do index.php:**
   - Navegue até: `/home1/sist5700/grupoautocredcar.com.br/vistoria/`
   - Faça upload do `index.php` atualizado (sobrescrever o existente)

### Opção B: Via FTP

Use um cliente FTP como FileZilla:

1. **Conecte-se ao servidor:**
   - Host: ftp.grupoautocredcar.com.br
   - Usuário: sist5700
   - Porta: 21

2. **Upload dos arquivos:**
   ```
   Local → Remoto
   
   app/Http/Kernel.php 
   → /home1/sist5700/sistema-vistoria/app/Http/Kernel.php
   
   app/Http/Middleware/* 
   → /home1/sist5700/sistema-vistoria/app/Http/Middleware/
   
   public/index.php 
   → /home1/sist5700/grupoautocredcar.com.br/vistoria/index.php
   ```

---

## ✅ Checklist de Verificação

Antes de testar, confirme que estes arquivos existem no servidor:

- [ ] `/sistema-vistoria/app/Http/Kernel.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/Authenticate.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/EncryptCookies.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/TrustProxies.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/VerifyCsrfToken.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/RedirectIfAuthenticated.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/PreventRequestsDuringMaintenance.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/TrimStrings.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/ValidateSignature.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/AdminMiddleware.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/AnalystMiddleware.php`
- [ ] `/sistema-vistoria/app/Http/Middleware/CheckPaymentMiddleware.php`
- [ ] `/grupoautocredcar.com.br/vistoria/index.php` (versão atualizada)

---

## 🧪 Teste Após Upload

1. **Acesse a URL:**
   ```
   http://grupoautocredcar.com.br/vistoria/
   ```

2. **Deve redirecionar automaticamente para:**
   ```
   http://grupoautocredcar.com.br/vistoria/login
   ```

3. **Faça login com:**
   - Email: `admin@admin.com`
   - Senha: `admin123`

4. **Após login, deve ir para:**
   ```
   http://grupoautocredcar.com.br/vistoria/dashboard
   ```

---

## 🔍 Se Ainda Der Erro

### Erro: "Target class [App\Http\Kernel] does not exist"
**Solução:** O arquivo `Kernel.php` não foi uploadado corretamente
- Verifique se está em: `/sistema-vistoria/app/Http/Kernel.php`
- Verifique as permissões do arquivo (644)

### Erro: "Class 'App\Http\Middleware\...' not found"
**Solução:** Algum middleware está faltando
- Verifique se TODOS os 11 middlewares foram uploadados
- Verifique o caminho: `/sistema-vistoria/app/Http/Middleware/`

### Erro 500 sem mensagem
**Solução:** Ative debug temporariamente
1. Edite `.env` no servidor:
   ```
   APP_DEBUG=true
   ```
2. Recarregue a página para ver o erro completo
3. Depois volte para `APP_DEBUG=false`

### Erro: "Session store not set on request"
**Solução:** Limpe o cache da aplicação
```bash
# Via terminal SSH ou crie um arquivo clear.php:
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

---

## 📁 Lista de Arquivos Locais para Upload

Estes são os arquivos que você tem localmente e precisa fazer upload:

```
/Users/guilherme/Documents/vistoria/

├── index.php                                    → /vistoria/index.php
├── app/Http/Kernel.php                          → /sistema-vistoria/app/Http/Kernel.php
└── app/Http/Middleware/
    ├── Authenticate.php                         → /sistema-vistoria/app/Http/Middleware/
    ├── EncryptCookies.php                       → /sistema-vistoria/app/Http/Middleware/
    ├── TrustProxies.php                         → /sistema-vistoria/app/Http/Middleware/
    ├── VerifyCsrfToken.php                      → /sistema-vistoria/app/Http/Middleware/
    ├── RedirectIfAuthenticated.php              → /sistema-vistoria/app/Http/Middleware/
    ├── PreventRequestsDuringMaintenance.php     → /sistema-vistoria/app/Http/Middleware/
    ├── TrimStrings.php                          → /sistema-vistoria/app/Http/Middleware/
    ├── ValidateSignature.php                    → /sistema-vistoria/app/Http/Middleware/
    ├── AdminMiddleware.php                      → /sistema-vistoria/app/Http/Middleware/
    ├── AnalystMiddleware.php                    → /sistema-vistoria/app/Http/Middleware/
    └── CheckPaymentMiddleware.php               → /sistema-vistoria/app/Http/Middleware/
```

---

## 🎯 Resumo Executivo

**O que estava faltando:**
- ❌ Kernel.php não estava no servidor
- ❌ 11 arquivos de Middleware não estavam no servidor
- ❌ index.php estava redirecionando para simple-login

**O que foi corrigido:**
- ✅ index.php atualizado (sem redirecionamento)
- ✅ Removido try-catch que forçava simple-login
- ✅ Sistema pronto para usar autenticação Laravel padrão

**Próximo passo:**
- 📤 Fazer upload dos 13 arquivos listados acima
- 🧪 Testar acesso em: http://grupoautocredcar.com.br/vistoria/

---

**Após o upload, o sistema Laravel funcionará 100% com:**
- ✅ Rotas padrão do Laravel
- ✅ Autenticação Laravel (login/register)
- ✅ Middleware de proteção
- ✅ CSRF protection
- ✅ Sessions
- ✅ Todas as funcionalidades do sistema

---

**Data:** 12 de novembro de 2025  
**Status:** ✅ Código atualizado localmente - Aguardando upload no servidor
