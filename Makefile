SHELL := /bin/bash

.PHONY: up down restart logs smoke load clean ps

up:
	docker compose up -d --build
	@echo 'Prometheus: http://127.0.0.1:19090  |  Grafana: http://127.0.0.1:13001'

down:
	docker compose down -v

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps

smoke:
	./tests/smoke.sh

load:
	./tests/load.sh 60

clean:
	docker compose down -v || true
	docker system prune -af || true
