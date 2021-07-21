FROM composer as composer

FROM php:8-fpm-alpine

RUN apk add git

COPY --from=composer /usr/bin/composer /usr/bin/composer
