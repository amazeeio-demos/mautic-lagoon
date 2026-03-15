#############
### CLI
FROM uselagoon/php-8.4-cli-drupal:latest AS cli

RUN apk add --no-cache \
        autoconf \
        make \
        gcc \
        g++ \
        musl-dev \
        openssl-dev \
        imap-dev \
        krb5-dev \
    && pecl install imap \
    && docker-php-ext-enable imap \
    && apk del autoconf make gcc g++ musl-dev \
    && apk add --no-cache c-client krb5-libs

COPY composer.* /app/
COPY patches /app/patches

COPY . /app

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN fix-permissions /app/docroot/app/bundles/CoreBundle/Assets

RUN mkdir -p -v -m775 /app/var/logs
RUN fix-permissions /app/var
ENV WEBROOT=docroot

#############
### NGINX
FROM uselagoon/nginx-drupal:latest AS nginx

COPY --from=cli /app /app
ENV WEBROOT=docroot

#############
### PHP
FROM uselagoon/php-8.4-fpm:latest AS php

RUN apk add --no-cache \
        autoconf \
        make \
        gcc \
        g++ \
        musl-dev \
        openssl-dev \
        imap-dev \
        krb5-dev \
    && pecl install imap \
    && docker-php-ext-enable imap \
    && apk del autoconf make gcc g++ musl-dev \
    && apk add --no-cache c-client krb5-libs

COPY --from=cli /app /app
