# 🗂️ ESTRUTURA DE PASTAS - Sistema de Vistoria

## 📁 Sua Estrutura Atual

```
sist5700/
└── grupoautocredcar.com.br/          ← Laravel está AQUI
    ├── vendor/                        ← Autoload do Composer
    ├── bootstrap/
    ├── app/
    ├── database/
    ├── config/
    ├── .env
    └── vistoria/
        └── public/                    ← Pasta pública (onde vai index.php)
            ├── index.php
            └── auto-create-admin.php  ← Coloque AQUI!
```

## 🎯 Onde Colocar os Arquivos

### ✅ **Opção 1: Dentro de `vistoria/public/` (RECOMENDADO)**

Coloque o arquivo aqui:
```
/sist5700/grupoautocredcar.com.br/vistoria/public/auto-create-admin.php
```

Acesse:
```
https://grupoautocredcar.com.br/vistoria/public/auto-create-admin.php
```

### ✅ **Opção 2: Dentro de `vistoria/`**

Coloque o arquivo aqui:
```
/sist5700/grupoautocredcar.com.br/vistoria/auto-create-admin.php
```

Acesse:
```
https://grupoautocredcar.com.br/vistoria/auto-create-admin.php
```

## 🔧 O que o Script Faz

O script agora testa estes caminhos automaticamente:

1. **De `vistoria/public/`** → volta 2 níveis → `grupoautocredcar.com.br/`
2. **De `vistoria/`** → volta 1 nível → `grupoautocredcar.com.br/`

## 🧪 Teste com Debug

Se ainda der erro, faça upload do `debug-system.php` e acesse para ver exatamente qual caminho existe.

---

**Atualizado:** 13 de novembro de 2025
