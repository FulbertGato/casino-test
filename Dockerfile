# Utilisez l'image PHP officielle avec Apache
FROM php:7.4-apache

# Installez git, unzip, zip, et les dépendances nécessaires pour les extensions PHP
RUN apt-get update && apt-get install -y \
        libonig-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libzip-dev \
        libgd-dev \
        git \
        unzip \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installez les extensions PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install bcmath ctype fileinfo json mbstring pdo xml tokenizer curl gd exif zip

RUN docker-php-ext-install bcmath ctype fileinfo json mbstring pdo xml tokenizer curl gd

# Enable Apache Modules
RUN a2enmod rewrite


# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set Document Root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update Apache Configuration
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}/!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
#COPY ./apache-config/000-default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
# Copy source code (Assuming your source code is in the current directory)
COPY . /var/www/html



# Set Permissions
RUN chmod -R 777 /var/www/html/storage /var/www/html/bootstrap

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# Install NPM Packages
RUN cd /var/www/html && npm install

# Expose port 80
EXPOSE 80
