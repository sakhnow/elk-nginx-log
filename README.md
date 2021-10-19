# ELK-контейнеры в Podman для сбора логов 

## Назначение

Показать пример настройки контейнеров ELK для сбора логов Nginx в Elasticsearch.

## Установка

### Склонировать файл с настройкой переменных окружения

```shell
cp .env.example .env
```

### Настроить переменные окружения в файле .env

Достаточно заполнить только пароль к Elasticsearch, например:

```dotenv
ELASTIC_PASSWORD=secret
```

Остальные переменные можно оставить по умолчанию. Тогда Kibana будет доступна по адресу http://localhost:5602,
а nginx будет слушать по адресу http://localhost:8001

### Запуск контейнеров

```shell
make podman_up
```

После запуска должны запуститься 4 контейнера:
 - Elasticsearch
 - Logstash
 - Kibana
 - Nginx

Проверить запущенные контейнеры:

```shell
podman ps
```

## Проверка работоспособности

Для проверки нужно перейти на страницу http://localhost:8001 или выполнить:

```shell
curl http://localhost:8001
```

Если все работает, то будет выведена страница с приветствием 'Welcome to nginx!',
а в Elasticsearch появится новый индекс nginx-index. Увидеть новый индекс можно в
Kibana по адресу http://localhost:5602/app/management/data/index_management/indices

## Ссылки

* [Алексей Медов. Logstash - Отправка логов Nginx в Elasticsearch](https://www.youtube.com/watch?v=VbzlvWoWG8Y&t=1086s)