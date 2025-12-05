# 🔧 Configuração do SQL Server Agregados

## 📋 Problema Identificado

As variáveis de ambiente `DB_AGREGADOS_*` não estavam configuradas no `.env`, causando erro:
```
The database configuration URL is malformed.
```

## ✅ Solução Aplicada

Adicionadas as seguintes variáveis ao `.env`:

```env
# SQL Server (Integração com Agregados)
DB_AGREGADOS_CONNECTION=sqlsrv
DB_AGREGADOS_HOST=SEU_HOST_AQUI          # Ex: 192.168.1.100 ou sql.dominio.com.br
DB_AGREGADOS_PORT=1433
DB_AGREGADOS_DATABASE=VeiculosAgregados
DB_AGREGADOS_USERNAME=SEU_USUARIO_AQUI   # Ex: sa ou usuario_sistema
DB_AGREGADOS_PASSWORD=SUA_SENHA_AQUI     # Ex: Prime@2024#
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
```

## 🔐 Preencher Credenciais

**IMPORTANTE:** Você precisa preencher com as credenciais reais do seu servidor SQL Server:

### 1. Editar .env

```bash
nano /Users/guilherme/Documents/vistoria/.env
```

### 2. Substituir os valores vazios:

```env
DB_AGREGADOS_HOST=192.168.1.100          # IP ou hostname do SQL Server
DB_AGREGADOS_USERNAME=sa                  # Usuário com acesso ao banco
DB_AGREGADOS_PASSWORD=Prime@2024#         # Senha do usuário
```

### 3. Limpar cache

```bash
php artisan config:clear
php artisan cache:clear
```

## 🧪 Testar Conexão

### Teste 1: Conexão Básica

```bash
php artisan tinker
```

Dentro do Tinker:
```php
try {
    $result = DB::connection('sqlsrv_agregados')->select('SELECT 1 as test');
    dump('✅ Conexão OK!', $result);
} catch (\Exception $e) {
    dump('❌ ERRO:', $e->getMessage());
}
```

### Teste 2: Buscar Dados de uma Placa

```php
$placa = 'ABC1234'; // Substitua por uma placa real do banco

try {
    $query = "
        SELECT TOP 1
            A.NR_Renavam,
            A.NR_Chassi,
            A.NR_Motor,
            C.NM_MarcaModelo,
            D.NM_Combustivel,
            I.NM_CorVeiculo,
            A.NR_AnoFabricacao,
            A.NR_AnoModelo
        FROM VeiculosAgregados.dbo.Agregados2020 A
        LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C ON TRY_CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
        LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D ON TRY_CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
        LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I ON TRY_CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
        WHERE A.NR_Placa = ?
    ";
    
    $resultado = DB::connection('sqlsrv_agregados')->select($query, [$placa]);
    
    if (!empty($resultado)) {
        dump('✅ Dados encontrados:', $resultado[0]);
    } else {
        dump('⚠️ Placa não encontrada no banco Agregados');
    }
} catch (\Exception $e) {
    dump('❌ ERRO ao buscar:', $e->getMessage());
}
```

## 🐛 Erros Comuns e Soluções

### 1. "could not find driver"

**Causa:** Extensão PHP SQL Server não instalada.

**Solução (macOS com Homebrew):**
```bash
# Instalar drivers SQL Server para PHP
pecl install sqlsrv
pecl install pdo_sqlsrv

# Adicionar ao php.ini
echo "extension=sqlsrv.so" >> $(php --ini | grep "Loaded Configuration" | cut -d: -f2 | xargs)
echo "extension=pdo_sqlsrv.so" >> $(php --ini | grep "Loaded Configuration" | cut -d: -f2 | xargs)

# Verificar
php -m | grep sqlsrv
# Deve mostrar: pdo_sqlsrv e sqlsrv
```

**Solução (Ubuntu/Debian):**
```bash
# Adicionar repositório Microsoft
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

apt-get update
ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
apt-get install -y php8.2-dev php8.2-sqlsrv

# Reiniciar PHP-FPM
systemctl restart php8.2-fpm
```

### 2. "Login failed for user"

**Causa:** Credenciais incorretas ou usuário sem permissão.

**Solução:**
- Verificar usuário e senha no SQL Server Management Studio
- Garantir que o usuário tem permissão de leitura no banco `VeiculosAgregados`
- Se usar autenticação Windows, configurar `Trusted_Connection=Yes`

### 3. "SSL Provider: The certificate chain was issued by an authority that is not trusted"

**Causa:** Certificado SSL não confiável.

**Solução (já aplicada):**
```env
DB_AGREGADOS_ENCRYPT=no
DB_AGREGADOS_TRUST_SERVER_CERTIFICATE=yes
```

### 4. "Cannot open database VeiculosAgregados"

**Causa:** Nome do banco incorreto ou usuário sem acesso.

**Solução:**
```sql
-- No SQL Server Management Studio, verificar:
USE master;
GO
SELECT name FROM sys.databases;
GO

-- Dar permissão ao usuário:
USE VeiculosAgregados;
GO
EXEC sp_addrolemember 'db_datareader', 'seu_usuario';
GO
```

### 5. "Named Pipes Provider: Could not open a connection"

**Causa:** Servidor inacessível (firewall, rede, serviço parado).

**Solução:**
```bash
# Testar conectividade de rede
ping 192.168.1.100

# Testar porta SQL Server (1433)
telnet 192.168.1.100 1433
# ou
nc -zv 192.168.1.100 1433

# Se falhar: verificar firewall no servidor SQL Server
# Windows: Permitir porta 1433 TCP no Firewall
# Linux: sudo ufw allow 1433/tcp
```

## 📊 Como Funciona a Integração

### Fluxo de Dados

1. **Cliente acessa:** `/vistoria/nova`
2. **Preenche placa:** Ex: `ABC1234`
3. **Laravel busca no Agregados:**
   ```php
   // InspectionController.php - linha 111-135
   $dados_agregados = DB::connection('sqlsrv_agregados')
       ->select($query, [$placa]);
   ```
4. **Auto-preenche campos:**
   - Chassi (VIN)
   - Motor
   - Marca/Modelo
   - Cor
   - Combustível
   - Ano fabricação/modelo

### Tabelas Consultadas

```
VeiculosAgregados
├── dbo.Agregados2020        (tabela principal)
├── dbo.TB_ModeloVeiculo     (join: marca/modelo)
├── dbo.TB_Combustivel       (join: tipo combustível)
└── dbo.TB_CorVeiculo        (join: cor)
```

### Query SQL Executada

```sql
SELECT TOP 1
    A.NR_Renavam,
    A.NR_Chassi,
    A.NR_Motor,
    C.NM_MarcaModelo,
    D.NM_Combustivel,
    I.NM_CorVeiculo,
    A.NR_AnoFabricacao,
    A.NR_AnoModelo
FROM VeiculosAgregados.dbo.Agregados2020 A
LEFT JOIN VeiculosAgregados.dbo.TB_ModeloVeiculo C 
    ON TRY_CAST(A.CD_MarcaModelo AS FLOAT) = C.CD_MarcaModelo
LEFT JOIN VeiculosAgregados.dbo.TB_Combustivel D 
    ON TRY_CAST(A.CD_Combustivel AS FLOAT) = D.CD_Combustivel
LEFT JOIN VeiculosAgregados.dbo.TB_CorVeiculo I 
    ON TRY_CAST(A.CD_CorVeiculo AS FLOAT) = I.CD_CorVeiculo
WHERE A.NR_Placa = ? OR A.NR_Placa = REPLACE(?, '-', '')
```

## 🔄 Próximos Passos

1. **Preencher credenciais** no `.env`
2. **Instalar driver SQL Server** (se necessário)
3. **Testar conexão** com os comandos acima
4. **Verificar logs:**
   ```bash
   tail -f storage/logs/laravel.log | grep agregados
   ```
5. **Testar no navegador:**
   - Acessar: http://localhost:8000/vistoria/nova
   - Preencher uma placa conhecida do banco Agregados
   - Verificar se os campos são auto-preenchidos

## 📞 Checklist de Troubleshooting

- [ ] Variáveis `DB_AGREGADOS_*` preenchidas no `.env`
- [ ] Driver `sqlsrv` instalado (`php -m | grep sqlsrv`)
- [ ] Servidor SQL Server acessível (ping + telnet porta 1433)
- [ ] Credenciais válidas (testar com SQL Server Management Studio)
- [ ] Banco `VeiculosAgregados` existe
- [ ] Usuário tem permissão de leitura
- [ ] Cache do Laravel limpo (`php artisan config:clear`)
- [ ] Teste no Tinker passou sem erros
- [ ] Logs verificados (`storage/logs/laravel.log`)

---

**Data:** 03/12/2025  
**Status:** Configuração adicionada, aguardando credenciais do cliente
