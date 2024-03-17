# Stage 1: Build Laravel application
FROM composer:2 AS builder

WORKDIR /app

# Install Laravel
RUN composer create-project --prefer-dist laravel/laravel:^10.0 .

# Install Laravel UI package with Bootstrap preset
RUN composer require laravel/ui
RUN php artisan ui bootstrap --auth

# Stage 2: Build assets with Vite
FROM node:16 AS node_builder

WORKDIR /app

# Copy only package.json and package-lock.json for npm install
COPY --from=builder /app/package*.json ./

# Install npm dependencies
RUN npm install

# Copy the rest of the application
COPY --from=builder /app .

# Install Laravel Vite plugin and Vite
RUN npm install --save-dev vite laravel-vite-plugin

# Build assets with Vite
RUN npm run build

# Stage 3: Final PHP image with Laravel application
FROM php:8.2.0-cli

WORKDIR /app

# Install PDO extension for MySQL support
RUN docker-php-ext-install pdo pdo_mysql

# Copy Laravel files from builder stage
COPY --from=node_builder /app .

# Expose port 8000 for Laravel application
EXPOSE 8000

# Set environment variable for artisan serve command
CMD php artisan serve --host=0.0.0.0 --port=$PORT
