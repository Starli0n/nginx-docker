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
	mkdir -p registry/{auth,data}
	docker run --entrypoint htpasswd registry:${TAG} -Bbn ${REGISTRY_USER} ${REGISTRY_PASS} > registry/auth/htpasswd

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
	docker exec -it ${REGISTRY_CONTAINER} /bin/sh

.PHONY: login
login:
	@docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} ${REGISTRY_HOSTNAME} 2> /dev/null
	@echo ${REGISTRY_HOSTNAME}

.PHONY: logout
logout:
	docker logout ${REGISTRY_HOSTNAME}

.PHONY: catalog
catalog:
	@curl -u ${REGISTRY_USER}:${REGISTRY_PASS} ${REGISTRY_EXTERNAL_URL}/v2/_catalog

.PHONY: list
list:
	@curl -u ${REGISTRY_USER}:${REGISTRY_PASS} ${REGISTRY_EXTERNAL_URL}/v2/my-hello-world/tags/list

.PHONY: garbage-collect
garbage-collect:
	docker exec registry bin/registry garbage-collect /etc/docker/registry/config.yml

.PHONY: test-login
test-login: login logout

.PHONY: test
test: login test-push test-remove stop test-delete start garbage-collect logout

.PHONY: test-push
test-push:
	docker pull hello-world:latest
	docker tag hello-world:latest ${REGISTRY_HOSTNAME}/my-hello-world:latest
	docker push ${REGISTRY_HOSTNAME}/my-hello-world:latest
	docker image remove hello-world:latest ${REGISTRY_HOSTNAME}/my-hello-world:latest
	docker pull ${REGISTRY_HOSTNAME}/my-hello-world:latest

.PHONY: test-remove
test-remove:
	docker run --rm ${REGISTRY_HOSTNAME}/my-hello-world:latest
	docker image remove ${REGISTRY_HOSTNAME}/my-hello-world:latest

.PHONY: test-delete
test-delete:
	find . | grep `ls ./registry/data/docker/registry/v2/repositories/my-hello-world/_manifests/tags/latest/index/sha256` | xargs rm -rf $1
	ls -1 ./registry/data/docker/registry/v2/repositories/my-hello-world/_layers/sha256 | xargs -L1 find ./registry/data/docker/registry/v2 -name $1 | xargs rm -rf $1
	rm -rf ./registry/data/docker/registry/v2/repositories/my-hello-world

.PHONY: url
url:
	@echo ${REGISTRY_EXTERNAL_URL}
