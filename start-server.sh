#!/bin/bash
#
# Script de inicialização do servidor Laravel
# Sistema de Vistorias Veiculares
#
# Uso: ./start-server.sh
#

echo "🚀 Iniciando Sistema de Vistorias..."
echo ""
echo "📊 Configurações de Upload:"
echo "  - Tamanho máximo por foto: 5MB"
echo "  - Tamanho total do formulário: 35MB"
echo "  - Limite validado pelo Laravel: 30MB"
echo "  - Memória disponível: 256MB"
echo ""

# Para o servidor anterior se estiver rodando
echo "🛑 Parando servidores anteriores..."
pkill -9 -f "php.*artisan serve" 2>/dev/null
pkill -9 -f "php.*8000" 2>/dev/null
sleep 2

# Limpa caches do Laravel
php artisan config:clear --quiet
php artisan route:clear --quiet
php artisan view:clear --quiet

echo "✅ Caches limpos"
echo ""
echo "🌐 Iniciando servidor em http://localhost:8000"
echo ""

# Inicia o servidor com configurações customizadas
# Nota: max_execution_time=0 para o servidor não parar, mas requests limitados a 120s
php -d upload_max_filesize=5M \
    -d post_max_size=35M \
    -d memory_limit=256M \
    -d max_execution_time=0 \
    -d max_input_time=120 \
    artisan serve
