.PHONY: build up down logs clean

build:
	docker compose build
	docker build -t krali4-frontend ./frontend

up: build
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f challenge

clean:
	docker compose down --volumes --remove-orphans
