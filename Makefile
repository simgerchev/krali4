.PHONY: build up down logs clean

build:
	docker compose build
	docker build -f frontend/Dockerfile -t krali4-frontend .

up: build
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f challenge

clean:
	docker compose down --volumes --remove-orphans
