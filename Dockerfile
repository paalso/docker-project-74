# Dockerfile

# Development Dockerfile.
# Installs dependencies, copies the source code, and starts the app in dev mode.
# Used with docker-compose.override.yml for hot-reloading and local development.

FROM node:20.12.2

WORKDIR /app

COPY app/package.json .
COPY app/package-lock.json .
RUN npm ci

COPY app/ .

ENV FASTIFY_ADDRESS 0.0.0.0
EXPOSE 8080

CMD ["make", "dev"]
