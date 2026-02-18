#!/bin/bash

################################################################################
# DIAGNÓSTICO COMPLETO - SQL SERVER AGREGADOS
# Sistema de Vistoria Veicular
# Para executar em servidor Linux de produção
################################################################################

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Caminho do projeto (ajustar se necessário)
PROJECT_PATH="/var/www/vistoria"
cd "$PROJECT_PATH" || exit 1

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                            ║"
echo "║           DIAGNÓSTICO COMPLETO - SQL SERVER AGREGADOS                      ║"
echo "║                                                                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "Servidor: $(hostname)"
echo ""

# ============================================================================
# 1. VERIFICAR CONFIGURAÇÕES
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}1. VERIFICANDO CONFIGURAÇÕES DO .ENV${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ ! -f .env ]; then
    echo -e "${RED}✗ Arquivo .env não encontrado!${NC}"
    exit 1
fi

echo "Configurações SQL Server Agregados:"
echo "-----------------------------------"
grep "^DB_AGREGADOS" .env | sed 's/PASSWORD=.*/PASSWORD=***OCULTO***/'
echo ""

# ============================================================================
# 2. VERIFICAR EXTENSÕES PHP
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}2. VERIFICANDO EXTENSÕES PHP${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Versão do PHP:"
php -v | head -1
echo ""

echo "Extensões PDO instaladas:"
php -m | grep -i pdo
echo ""

if php -m | grep -qi "pdo_sqlsrv"; then
    echo -e "${GREEN}✓ pdo_sqlsrv INSTALADO${NC}"
    php -m | grep -i sqlsrv
else
    echo -e "${RED}✗ pdo_sqlsrv NÃO INSTALADO${NC}"
    echo ""
    echo "Para instalar no Ubuntu/Debian:"
    echo "  sudo apt-get install php8.2-dev php8.2-sqlsrv php8.2-pdo-sqlsrv"
    echo ""
    echo "Para instalar via PECL:"
    echo "  sudo pecl install sqlsrv pdo_sqlsrv"
    echo "  echo 'extension=pdo_sqlsrv.so' | sudo tee /etc/php/8.2/mods-available/pdo_sqlsrv.ini"
    echo "  sudo phpenmod pdo_sqlsrv"
    echo ""
fi
echo ""

# ============================================================================
# 3. VERIFICAR DRIVERS ODBC
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}3. VERIFICANDO DRIVERS ODBC SQL SERVER${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if command -v odbcinst &> /dev/null; then
    echo "Drivers ODBC instalados:"
    odbcinst -q -d | grep -i "SQL Server"
    echo ""
    
    if odbcinst -q -d | grep -qi "ODBC Driver"; then
        echo -e "${GREEN}✓ Driver ODBC SQL Server encontrado${NC}"
    else
        echo -e "${RED}✗ Driver ODBC SQL Server NÃO encontrado${NC}"
        echo ""
        echo "Para instalar:"
        echo "  curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
        echo "  curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list"
        echo "  sudo apt-get update"
        echo "  sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18"
    fi
else
    echo -e "${YELLOW}⚠ odbcinst não instalado${NC}"
fi
echo ""

# ============================================================================
# 4. LIMPAR CACHE
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}4. LIMPANDO CACHE DA APLICAÇÃO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

php artisan config:clear
php artisan cache:clear
echo -e "${GREEN}✓ Cache limpo${NC}"
echo ""

# ============================================================================
# 5. TESTAR CONEXÃO
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}5. TESTANDO CONEXÃO COM SQL SERVER${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Tentando conectar..."
php artisan tinker --execute="
try {
    echo '→ Obtendo PDO...' . PHP_EOL;
    \$pdo = DB::connection('sqlsrv_agregados')->getPdo();
    echo '${GREEN}✓ CONEXÃO ESTABELECIDA COM SUCESSO!${NC}' . PHP_EOL;
    echo '' . PHP_EOL;
    echo 'Informações da conexão:' . PHP_EOL;
    echo '  Driver: ' . \$pdo->getAttribute(PDO::ATTR_DRIVER_NAME) . PHP_EOL;
    echo '  Servidor: ' . config('database.connections.sqlsrv_agregados.host') . PHP_EOL;
    echo '  Porta: ' . config('database.connections.sqlsrv_agregados.port') . PHP_EOL;
    echo '  Database: ' . config('database.connections.sqlsrv_agregados.database') . PHP_EOL;
    echo '  Username: ' . config('database.connections.sqlsrv_agregados.username') . PHP_EOL;
} catch (\Exception \$e) {
    echo '${RED}✗ ERRO NA CONEXÃO${NC}' . PHP_EOL;
    echo '' . PHP_EOL;
    echo 'Mensagem: ' . \$e->getMessage() . PHP_EOL;
    echo 'Código: ' . \$e->getCode() . PHP_EOL;
    echo 'Arquivo: ' . \$e->getFile() . ':' . \$e->getLine() . PHP_EOL;
}
"
echo ""

# ============================================================================
# 6. TESTAR QUERY SIMPLES
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}6. TESTANDO QUERY SIMPLES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

php artisan tinker --execute="
try {
    echo '→ Executando SELECT 1...' . PHP_EOL;
    \$result = DB::connection('sqlsrv_agregados')->select('SELECT 1 as test');
    echo '${GREEN}✓ QUERY EXECUTADA COM SUCESSO!${NC}' . PHP_EOL;
    echo 'Resultado: ' . json_encode(\$result) . PHP_EOL;
} catch (\Exception \$e) {
    echo '${RED}✗ ERRO NA QUERY${NC}' . PHP_EOL;
    echo 'Mensagem: ' . \$e->getMessage() . PHP_EOL;
}
"
echo ""

# ============================================================================
# 7. TESTAR QUERY REAL (Agregados)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}7. TESTANDO QUERY REAL NA TABELA AGREGADOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Digite uma placa para testar (ex: ABC1234) ou pressione Enter para pular:"
read -r PLACA_TESTE

if [ -n "$PLACA_TESTE" ]; then
    PLACA_TESTE=$(echo "$PLACA_TESTE" | tr '[:lower:]' '[:upper:]' | sed 's/-//g')
    echo ""
    echo "Buscando placa: $PLACA_TESTE"
    
    php artisan tinker --execute="
try {
    \$placa = '$PLACA_TESTE';
    echo '→ Consultando banco Agregados2020...' . PHP_EOL;
    
    \$query = \"
        SELECT TOP 1
            A.NR_Chassi, A.NR_Motor, A.NR_AnoFabricacao, A.NR_AnoModelo,
            C.NM_MarcaModelo,
            I.NM_CorVeiculo,
            D.NM_Combustivel
        FROM VeiculosAgregados.dbo.Agregados2020 A
        LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C ON TRY_CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
        LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D ON TRY_CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
        LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I ON TRY_CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
        WHERE (A.NR_PlacaModeloAntigo = ? OR A.NR_PlacaModeloNovo = ?)
        AND A.NR_AnoFabricacao IS NOT NULL
    \";
    
    \$resultado = DB::connection('sqlsrv_agregados')->select(\$query, [\$placa, \$placa]);
    
    if (!empty(\$resultado)) {
        echo '${GREEN}✓ DADOS ENCONTRADOS!${NC}' . PHP_EOL;
        echo '' . PHP_EOL;
        \$dados = (array) \$resultado[0];
        echo 'Placa: ' . \$placa . PHP_EOL;
        echo 'Chassi: ' . (\$dados['NR_Chassi'] ?? 'N/A') . PHP_EOL;
        echo 'Motor: ' . (\$dados['NR_Motor'] ?? 'N/A') . PHP_EOL;
        echo 'Marca/Modelo: ' . (\$dados['NM_MarcaModelo'] ?? 'N/A') . PHP_EOL;
        echo 'Cor: ' . (\$dados['NM_CorVeiculo'] ?? 'N/A') . PHP_EOL;
        echo 'Combustível: ' . (\$dados['NM_Combustivel'] ?? 'N/A') . PHP_EOL;
        echo 'Ano Fabricação: ' . (\$dados['NR_AnoFabricacao'] ?? 'N/A') . PHP_EOL;
    } else {
        echo '${YELLOW}⚠ NENHUM DADO ENCONTRADO PARA ESTA PLACA${NC}' . PHP_EOL;
    }
} catch (\Exception \$e) {
    echo '${RED}✗ ERRO NA CONSULTA${NC}' . PHP_EOL;
    echo 'Mensagem: ' . \$e->getMessage() . PHP_EOL;
    echo 'SQL: ' . (\$e->getSql() ?? 'N/A') . PHP_EOL;
}
"
else
    echo "Teste de placa pulado."
fi
echo ""

# ============================================================================
# 8. MOSTRAR LOGS RECENTES
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}8. ÚLTIMOS LOGS DA APLICAÇÃO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

if [ -f storage/logs/laravel.log ]; then
    echo "Últimas 50 linhas do log:"
    echo "------------------------"
    tail -50 storage/logs/laravel.log
    echo ""
    
    echo "Erros relacionados a SQL Server/Agregados:"
    echo "-------------------------------------------"
    grep -i "sqlsrv\|agregados\|sql server\|pdo" storage/logs/laravel.log | tail -20
else
    echo -e "${YELLOW}⚠ Arquivo de log não encontrado${NC}"
fi
echo ""

# ============================================================================
# 9. TESTAR ROTA HTTP
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}9. TESTANDO ROTA DE DIAGNÓSTICO${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Testando rota /test-db-connection..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/test-db-connection 2>/dev/null || echo "ERRO")

if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ Rota acessível (HTTP 200)${NC}"
    curl -s http://localhost/test-db-connection | jq . 2>/dev/null || curl -s http://localhost/test-db-connection
elif [ "$RESPONSE" = "ERRO" ]; then
    echo -e "${YELLOW}⚠ curl não disponível ou erro na requisição${NC}"
else
    echo -e "${YELLOW}⚠ Rota retornou HTTP $RESPONSE${NC}"
fi
echo ""

# ============================================================================
# 10. RESUMO E RECOMENDAÇÕES
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}10. RESUMO E RECOMENDAÇÕES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""

echo "CHECKLIST:"
echo "----------"

# Verificar extensão
if php -m | grep -qi "pdo_sqlsrv"; then
    echo -e "[${GREEN}✓${NC}] Extensão pdo_sqlsrv instalada"
else
    echo -e "[${RED}✗${NC}] Extensão pdo_sqlsrv NÃO instalada"
fi

# Verificar driver ODBC
if command -v odbcinst &> /dev/null && odbcinst -q -d | grep -qi "ODBC Driver"; then
    echo -e "[${GREEN}✓${NC}] Driver ODBC SQL Server instalado"
else
    echo -e "[${RED}✗${NC}] Driver ODBC SQL Server NÃO instalado"
fi

# Verificar .env
if grep -q "^DB_AGREGADOS_HOST=.\+$" .env; then
    echo -e "[${GREEN}✓${NC}] Credenciais configuradas no .env"
else
    echo -e "[${RED}✗${NC}] Credenciais VAZIAS no .env"
fi

echo ""
echo "PRÓXIMOS PASSOS:"
echo "----------------"
echo "1. Se houver erros, verificar logs acima"
echo "2. Instalar extensões faltantes (se necessário)"
echo "3. Verificar firewall/conectividade com servidor SQL"
echo "4. Testar criação de vistoria real no sistema"
echo ""

echo "═══════════════════════════════════════════════════════════════════════════"
echo "Diagnóstico concluído em $(date '+%d/%m/%Y %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

# Salvar log em arquivo
LOG_FILE="diagnostico_sqlserver_$(date +%Y%m%d_%H%M%S).log"
echo "Salvando resultado em: $LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1
