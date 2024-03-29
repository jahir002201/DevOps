# DevOps


# Create a new directory for your Laravel project
mkdir my_laravel_project

# Navigate into the directory
cd my_laravel_project

# Create a Dockerfile to build your Laravel environment
cat << EOF > Dockerfile
FROM composer:2 AS builder

WORKDIR /app

# Install Laravel
RUN composer create-project --prefer-dist laravel/laravel:^10.0 .

# Install Laravel UI package with Bootstrap preset
RUN composer require laravel/ui
RUN php artisan ui bootstrap --auth

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

FROM php:8.2.0-cli

WORKDIR /app

# Install PDO extension for MySQL support
RUN docker-php-ext-install pdo pdo_mysql

# Copy Laravel files from builder stage
COPY --from=node_builder /app .

# Expose port 8000 for Laravel application
EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=\$PORT
EOF

# Build your Docker image
docker build -t my_laravel_app .

# Run the Docker container with port mapping and MySQL support
docker run --rm -p 8100:8000 -e PORT=8000 --name my_laravel_container -d -e DB_CONNECTION=mysql -e DB_HOST=mysql -e DB_PORT=3306 -e DB_DATABASE=my_database -e DB_USERNAME=my_user -e DB_PASSWORD=my_password my_laravel_app
