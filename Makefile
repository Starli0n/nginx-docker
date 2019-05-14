-include .env
export $(shell sed 's/=.*//' .env)

export REGISTRY_HOSTNAME=${REGISTRY_CONTAINER}.${NGINX_HOSTNAME}
export REGISTRY_HTTP_URL=http://${REGISTRY_HOSTNAME}:${REGISTRY_PORT}
export REGISTRY_EXTERNAL_URL=https://${REGISTRY_HOSTNAME}:${NGINX_PROXY_HTTPS}

.PHONY: env_var
env_var: # Print environnement variables
	@cat .env
	@echo
	@echo REGISTRY_HOSTNAME=${REGISTRY_HOSTNAME}
	@echo REGISTRY_HTTP_URL=${REGISTRY_HTTP_URL}
	@echo REGISTRY_EXTERNAL_URL=${REGISTRY_EXTERNAL_URL}

.PHONY: env
env: # Create .env and tweak it before init
	cp .env.default .env

.PHONY: init
init:
	mkdir -p registry

.PHONY: erase
erase:
	rm -rf registry

.PHONY: pull
pull: # Pull the docker image
	docker pull registry:${TAG}

.PHONY: config
config: # Show docker-compose configuration
	docker-compose -f docker-compose.yml config

.PHONY: up
up: # Start containers and services
	docker-compose -f docker-compose.yml up -d

.PHONY: down
down: # Stop containers and services
	docker-compose -f docker-compose.yml down

.PHONY: start
start: # Start containers
	docker-compose -f docker-compose.yml start

.PHONY: stop
stop: # Stop containers
	docker-compose -f docker-compose.yml stop

.PHONY: restart
restart: # Restart container
	docker-compose -f docker-compose.yml restart

.PHONY: delete
delete: down erase

.PHONY: mount
mount: init up

.PHONY: reset
reset: down up

.PHONY: hard-reset
hard-reset: delete mount

.PHONY: logs
logs:
	docker-compose logs -f

.PHONY: shell
shell: # Open a shell on a started container
	docker exec -it ${REGISTRY_CONTAINER} /bin/bash

.PHONY: url
url:
	@echo ${REGISTRY_EXTERNAL_URL}
