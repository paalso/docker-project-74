# Include additional Docker Compose helper targets if any
include make-compose.mk

.PHONY: help build prod ci dev run-dev-direct

help: ## Show this help message
	@echo
	@echo "Usage: make <target>"
	@echo
	@echo "Available targets:"
	@grep -h -E '^[a-zA-Z0-9_/-]+:.*## ' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo

build:	## Build the production image (Dockerfile.production)
	docker compose --file docker-compose.yml build app

# prod:	## Run the production server (no override)
# 	docker compose --file docker-compose.yml up

ci:	## Run tests in CI mode using production config (stops on first failure)
	docker compose --file docker-compose.yml up --abort-on-container-exit --exit-code-from app

dev:	## Run the development server with override (hot-reload)
	docker compose up

run-dev-direct:	## Run development mode directly with docker run (bypassing docker compose)
	docker run -p 8080:8080 -e NODE_ENV=development paalso/docker-project-74 make dev
