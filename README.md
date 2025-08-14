#### Hexlet tests and linter status:
[![Actions Status](https://github.com/paalso/docker-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/paalso/docker-project-74/actions)

#### App tests and docker push status:
[![push](https://github.com/paalso/docker-project-74/actions/workflows/push.yml/badge.svg)](https://github.com/paalso/docker-project-74/actions/workflows/push.yml)

## [Hexlet](https://ru.hexlet.io/), program [Devops for developers](https://ru.hexlet.io/programs/devops-for-developers), Level 1 project
### [Упаковка в Docker Compose (Docker Compose Packaging)](https://ru.hexlet.io/programs/python/projects/74)

#### Docker image on [my Docker hub](https://hub.docker.com/u/paalso): [paalso/docker-project-74](https://hub.docker.com/r/paalso/docker-project-74)

## Некоторые заметки по организации docker-инфраструктуры

### Общая схема
```
          ┌─────────────────────┐
          │ docker-compose.yml  │
          │ (base config)       │
          └─────────┬───────────┘
                    │
      ┌─────────────▼─────────────┐
      │ Dockerfile.production     │
      │ (prod/test build)         │
      └───────────────────────────┘

override applied automatically:
      ┌─────────────────────────────┐
      │ docker-compose.override.yml │
      │ (dev overrides)             │
      └─────────┬───────────────────┘
                │
         ┌──────▼───────────┐
         │ Dockerfile (dev) │
         │ hot-reload, vol. │
         └──────────────────┘
```

### Docker / Compose конфигурация

В проекте используются два Dockerfile и два docker-compose файла.

#### Общее для всех окружений
- Образ на базе `node:20.12.2`.
- Рабочая директория — `/app`.
- Сначала копируются `package.json` + `package-lock.json` и выполняется `npm ci`.
- Затем копируется исходный код (`COPY app/ .`).
- Приложение слушает порт `8080`.
- Конфигурация передаётся через переменные окружения (методология 12 факторов).

---

#### **Dockerfile** — Development
- Запускает приложение командой `make dev` (hot-reload).
- Устанавливает `FASTIFY_ADDRESS=0.0.0.0`.
- Используется с `docker-compose.override.yml`.

#### **Dockerfile.production** — Production/Test
- Устанавливает `NODE_ENV=production`.
- Выполняет сборку фронтенда (`make build`).
- По умолчанию запускает тесты (`make test`).
- Используется с базовым `docker-compose.yml`.

---

#### **docker-compose.yml** — базовая конфигурация (prod/test)
- Сервис `app` собирается из `Dockerfile.production`.
- Поднимает Postgres (`db`) с volume для данных и healthcheck’ом.
- Не монтирует код — всё копируется при сборке образа.

#### **docker-compose.override.yml** — dev-override
- Подменяет Dockerfile на dev-версию.
- Монтирует локальный код `./app:/app` для hot-reload.
- Добавляет сервис `caddy` для проксирования запросов.

---

### Дисклеймер

1. **Организация зависимостей**  
   В проекте зависимости организованы не самым удачным образом. При текущих требованиях приходится собирать docker-образ для `test/production`, устанавливая **все** зависимости из [`package.json`](https://github.com/paalso/docker-project-74/blob/main/app/package.json):  
   - кроме основных зависимостей - [dependencies](https://github.com/paalso/docker-project-74/blob/128819849adb570db3679efaa06559c274d6ffd8/app/package.json#L38), устанавливаются и [devDependencies](https://github.com/paalso/docker-project-74/blob/128819849adb570db3679efaa06559c274d6ffd8/app/package.json#L73).  
   - Отказаться от `devDependencies` нельзя, так как там содержатся пакеты, необходимые для тестирования в `test/production`.  
   - В результате в образ попадают лишние пакеты (например, линтеры), увеличивая размер и сложность поддержки.  
   - Кроме того, для `test/production` фактически не нужен пакет [`sqlite3`](https://github.com/paalso/docker-project-74/blob/main/app/package.json#L70), который есть в `dependencies`.

2. **Копирование лишних файлов**  
   В [`Dockerfile.production`](https://github.com/paalso/docker-project-74/blob/main/Dockerfile.production) используется `COPY app/ .`, что включает ненужные файлы `*.sqlite`.  
   Избавиться от них без костылей невозможно при существующей структуре проекта и требуемой конфигурации Docker.

3. **Неочевидное требование docker-compose.yml**  
   Согласно заданию:  
   > [При старте контейнера приложения должны запускаться тесты с помощью команды `make test`](https://ru.hexlet.io/projects/74/members/47176?step=2)

   В текущей реализации [`docker-compose.yml`](https://github.com/paalso/docker-project-74/blob/main/docker-compose.yml) именно это и сделано [таким образом](https://github.com/paalso/docker-project-74/blob/128819849adb570db3679efaa06559c274d6ffd8/docker-compose.yml#L22)

   Однако, с точки зрения обычного использования, логично было бы, чтобы базовый `docker-compose.yml` запускал само приложение (`make start` или `make prod`), а тесты выполнялись через отдельную команду или сервис.  
   То есть учебное решение корректно для проверки тестов, но для реального продакшена лучше иметь отдельный сервис/команду для тестирования.
