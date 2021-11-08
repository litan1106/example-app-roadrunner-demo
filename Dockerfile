# ----------------------------------------------- Build Time Arguments ---------------------------------------------
ARG VARIANT="8.0-apache"
ARG COMPOSER_VERSION="2.0"
ARG ROADRUNNER_VERSION="2.5.6"

# ------------------------------------------------- Composer Image -------------------------------------------------
FROM composer:${COMPOSER_VERSION} as composer

# ------------------------------------------------- RoadRunner Image -----------------------------------------------
FROM spiralscout/roadrunner:${ROADRUNNER_VERSION} as roadrunner

# ==================================================================================================================
#                                                  --- BASE PHP ---
# ==================================================================================================================
FROM php:${VARIANT}

ARG PHP_MEMORY_LIMIT="1024M"
ARG OPCACHE_ENABLE=1
ARG OPCACHE_VALIDATE_TIMESTAMPS=0

ENV PHP_MEMORY_LIMIT ${PHP_MEMORY_LIMIT}
ENV OPCACHE_ENABLE ${OPCACHE_ENABLE}
ENV OPCACHE_VALIDATE_TIMESTAMPS ${OPCACHE_VALIDATE_TIMESTAMPS}

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends unzip zip git-core curl bash nano \
    && docker-php-source extract \
    && docker-php-ext-install -j$(nproc) opcache pcntl sockets > /dev/null \
    && docker-php-source delete \
    # Setup php.ini
    && mv ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Setup custom app php.ini
COPY app.ini /usr/local/etc/php/conf.d/app.ini
# Setup apache2 vhost
COPY apache2-vhost.conf /etc/apache2/sites-available/000-default.conf

# Change DocumentRoot in other Apache configuration
RUN sed -ri -e 's!/var/www/!//var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && sed -i 's/80/8080/g' /etc/apache2/ports.conf

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=roadrunner /usr/bin/rr /usr/bin/rr

WORKDIR /var/www/html

# Prepare Laravel project with Octane and RoadRunner
RUN composer create-project laravel/laravel . \
    && composer require laravel/octane \
    && composer require spiral/roadrunner:^2.0 --with-all-dependencies \
    && chown -R www-data:www-data /var/www/html/bootstrap /var/www/html/storage

# Copy .rr.yaml
COPY .rr.yaml /var/www/html/.rr.yaml

EXPOSE 8080 8000

# Laravel Octane envs
ARG APP_ENV="local"
ARG APP_BASE_PATH="/var/www/html"
ARG LARAVEL_OCTANE="1"

ENV APP_ENV ${APP_ENV}
ENV APP_BASE_PATH ${APP_BASE_PATH}
ENV LARAVEL_OCTANE ${LARAVEL_OCTANE}