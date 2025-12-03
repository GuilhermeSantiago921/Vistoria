# 🚀 GUIA COMPLETO: Corrigir e Fazer Upload para HostGator

## ⚠️ PROBLEMA IDENTIFICADO
A tabela `vehicles` no SQLite do HostGator não tem a coluna `user_id`.

---

## 📦 PASSO 1: Fazer Upload dos Arquivos Atualizados

### Arquivos que DEVEM ser enviados ao HostGator:

1. **`public/fix-vehicles-table.php`** (NOVO - script de correção)
2. **`public/test-upload.php`** (NOVO - teste de configurações)
3. **`public/.htaccess`** (ATUALIZADO - limites de upload)
4. **`app/Http/Controllers/InspectionController.php`** (ATUALIZADO - logs e validação)
5. **`resources/views/inspections/create.blade.php`** (ATUALIZADO - mensagens de erro)

### Como fazer o upload via File Manager do cPanel:

1. Acesse o **cPanel** do HostGator
2. Clique em **"File Manager"** (Gerenciador de Arquivos)
3. Navegue até: `/home1/sist5700/grupoautocredcar.com.br/vistoria/`
4. Faça upload dos arquivos para as respectivas pastas:
   - `fix-vehicles-table.php` → pasta `public/`
   - `test-upload.php` → pasta `public/`
   - `.htaccess` → pasta `public/`
   - `InspectionController.php` → pasta `app/Http/Controllers/`
   - `create.blade.php` → pasta `resources/views/inspections/`

---

## 🔧 PASSO 2: Executar o Script de Correção

### 2.1. Acesse o script no navegador:
```
https://grupoautocredcar.com.br/fix-vehicles-table.php
```

### 2.2. Você verá algo assim:
```
🔧 Corrigindo tabela vehicles...
📝 Adicionando coluna 'user_id'...
✅ Coluna 'user_id' adicionada com sucesso!
✅ Veículos existentes associados ao usuário padrão!

📋 Estrutura atual da tabela vehicles:
[Tabela mostrando todos os campos incluindo user_id]

🎉 Correção concluída!
```

### 2.3. IMPORTANTE: Apague o arquivo após execução
Após ver a mensagem de sucesso, apague o arquivo `public/fix-vehicles-table.php` por segurança.

---

## ✅ PASSO 3: Verificar Configurações de Upload

### 3.1. Acesse:
```
https://grupoautocredcar.com.br/test-upload.php
```

### 3.2. Verifique os valores:
- ✅ `upload_max_filesize`: deve ser **10M ou mais**
- ✅ `post_max_size`: deve ser **60M ou mais**
- ✅ `max_file_uploads`: deve ser **10 ou mais**

### 3.3. Se os valores estiverem BAIXOS:

**Opção A: Via .htaccess (já está configurado)**
O arquivo `.htaccess` que você enviou já tem as configurações. Se não funcionar, tente a Opção B.

**Opção B: Via cPanel - MultiPHP INI Editor**
1. No cPanel, procure **"MultiPHP INI Editor"** ou **"Select PHP Version"**
2. Selecione o modo **"Editor Mode"**
3. Ajuste os valores:
   ```
   upload_max_filesize = 10M
   post_max_size = 70M
   max_file_uploads = 20
   max_execution_time = 300
   max_input_time = 300
   memory_limit = 256M
   ```
4. Clique em **"Apply"** ou **"Salvar"**

---

## 🧪 PASSO 4: Testar o Envio de Vistoria

1. Acesse: `https://grupoautocredcar.com.br/login`
2. Faça login com seu usuário cliente
3. Clique em **"Nova Vistoria"**
4. Preencha:
   - **Placa**: `GCD6J50` ou `ABC-1234` (formato correto)
   - **10 Fotos**: Tire ou selecione todas as fotos
5. Clique em **"Enviar Vistoria"**

### O que deve acontecer:
- ✅ **Sucesso**: Mensagem verde "Vistoria enviada com sucesso!"
- ❌ **Erro**: Mensagem vermelha com detalhes do erro

---

## 🐛 PASSO 5: Se Continuar com Erro

### 5.1. Verificar Logs no HostGator

**Via File Manager:**
1. Navegue até: `/home1/sist5700/grupoautocredcar.com.br/vistoria/storage/logs/`
2. Abra o arquivo `laravel.log`
3. Role até o final do arquivo
4. Procure por:
   ```
   === INÍCIO STORE INSPECTION ===
   ```
5. Leia os logs para identificar o erro específico

**Via SSH (se tiver acesso):**
```bash
cd /home1/sist5700/grupoautocredcar.com.br/vistoria
tail -100 storage/logs/laravel.log
```

### 5.2. Erros Comuns e Soluções

**Erro: "Você não possui créditos suficientes"**
```
Solução: O admin precisa adicionar créditos via:
Admin Dashboard → Gerenciar Clientes → Adicionar Créditos
```

**Erro: "Todas as 10 fotos são obrigatórias"**
```
Solução: Certifique-se de selecionar TODAS as 10 fotos antes de enviar
```

**Erro: "O tamanho máximo permitido é 5MB por foto"**
```
Solução: 
1. Tire fotos em qualidade menor
2. OU reduza o limite no InspectionController.php de 5120 para 2048 (2MB)
```

**Erro: Formulário volta limpo sem mensagem**
```
Solução: Limite de post_max_size muito baixo
1. Verifique test-upload.php
2. Ajuste no MultiPHP INI Editor do cPanel
```

---

## 📝 CHECKLIST FINAL

Antes de testar, confirme:

- [ ] Arquivo `fix-vehicles-table.php` enviado para `public/`
- [ ] Executado `fix-vehicles-table.php` no navegador
- [ ] Viu mensagem "✅ Coluna 'user_id' adicionada com sucesso!"
- [ ] Arquivo `fix-vehicles-table.php` APAGADO após execução
- [ ] Arquivo `.htaccess` atualizado em `public/`
- [ ] Arquivo `InspectionController.php` atualizado
- [ ] Arquivo `create.blade.php` atualizado
- [ ] Verificado `test-upload.php` - valores adequados
- [ ] Usuário tem créditos (verificar no Admin Dashboard)

---

## 🆘 SUPORTE ADICIONAL

Se após todos esses passos ainda houver erro:

1. **Capture o erro exato** que aparece na tela
2. **Copie os últimos logs** do arquivo `storage/logs/laravel.log`
3. **Tire print** da página `test-upload.php`
4. **Me envie** essas informações para análise

---

## ⚡ RESUMO RÁPIDO

```bash
# 1. Enviar arquivos via File Manager do cPanel

# 2. Executar no navegador:
https://grupoautocredcar.com.br/fix-vehicles-table.php

# 3. Verificar configurações:
https://grupoautocredcar.com.br/test-upload.php

# 4. Ajustar limites no cPanel (se necessário):
MultiPHP INI Editor → post_max_size = 70M

# 5. Testar vistoria:
Login → Nova Vistoria → Preencher e Enviar

# 6. Se erro, verificar:
storage/logs/laravel.log
```

---

**BOA SORTE! 🚀**
