# Dockerfile

# Use uma imagem Debian estável, que tem o apt-get mais robusto
FROM php:8.3-fpm-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instala utilitários, dependências de build e runtime necessários
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    gnupg2 \
    dirmngr \
    lsb-release \
    wget \
    curl \
    build-essential \
    autoconf \
    pkg-config \
    make \
    g++ \
    unixodbc-dev \
    libsqlite3-dev \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Adiciona chave Microsoft de forma não-depreciada e repositório (usa signed-by)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update

# Instala o driver ODBC da Microsoft (msodbcsql17) e as ferramentas mssql-tools (sqlcmd)
RUN ACCEPT_EULA=Y apt-get update \
 && ACCEPT_EULA=Y apt-get install -y --no-install-recommends \
    msodbcsql17 \
    mssql-tools \
 && ln -s /opt/mssql-tools/bin/* /usr/local/bin/ || true \
 && rm -rf /var/lib/apt/lists/*

# Instala extensões PHP via PECL
RUN pecl install sqlsrv pdo_sqlsrv \
 && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Instala e compila pdo_mysql (usa as headers instaladas acima)
RUN docker-php-ext-install pdo_mysql

# Limpeza: remover apenas pacotes de build; garantir que runtime ODBC permaneça
RUN apt-get purge -y build-essential autoconf pkg-config make g++ default-libmysqlclient-dev \
 && apt-get update \
 && apt-get install -y --no-install-recommends unixodbc libodbc1 odbcinst \
 && rm -rf /var/lib/apt/lists/*

# Define o usuário e grupo padrão do Sail (descomente se necessário)
# RUN usermod -u 1000 sail