# Solução para Erro ao Enviar Vistoria no HostGator

## Problema
O formulário volta limpo sem enviar quando clica em "Enviar Vistoria".

## Causa Provável
Limitações de upload do HostGator (10 fotos de até 5MB cada = 50MB total).

## Soluções Implementadas

### 1. Arquivo `.htaccess` Atualizado
O arquivo `public/.htaccess` foi atualizado com:
```apache
php_value upload_max_filesize 10M
php_value post_max_size 70M
php_value max_execution_time 300
php_value max_input_time 300
php_value memory_limit 256M
```

### 2. Mensagens de Erro Visíveis
Adicionado no formulário para mostrar erros de validação.

### 3. Logs Detalhados
Adicionado logs em todo o processo para debug.

## Como Testar

### Passo 1: Verificar Configurações PHP
Acesse: `https://grupoautocredcar.com.br/test-upload.php`

Você deve ver:
- ✅ upload_max_filesize: 10M ou mais
- ✅ post_max_size: 60M ou mais  
- ✅ max_file_uploads: 10 ou mais

**Se aparecer valores menores**, você precisa ajustar no cPanel:

### Passo 2: Ajustar no cPanel (se necessário)

1. Acesse o **cPanel do HostGator**
2. Procure por **"Select PHP Version"** ou **"MultiPHP INI Editor"**
3. Ajuste os valores:
   - `upload_max_filesize`: **10M**
   - `post_max_size`: **70M**
   - `max_file_uploads`: **20**
   - `max_execution_time`: **300**
   - `memory_limit`: **256M**
4. Clique em **"Apply"** ou **"Salvar"**

### Passo 3: Testar Upload
1. Faça login como cliente em: `https://grupoautocredcar.com.br`
2. Vá em **"Nova Vistoria"**
3. Preencha a placa (formato: **ABC-1234** ou **ABC1D23**)
4. Tire/selecione as 10 fotos
5. Clique em **"Enviar Vistoria"**

**Observação**: Se aparecer mensagens de erro agora, elas serão exibidas no topo da página em vermelho.

### Passo 4: Verificar Logs
Acesse via SSH ou File Manager:
```bash
cat storage/logs/laravel.log | tail -100
```

Procure por:
- `=== INÍCIO STORE INSPECTION ===`
- `Validação passou com sucesso`
- `=== STORE CONCLUÍDO COM SUCESSO ===`

Se houver erro, aparecerá:
- `=== ERRO NO STORE ===`
- Detalhes do erro

## Problemas Comuns

### 1. "Todas as 10 fotos são obrigatórias"
- Certifique-se de selecionar TODAS as 10 fotos antes de enviar

### 2. "O tamanho máximo permitido é 5MB por foto"
- Reduza o tamanho das fotos ou use uma qualidade menor na câmera

### 3. "Formato de placa inválido"
- Use formato: **ABC-1234** (com hífen) ou **ABC1D23** (Mercosul)

### 4. "Você não possui créditos suficientes"
- Peça ao admin para adicionar créditos via:
  - Admin Dashboard → Gerenciar Clientes → Adicionar Créditos

### 5. Formulário volta limpo sem mensagem
- Provavelmente é limite de upload muito baixo
- Verifique `test-upload.php` e ajuste no cPanel

## Alternativa: Reduzir Tamanho das Fotos

Se o HostGator não permitir aumentar os limites, você pode reduzir o tamanho máximo aceito:

No arquivo `app/Http/Controllers/InspectionController.php`, linha ~50, mude:
```php
'front_photo' => 'required|image|mimes:jpeg,png,jpg|max:5120',  // 5MB
```

Para:
```php
'front_photo' => 'required|image|mimes:jpeg,png,jpg|max:2048',  // 2MB
```

E ajuste `post_max_size` para **30M** no `.htaccess`.

## Suporte

Se continuar com problemas:
1. Acesse `test-upload.php` e tire print das configurações
2. Acesse `storage/logs/laravel.log` e copie os últimos logs
3. Entre em contato com o suporte do HostGator se precisar aumentar limites
