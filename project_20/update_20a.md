FROM php:7.2-apache

RUN apt-get update

#development packages

RUN apt-get install -y \
    git \
    zip \
    curl \
    sudo \
    unzip \
    libicu-dev \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    g++

#apache configs + document root. by default, php-apache document root is set to /var/www/html but laravel index.php is in /var/www/html/public. so we'll edit the apache config and sites-available. 

ENV APACHE_DOCUMENT_ROOT=#${APACHE_DOCUMENT_ROOT}
ENV APACHE_RUN_USER=#${UID}
ENV APACHE_RUN_GROUP=#${UID}
ENV HOST_PORT=#${HOST_PORT}

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

#We'll enable mod_rewrite for url matching and mod_headers for configuring webserver headers like Access-Control-Allow-Origin-

RUN a2enmod rewrite headers

#start with base php config, then add extensions

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN docker-php-ext-install \
    bz2 \
    intl \
    iconv \
    bcmath \
    opcache \
    calendar \
    mbstring \
    pdo_mysql \
    zip

#composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#we need a user with the same UID/GID with host user
#so when we execute CLI commands, all the host file's ownership remains intact
#otherwise command from inside container will create root-owned files and directories

ARG uid
RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
RUN mkdir -p /home/devuser/.composer && \
    chown -R devuser:devuser /home/devuser

COPY . /var/www/html
RUN cd /var/www/html && composer install && php artisan key:generate




.env

DB_HOST=mysql-db
MYSQL_ROOT_PASSWORD=securerootpassword
MYSQL_DATABASE=db
MYSQL_USER=dbuser
MYSQL_PASSWORD=secret

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

MIX_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
MIX_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

UID=1000
HOST_PORT=8000