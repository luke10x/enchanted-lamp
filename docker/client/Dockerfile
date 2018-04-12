FROM php:7.2.4-cli-stretch

RUN curl -sS https://getcomposer.org/installer | php 

RUN apt-get update; \
    apt-get install -y zlib1g-dev; \
    docker-php-ext-configure zip --with-zlib-dir=/usr; \
    docker-php-ext-install zip 

RUN php composer.phar require facebook/webdriver

RUN mkdir /scripts
VOLUME /scripts
