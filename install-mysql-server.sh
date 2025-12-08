#!/bin/bash

#######################################
# INSTALAÇÃO DO MYSQL SERVER
# Sistema de Vistoria Veicular
# Versão: 1.0
#######################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║    INSTALAÇÃO MYSQL SERVER - Sistema de Vistoria        ║"
echo "║              Banco de Dados Dedicado                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERRO] Por favor, execute como root (sudo)${NC}"
    exit 1
fi

# Detectar sistema operacional
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}[ERRO] Não foi possível detectar o sistema operacional${NC}"
    exit 1
fi

echo -e "${GREEN}[INFO] Sistema detectado: $OS${NC}"

#######################################
# PASSO 1: Coletar Informações
#######################################

echo -e "\n${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  CONFIGURAÇÃO DO BANCO DE DADOS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}\n"

# Senha root do MySQL
while true; do
    read -sp "Digite a senha para o usuário root do MySQL: " MYSQL_ROOT_PASSWORD
    echo
    read -sp "Confirme a senha: " MYSQL_ROOT_PASSWORD_CONFIRM
    echo
    if [ "$MYSQL_ROOT_PASSWORD" = "$MYSQL_ROOT_PASSWORD_CONFIRM" ]; then
        break
    else
        echo -e "${RED}[ERRO] As senhas não coincidem. Tente novamente.${NC}"
    fi
done

# Nome do banco
read -p "Nome do banco de dados [vistoria]: " DB_NAME
DB_NAME=${DB_NAME:-vistoria}

# Usuário do banco
read -p "Usuário do banco de dados [vistoria_user]: " DB_USER
DB_USER=${DB_USER:-vistoria_user}

# Senha do usuário
while true; do
    read -sp "Senha para o usuário '$DB_USER': " DB_PASSWORD
    echo
    read -sp "Confirme a senha: " DB_PASSWORD_CONFIRM
    echo
    if [ "$DB_PASSWORD" = "$DB_PASSWORD_CONFIRM" ]; then
        break
    else
        echo -e "${RED}[ERRO] As senhas não coincidem. Tente novamente.${NC}"
    fi
done

# IP do servidor de aplicação (para acesso remoto)
read -p "IP do servidor de aplicação (ou '%' para qualquer IP) [%]: " APP_SERVER_IP
APP_SERVER_IP=${APP_SERVER_IP:-%}

echo -e "\n${GREEN}[INFO] Configurações:${NC}"
echo "  - Banco de dados: $DB_NAME"
echo "  - Usuário: $DB_USER"
echo "  - Acesso remoto de: $APP_SERVER_IP"

read -p "Confirma estas configurações? (S/n): " CONFIRM
CONFIRM=${CONFIRM:-S}
if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then
    echo -e "${RED}[INFO] Instalação cancelada pelo usuário${NC}"
    exit 0
fi

#######################################
# PASSO 2: Instalar MySQL Server
#######################################

echo -e "\n${BLUE}[PASSO 2/6] Instalando MySQL Server...${NC}"

if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    # Ubuntu/Debian
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client
    
elif [[ "$OS" == "rocky" ]] || [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
    # Rocky Linux/CentOS
    dnf install -y mysql-server mysql
    systemctl enable mysqld
    systemctl start mysqld
else
    echo -e "${RED}[ERRO] Sistema operacional não suportado: $OS${NC}"
    exit 1
fi

echo -e "${GREEN}✓ MySQL Server instalado${NC}"

#######################################
# PASSO 3: Iniciar MySQL
#######################################

echo -e "\n${BLUE}[PASSO 3/6] Iniciando MySQL...${NC}"

systemctl start mysql 2>/dev/null || systemctl start mysqld 2>/dev/null || true
systemctl enable mysql 2>/dev/null || systemctl enable mysqld 2>/dev/null || true

# Aguardar MySQL iniciar
sleep 5

echo -e "${GREEN}✓ MySQL iniciado${NC}"

#######################################
# PASSO 4: Configurar Segurança
#######################################

echo -e "\n${BLUE}[PASSO 4/6] Configurando segurança do MySQL...${NC}"

# Configurar senha root
mysql -u root <<MYSQL_SECURE
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
MYSQL_SECURE

echo -e "${GREEN}✓ Segurança configurada${NC}"

#######################################
# PASSO 5: Criar Banco e Usuário
#######################################

echo -e "\n${BLUE}[PASSO 5/6] Criando banco de dados e usuário...${NC}"

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<MYSQL_SETUP
-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criar usuário e conceder privilégios
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'${APP_SERVER_IP}' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${APP_SERVER_IP}';

FLUSH PRIVILEGES;
MYSQL_SETUP

echo -e "${GREEN}✓ Banco '$DB_NAME' criado${NC}"
echo -e "${GREEN}✓ Usuário '$DB_USER' criado${NC}"

#######################################
# PASSO 6: Criar Tabelas
#######################################

echo -e "\n${BLUE}[PASSO 6/6] Criando tabelas do sistema...${NC}"

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" "${DB_NAME}" <<'MYSQL_TABLES'
-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'analyst', 'client') NOT NULL DEFAULT 'client',
    credits INT NOT NULL DEFAULT 0,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de veículos
CREATE TABLE IF NOT EXISTS vehicles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    placa VARCHAR(7) NOT NULL UNIQUE,
    marca VARCHAR(255) NULL,
    modelo VARCHAR(255) NULL,
    ano INT NULL,
    cor VARCHAR(100) NULL,
    chassi VARCHAR(17) NULL,
    renavam VARCHAR(11) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_placa (placa),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de vistorias
CREATE TABLE IF NOT EXISTS inspections (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    analyst_id BIGINT UNSIGNED NULL,
    status ENUM('pending', 'in_analysis', 'approved', 'disapproved') NOT NULL DEFAULT 'pending',
    inspection_date DATE NOT NULL,
    observations TEXT NULL,
    disapproval_reason TEXT NULL,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (analyst_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_user_id (user_id),
    INDEX idx_analyst_id (analyst_id),
    INDEX idx_inspection_date (inspection_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de detalhes da vistoria
CREATE TABLE IF NOT EXISTS inspection_details (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inspection_id BIGINT UNSIGNED NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    photo_number INT NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE CASCADE,
    INDEX idx_inspection_id (inspection_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de transações de créditos
CREATE TABLE IF NOT EXISTS credit_transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    amount INT NOT NULL,
    type ENUM('purchase', 'usage', 'refund', 'admin_adjustment') NOT NULL,
    description TEXT NULL,
    inspection_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (inspection_id) REFERENCES inspections(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de sessões
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de cache
CREATE TABLE IF NOT EXISTS cache (
    `key` VARCHAR(255) PRIMARY KEY,
    value MEDIUMTEXT NOT NULL,
    expiration INT NOT NULL,
    INDEX idx_expiration (expiration)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cache_locks (
    `key` VARCHAR(255) PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    expiration INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de jobs (filas)
CREATE TABLE IF NOT EXISTS jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    queue VARCHAR(255) NOT NULL,
    payload LONGTEXT NOT NULL,
    attempts TINYINT UNSIGNED NOT NULL,
    reserved_at INT UNSIGNED NULL,
    available_at INT UNSIGNED NOT NULL,
    created_at INT UNSIGNED NOT NULL,
    INDEX idx_queue (queue)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS job_batches (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    total_jobs INT NOT NULL,
    pending_jobs INT NOT NULL,
    failed_jobs INT NOT NULL,
    failed_job_ids LONGTEXT NOT NULL,
    options MEDIUMTEXT NULL,
    cancelled_at INT NULL,
    created_at INT NOT NULL,
    finished_at INT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS failed_jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    uuid VARCHAR(255) NOT NULL UNIQUE,
    connection TEXT NOT NULL,
    queue TEXT NOT NULL,
    payload LONGTEXT NOT NULL,
    exception LONGTEXT NOT NULL,
    failed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_uuid (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de password resets
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    email VARCHAR(255) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de migrations (controle de versão do banco)
CREATE TABLE IF NOT EXISTS migrations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    batch INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
MYSQL_TABLES

echo -e "${GREEN}✓ Todas as tabelas criadas${NC}"

#######################################
# PASSO 7: Configurar Acesso Remoto
#######################################

echo -e "\n${BLUE}[PASSO 7/7] Configurando acesso remoto...${NC}"

# Backup da configuração original
cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.backup 2>/dev/null || \
cp /etc/my.cnf /etc/my.cnf.backup 2>/dev/null || \
cp /etc/my.cnf.d/mysql-server.cnf /etc/my.cnf.d/mysql-server.cnf.backup 2>/dev/null || true

# Configurar bind-address para aceitar conexões remotas
if [ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]; then
    # Ubuntu/Debian
    sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
elif [ -f /etc/my.cnf ]; then
    # Rocky Linux/CentOS
    if ! grep -q "bind-address" /etc/my.cnf; then
        sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf
    else
        sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf
    fi
elif [ -f /etc/my.cnf.d/mysql-server.cnf ]; then
    if ! grep -q "bind-address" /etc/my.cnf.d/mysql-server.cnf; then
        sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mysql-server.cnf
    else
        sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mysql-server.cnf
    fi
fi

# Reiniciar MySQL
systemctl restart mysql 2>/dev/null || systemctl restart mysqld 2>/dev/null

echo -e "${GREEN}✓ Acesso remoto configurado${NC}"

#######################################
# PASSO 8: Configurar Firewall
#######################################

echo -e "\n${BLUE}[PASSO 8/8] Configurando firewall...${NC}"

# Detectar e configurar firewall
if command -v ufw &> /dev/null; then
    # Ubuntu/Debian com UFW
    ufw allow 3306/tcp
    echo -e "${GREEN}✓ Porta 3306 liberada no UFW${NC}"
elif command -v firewall-cmd &> /dev/null; then
    # Rocky Linux/CentOS com firewalld
    firewall-cmd --permanent --add-port=3306/tcp
    firewall-cmd --reload
    echo -e "${GREEN}✓ Porta 3306 liberada no firewalld${NC}"
else
    echo -e "${YELLOW}⚠ Firewall não detectado. Libere manualmente a porta 3306${NC}"
fi

#######################################
# RESUMO FINAL
#######################################

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          INSTALAÇÃO CONCLUÍDA COM SUCESSO!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}\n"

# Obter IP do servidor
SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  INFORMAÇÕES DE CONEXÃO${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}\n"

echo -e "${BLUE}Servidor MySQL:${NC} $SERVER_IP"
echo -e "${BLUE}Porta:${NC} 3306"
echo -e "${BLUE}Banco de dados:${NC} $DB_NAME"
echo -e "${BLUE}Usuário:${NC} $DB_USER"
echo -e "${BLUE}Senha:${NC} [a que você configurou]"

echo -e "\n${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  CONFIGURAÇÃO NO SERVIDOR DE APLICAÇÃO${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}\n"

echo "Adicione no arquivo .env do Laravel:"
echo ""
echo -e "${GREEN}DB_CONNECTION=mysql${NC}"
echo -e "${GREEN}DB_HOST=$SERVER_IP${NC}"
echo -e "${GREEN}DB_PORT=3306${NC}"
echo -e "${GREEN}DB_DATABASE=$DB_NAME${NC}"
echo -e "${GREEN}DB_USERNAME=$DB_USER${NC}"
echo -e "${GREEN}DB_PASSWORD=sua_senha_aqui${NC}"

echo -e "\n${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  TESTAR CONEXÃO${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}\n"

echo "Do servidor de aplicação, execute:"
echo ""
echo -e "${BLUE}mysql -h $SERVER_IP -u $DB_USER -p $DB_NAME${NC}"

echo -e "\n${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  COMANDOS ÚTEIS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}\n"

echo "Ver status do MySQL:"
echo -e "  ${BLUE}systemctl status mysql${NC} (Ubuntu/Debian)"
echo -e "  ${BLUE}systemctl status mysqld${NC} (Rocky/CentOS)"
echo ""
echo "Ver logs do MySQL:"
echo -e "  ${BLUE}tail -f /var/log/mysql/error.log${NC}"
echo ""
echo "Acessar MySQL como root:"
echo -e "  ${BLUE}mysql -u root -p${NC}"
echo ""
echo "Backup do banco:"
echo -e "  ${BLUE}mysqldump -u root -p $DB_NAME > backup.sql${NC}"

echo -e "\n${GREEN}✓ Banco de dados pronto para uso!${NC}\n"

# Salvar informações em arquivo
cat > ~/mysql-vistoria-config.txt <<EOF
═══════════════════════════════════════════
  CONFIGURAÇÃO MYSQL - SISTEMA DE VISTORIA
═══════════════════════════════════════════

Servidor: $SERVER_IP
Porta: 3306
Banco: $DB_NAME
Usuário: $DB_USER
Data: $(date)

Configuração .env:
DB_CONNECTION=mysql
DB_HOST=$SERVER_IP
DB_PORT=3306
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=[sua_senha]

Comando de teste:
mysql -h $SERVER_IP -u $DB_USER -p $DB_NAME
EOF

echo -e "${GREEN}✓ Configurações salvas em: ~/mysql-vistoria-config.txt${NC}\n"