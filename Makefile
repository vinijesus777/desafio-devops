.PHONY: up down logs ps rebuild clean test

up:
	docker compose up --build

down:
	docker compose down

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps

rebuild:
	docker compose build --no-cache

clean: down
	docker system prune -f

test:
	./tests/smoke.sh
