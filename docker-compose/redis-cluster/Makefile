.PHONY: help setup storage acl acl-hash cert up up-tls down logs

help:
	@echo ""
	@echo "Redis Docker Compose Commands"
	@echo ""
	@echo "make setup      - generate storage, ACL, and TLS certificates"
	@echo "make storage    - prepare Redis volume directory"
	@echo "make acl        - generate users.acl"
	@echo "make acl-hash   - generate users-hash.acl"
	@echo "make cert       - generate TLS certificates"
	@echo ""
	@echo "make up         - start Redis"
	@echo "make down       - stop Redis"
	@echo "make logs       - view Redis logs"
	@echo ""

setup:
	chmod +x setup-redis.sh
	./setup-redis.sh all

storage:
	./setup-redis.sh storage

acl:
	./setup-redis.sh acl

acl-hash:
	./setup-redis.sh acl-hash

cert:
	./setup-redis.sh cert

up:
	docker compose up -d


down:
	docker compose down

logs:
	docker compose logs -f