# STAGE 1: Build Frontend Assets (Node.js)
# Kita pisahkan ini agar image akhir tidak bengkak dengan node_modules
FROM node:20-alpine AS node_builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# STAGE 2: Install Composer Dependencies
FROM composer:2 AS composer_builder
WORKDIR /app
COPY composer.json composer.lock ./
# --ignore-platform-reqs penting jika host build beda arsitektur dengan target
RUN composer install --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# STAGE 3: Runtime (FrankenPHP)
FROM dunglas/frankenphp:1-php8.3

# 1. Install System Dependencies & PHP Extensions
# pcntl, sockets, dan bcmath sangat wajib untuk Octane
# 1. Install System Dependencies & PHP Extensions
RUN apt-get update && apt-get install -y \
    libzip-dev libpng-dev libicu-dev libxml2-dev \
    zip unzip curl acl && \
    docker-php-ext-install -j$(nproc) \
    pcntl \
    bcmath \
    sockets \
    intl \
    zip \
    gd \
    opcache \
    pdo_mysql && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Configure PHP (Production Settings)
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/php-custom.ini && \
    echo "variables_order=EGPCS" >> /usr/local/etc/php/conf.d/php-custom.ini

WORKDIR /var/www/html


# 4. Copy Source Code Aplikasi
COPY . .

# HAPUS file hot bawaan lokal agar Vite tahu ini Production
RUN rm -f public/hot

# 3. Copy Dependencies dari Stage Sebelumnya
COPY --from=composer_builder /app/vendor ./vendor
COPY --from=node_builder /app/public/build ./public/build

# 5. SETUP PERMISSION & OCTANE CONFIG (BAGIAN KRUSIAL)
# Kita buat folder storage log secara manual dan pastikan www-data memilikinya
RUN mkdir -p storage/logs storage/framework/views storage/framework/cache storage/framework/sessions bootstrap/cache

# Fix Permissions: Berikan kepemilikan penuh ke www-data
# Force permission 755 untuk public agar Nginx/FrankenPHP bisa baca static files
# Force permission 775 untuk storage/cache agar Laravel bisa tulis logs/cache
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache && \
    chmod -R 755 public

# 6. Environment Variables Khusus Octane
# Ini MEMAKSA Octane menulis state file ke storage/logs, bukan ke root
ENV OCTANE_SERVER=frankenphp
ENV OCTANE_STATE_FILE=/var/www/html/storage/logs/octane-server-state.json

# 8. Expose & Entrypoint
EXPOSE 8000

# Hapus flag --watch untuk production karena butuh resource besar & chokidar
# Gunakan array exec form untuk performa sinyal (SIGTERM) yang lebih baik
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000"]