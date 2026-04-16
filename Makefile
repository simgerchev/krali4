.PHONY: build up down logs clean

build:
	docker build -t krali4-challenge ./challenge
	docker compose build

up: build
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f backend

# Remove all challenge containers and the backend
clean:
	docker compose down
	docker ps -a --filter "label=app=krali4" -q | xargs -r docker rm -f
	docker network rm krali4-challenge-net 2>/dev/null || true
