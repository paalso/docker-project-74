include make-compose.mk

up:
	docker compose up --abort-on-container-exit

test:
	docker compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
