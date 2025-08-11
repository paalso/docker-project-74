FROM node:20.12.2

WORKDIR /app

COPY app/package.json .
COPY app/package-lock.json .

RUN npm install

COPY app/. .

ENV FASTIFY_ADDRESS 0.0.0.0
EXPOSE 8080

CMD ["make", "test"]
