# Dockerfile - Vistoria Veicular
# Laravel 12 + MySQL + Redis + MailHog

FROM php:8.2-cli-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    curl \
    wget \
    git \
    zip \
    unzip \
    mysql-client \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    nodejs \
    npm \
    supervisor \
    icu-dev

# Install PHP extensions
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        gd \
        bcmath \
        ctype \
        fileinfo \
        json \
        tokenizer \
        xml \
        intl

# Install PECL extensions
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --optimize-autoloader

# Install Node dependencies
RUN npm install

# Create necessary directories
RUN mkdir -p \
    storage/logs \
    storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache \
    bootstrap/cache \
    public/storage

# Build assets
RUN npm run build || true

# Copy .env.example to .env if doesn't exist
RUN [ ! -f .env ] && cp .env.example .env || true

# Generate app key
RUN php artisan key:generate --force

# Expose port
EXPOSE 8000

# Start Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
