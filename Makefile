.PHONY: help pull up restart logs clean status deploy

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  pull    - Pull latest images"
	@echo "  up      - Start all services"
	@echo "  deploy  - Pull latest images and start services"
	@echo "  restart - Restart all or specific service"
	@echo "  logs    - Show logs (use SERVICE=name to filter)"
	@echo "  status  - Show container status"
	@echo "  clean   - Stop and remove all containers"
	@echo ""
	@echo "Examples:"
	@echo "  make pull"
	@echo "  make up"
	@echo "  make deploy"
	@echo "  make restart"
	@echo "  make restart SERVICE=api"
	@echo "  make logs SERVICE=api"
	@echo "  make status"

pull:
	docker compose pull

up:
	docker compose up -d

deploy: pull up

restart:
ifdef SERVICE
	docker compose restart $(SERVICE)
else
	docker compose restart
endif

logs:
ifdef SERVICE
	docker compose logs -f $(SERVICE)
else
	docker compose logs -f
endif

status:
	docker compose ps

clean:
	docker compose down