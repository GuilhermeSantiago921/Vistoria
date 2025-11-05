# Dockerfile

# Use uma imagem Debian estável, que tem o apt-get mais robusto
FROM php:8.3-fpm-bullseye

# Instalar dependências básicas
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    curl \
    unixodbc-dev \
    libsqlite3-dev \
    # Limpeza de cache
    && rm -rf /var/lib/apt/lists/*

# Configuração e Instalação do Driver SQL Server (MSODBCSQL17)
# Quebra dos comandos para evitar erros de Shell/Sintaxe
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools

# Instalar as extensões PHP (PECL)
RUN pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    docker-php-ext-enable sqlsrv pdo_sqlsrv

# Define o usuário e grupo padrão do Sail
# Adicione esta linha se você usou o sail:install
# RUN usermod -u 1000 sail