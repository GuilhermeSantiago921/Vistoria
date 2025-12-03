# 🖼️ Solução: Imagens 404 nas Vistorias

## 🔍 Problema
As fotos das vistorias não aparecem e geram erro 404 quando o analista tenta visualizar.

## 🎯 Causa
O Laravel salva as fotos em `storage/app/public/` mas precisa de um **link simbólico** em `public/storage/` para que sejam acessíveis via web.

---

## ✅ SOLUÇÃO 1: Via Script PHP (Mais Fácil)

### 1. Enviar arquivo
Envie o arquivo `fix-storage-link.php` para a pasta `public/` do HostGator

### 2. Executar no navegador
```
https://grupoautocredcar.com.br/fix-storage-link.php
```

### 3. Verificar resultado
Você verá:
```
✅ Link simbólico criado com sucesso!
```

### 4. Testar
Acesse uma foto diretamente:
```
https://grupoautocredcar.com.br/storage/inspections/1/frente-do-veiculo.jpg
```

Se a foto aparecer = **SUCESSO!** ✅

### 5. Apagar o arquivo
Delete `public/fix-storage-link.php` após executar.

---

## ✅ SOLUÇÃO 2: Via Terminal SSH (Mais Confiável)

Se a Solução 1 não funcionar, use o Terminal:

### 1. Acessar Terminal
No **cPanel do HostGator**:
- Procure por **"Terminal"** ou **"SSH Access"**
- Clique para abrir

### 2. Executar comandos
```bash
# Navegar até a pasta public
cd /home1/sist5700/grupoautocredcar.com.br/vistoria/public

# Remover storage antigo (se existir)
rm -rf storage

# Criar link simbólico
ln -s ../storage/app/public storage

# Verificar se funcionou
ls -la storage
```

Você deve ver algo como:
```
lrwxrwxrwx ... storage -> ../storage/app/public
```

### 3. Testar
Acesse:
```
https://grupoautocredcar.com.br/storage/inspections/1/frente-do-veiculo.jpg
```

---

## ✅ SOLUÇÃO 3: Via File Manager (Alternativa)

Se não tiver acesso ao Terminal:

### 1. Acessar File Manager
No cPanel → File Manager

### 2. Navegar para
```
/home1/sist5700/grupoautocredcar.com.br/vistoria/public/
```

### 3. Verificar se existe pasta "storage"
- Se existir, **delete** ela
- Se for um link, **delete** também

### 4. Criar link via PHP
Crie um arquivo `create-link.php` em `public/`:
```php
<?php
symlink('../storage/app/public', 'storage');
echo "Link criado!";
?>
```

### 5. Executar
Acesse: `https://grupoautocredcar.com.br/create-link.php`

### 6. Apagar
Delete `create-link.php` após executar

---

## 🧪 Como Testar se Funcionou

### Teste 1: Acessar foto diretamente
```
https://grupoautocredcar.com.br/storage/inspections/1/frente-do-veiculo.jpg
```
**Deve mostrar**: A imagem da vistoria  
**Se mostrar 404**: Link ainda não está funcionando

### Teste 2: Ver vistoria como analista
1. Login como analista
2. Ir em "Todas as Vistorias"
3. Clicar em uma vistoria
4. As 10 fotos devem aparecer

---

## 📁 Estrutura de Pastas Correta

```
vistoria/
├── public/
│   ├── index.php
│   └── storage/  ← LINK SIMBÓLICO apontando para ↓
│
└── storage/
    └── app/
        └── public/  ← ONDE AS FOTOS ESTÃO REALMENTE
            └── inspections/
                ├── 1/
                │   ├── frente-do-veiculo.jpg
                │   ├── traseira-do-veiculo.jpg
                │   └── ...
                ├── 2/
                └── ...
```

---

## ⚠️ Problemas Comuns

### Erro: "Permission denied"
**Solução**: Use o Terminal SSH (Solução 2)

### Erro: "symlink() has been disabled"
**Solução**: Entre em contato com suporte HostGator para habilitar `symlink()`

### Fotos ainda dão 404
**Verifique**:
1. O link existe? `ls -la public/storage`
2. As fotos existem? `ls -la storage/app/public/inspections/`
3. Permissões corretas? `chmod 755 storage/app/public -R`

---

## 🆘 Se Nada Funcionar

### Última alternativa: Mudar local de salvamento

Edite `config/filesystems.php`:

**Antes:**
```php
'public' => [
    'driver' => 'local',
    'root' => storage_path('app/public'),
    'url' => env('APP_URL').'/storage',
    'visibility' => 'public',
],
```

**Depois:**
```php
'public' => [
    'driver' => 'local',
    'root' => public_path('uploads'),  // Salvar direto em public/uploads
    'url' => env('APP_URL').'/uploads',
    'visibility' => 'public',
],
```

Depois crie a pasta:
```bash
mkdir public/uploads
chmod 755 public/uploads
```

**Mas prefira usar o link simbólico (Soluções 1 ou 2)!**

---

## ✅ Checklist Final

- [ ] Executado `fix-storage-link.php` OU comandos SSH
- [ ] Link `public/storage` aponta para `../storage/app/public`
- [ ] Foto de teste abre no navegador
- [ ] Analista consegue ver todas as 10 fotos
- [ ] Arquivo `fix-storage-link.php` foi apagado

---

**Boa sorte! 🚀**
