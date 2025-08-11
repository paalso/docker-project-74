Устанавливаем зависимости

```bash
~/Projects/docker-project-74 (main)$ docker run -it -w /root -v `pwd`/app:/root node:20.12.2 make setup
...................................................
```

Запускаем проект

```bash
~/Projects/docker-project-74 (main)$ docker run -it -w /root -v `pwd`/app:/root -p 8080:8080 node:20.12.2 make dev
npx concurrently "make start-frontend" "make start-backend"
[0] make[1]: Entering directory '/root'
[0] npx webpack --watch --progress
[1] make[1]: Entering directory '/root'
...................................................
```

Переименовали контейнеры

```bash
~/Projects/docker-project-74 (main)$ #
~/Projects/docker-project-74 (main)$ dpsa
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                      PORTS                                       NAMES
d197a17727b4   node:20.12.2   "docker-entrypoint.s…"   21 minutes ago   Up 40 seconds               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   fastify_blog
29c62653db6a   node:20.12.2   "docker-entrypoint.s…"   22 minutes ago   Exited (0) 10 minutes ago                                               node2012
```

fastify_blog можно запустить запустить снова

```bash
~/Projects/docker-project-74 (main)$ docker start -ai fastify_blog
npx concurrently "make start-frontend" "make start-backend"
[0] make[1]: Entering directory '/root'
[0] npx webpack --watch --progress
[1] make[1]: Entering directory '/root'
[1] npm start -- --watch --verbose-watch --ignore-watch='node_modules .git .sqlite'
[1]
[1] > javascript-fastify-blog@0.1.0 prestart
[1] > npm run migrate
...................................................
```

Проверим что работает

```bash
~/Projects/docker-project-74 (main)$ curl http://0.0.0.0:8080
<!DOCTYPE html><html lang="en"><head><title>Hexlet Fastify Boilerplate</title><script src="/assets/main.js"></script><link href="/assets/main.css" rel="stylesheet"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"></head><body class="d-flex flex-column min-vh-100"><nav class="navbar navbar-expand-lg navbar-light bg-light mb-3"><div class="container-fluid"><a class="navbar-brand" href="/">Simple blog</a><button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbarToggleExternalContent"><span class="navbar-toggler-icon"></span></button><div class="collapse navbar-collapse" id="navbarToggleExternalContent"><div class="container-fluid"><ul class="navbar-nav mr-auto"><li class="nav-item"><a class="nav-link" href="/articles">Articles</a></li></ul></div></div></div></nav><div class="container wrapper flex-grow-1"><h1 class="my-4"></h1><div class="card"><div class="card-body p-5 bg-light"><div class="display-4">Hello from Hexlet!</div><p class="lead">Online programming school</p><hr><a class="btn btn-primary btn-lg" href="https://hexlet.io">Learn more</a></div></div></div><footer><div class="container my-5 pt-4 border-top"><a target="_blank" href="https://ru.hexlet.io">Hexlet</a></div></footer></body></html>
```

Можно приконнектиться к уже запущенному контейнеру

```bash
~/Projects/docker-project-74 (main)$ docker exec -it fastify_blog bash
root@d197a17727b4:~# pwd
/root
root@d197a17727b4:~# ls
Makefile   config	    dist	      jsconfig.json  package-lock.json	server	webpack.config.js
README.md  database.sqlite  eslint.config.js  node_modules   package.json	src
root@d197a17727b4:~#
```
