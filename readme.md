# PHP dev environment #

Заготовка docker-compose.yml файла для поднятия dev окружения php-fpm + nginx.

## Использование ##

1) скопировать файлы в корень проекта
2) заполнить параметры окружения
```shell
make env
vim .docker/.env
```
3) подготовить сеть и прокси, если это ещё не было сделано
```shell
make network
make proxy-start
```
4) запустить контейнеры
```shell
make start
```
5) остановить контейнеры
```shell
make stop
```