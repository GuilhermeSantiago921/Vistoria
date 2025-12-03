#!/bin/bash

# Script para empacotar arquivos necessários para deploy no HostGator
# Cria um arquivo ZIP com todos os arquivos que devem ser enviados

echo "📦 Empacotando arquivos para deploy no HostGator..."

# Criar diretório temporário
TEMP_DIR="deploy-hostgator"
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

# Criar estrutura de pastas
mkdir -p "$TEMP_DIR/vistoria"
mkdir -p "$TEMP_DIR/sistema-vistoria/app/Http/Middleware"
mkdir -p "$TEMP_DIR/sistema-vistoria/app/Http/Controllers"
mkdir -p "$TEMP_DIR/sistema-vistoria/config"
mkdir -p "$TEMP_DIR/sistema-vistoria/routes"
mkdir -p "$TEMP_DIR/sistema-vistoria/resources/views/auth"

echo "✅ Estrutura de pastas criada"

# Copiar index.php principal (SEM simple-login)
echo "📄 Copiando index.php atualizado..."
cp index.php "$TEMP_DIR/vistoria/index.php"

# Copiar Kernel.php (ESSENCIAL)
echo "📄 Copiando Kernel.php..."
cp app/Http/Kernel.php "$TEMP_DIR/sistema-vistoria/app/Http/Kernel.php"

# Copiar todos os Middlewares (ESSENCIAIS)
echo "📄 Copiando Middlewares..."
cp app/Http/Middleware/*.php "$TEMP_DIR/sistema-vistoria/app/Http/Middleware/"

# Copiar Controllers
echo "📄 Copiando Controllers..."
if [ -d "app/Http/Controllers" ]; then
    cp -r app/Http/Controllers/* "$TEMP_DIR/sistema-vistoria/app/Http/Controllers/"
fi

# Copiar rotas
echo "📄 Copiando rotas..."
cp routes/web.php "$TEMP_DIR/sistema-vistoria/routes/"
if [ -f "routes/auth.php" ]; then
    cp routes/auth.php "$TEMP_DIR/sistema-vistoria/routes/"
fi

# Copiar views de auth
echo "📄 Copiando views de autenticação..."
if [ -d "resources/views/auth" ]; then
    cp -r resources/views/auth/* "$TEMP_DIR/sistema-vistoria/resources/views/auth/"
fi

# Copiar arquivos de configuração importantes
echo "📄 Copiando configurações..."
cp config/app.php "$TEMP_DIR/sistema-vistoria/config/" 2>/dev/null || true
cp config/auth.php "$TEMP_DIR/sistema-vistoria/config/" 2>/dev/null || true
cp config/database.php "$TEMP_DIR/sistema-vistoria/config/" 2>/dev/null || true
cp config/session.php "$TEMP_DIR/sistema-vistoria/config/" 2>/dev/null || true

# Criar README com instruções
cat > "$TEMP_DIR/README.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║  INSTRUÇÕES DE DEPLOY - SISTEMA DE VISTORIA - HOSTGATOR    ║
╚══════════════════════════════════════════════════════════════╝

📦 CONTEÚDO DESTE PACOTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Este arquivo ZIP contém TODOS os arquivos necessários para 
fazer o sistema Laravel funcionar com autenticação padrão.

📂 ESTRUTURA DO PACOTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vistoria/
  └─ index.php              ← Atualizado (sem simple-login)

sistema-vistoria/
  ├─ app/Http/
  │   ├─ Kernel.php         ← ESSENCIAL!
  │   ├─ Middleware/        ← 11 arquivos essenciais
  │   └─ Controllers/       ← Controllers incluindo Auth
  ├─ config/                ← Configurações
  ├─ routes/                ← Rotas web e auth
  └─ resources/views/auth/  ← Views de login

🚀 COMO FAZER O DEPLOY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. ACESSE O CPANEL
   URL: https://grupoautocredcar.com.br:2083
   
2. ABRA O GERENCIADOR DE ARQUIVOS
   
3. FAÇA UPLOAD DOS ARQUIVOS:

   A) Arquivos em "vistoria/"
      - Navegue até: /home1/sist5700/grupoautocredcar.com.br/vistoria/
      - Faça upload de: vistoria/index.php
      - SUBSTITUA o arquivo existente
   
   B) Arquivos em "sistema-vistoria/"
      - Navegue até: /home1/sist5700/sistema-vistoria/
      - Faça upload de toda a estrutura de pastas
      - Mantenha a estrutura de diretórios

4. VERIFIQUE AS PERMISSÕES
   - Arquivos .php: 644
   - Pastas: 755

✅ TESTE O SISTEMA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Acesse: http://grupoautocredcar.com.br/vistoria/
   Resultado esperado: Redirecionamento para /login

2. Faça login com:
   Email: admin@admin.com
   Senha: admin123

3. Deve funcionar SEM erro 500!

⚠️ SE DER ERRO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Erro: "Target class [config] does not exist"
→ O Kernel.php não foi copiado. Verifique se está em:
  /home1/sist5700/sistema-vistoria/app/Http/Kernel.php

Erro: "Class 'App\Http\Middleware\...' not found"  
→ Os middlewares não foram copiados. Verifique se estão em:
  /home1/sist5700/sistema-vistoria/app/Http/Middleware/

Erro 500 genérico
→ Verifique os logs em:
  /home1/sist5700/sistema-vistoria/storage/logs/laravel.log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Data: 12 de novembro de 2025
Sistema: Laravel 12.30.1 - Sistema de Vistoria
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Contar arquivos
TOTAL_FILES=$(find "$TEMP_DIR" -type f | wc -l)
echo ""
echo "📊 Resumo:"
echo "   Total de arquivos: $TOTAL_FILES"
echo ""

# Criar arquivo ZIP
ZIP_FILE="deploy-hostgator-$(date +%Y%m%d-%H%M%S).zip"
echo "🗜️  Criando arquivo ZIP..."
cd "$TEMP_DIR"
zip -r "../$ZIP_FILE" . -q
cd ..

# Limpar diretório temporário
rm -rf "$TEMP_DIR"

echo ""
echo "✅ PRONTO!"
echo ""
echo "📦 Arquivo criado: $ZIP_FILE"
echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "   1. Faça download do arquivo: $ZIP_FILE"
echo "   2. Acesse o cPanel do HostGator"
echo "   3. Use o Gerenciador de Arquivos"
echo "   4. Faça upload e extraia o ZIP"
echo "   5. Copie os arquivos para as pastas corretas"
echo ""
echo "📖 Leia o arquivo README.txt dentro do ZIP para instruções detalhadas"
echo ""
