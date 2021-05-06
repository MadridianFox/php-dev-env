SHELL=/bin/bash

ifneq (,$(wildcard .docker/.env))
    include .docker/.env
    export
endif

env:
	cp .docker/.env.example .docker/.env

network:
	docker network create ${NETWORK}

proxy:
	docker run -d -p ${NETWORK_PROXY_PORT}:80 \
		--network ${NETWORK} \
		-v /var/run/docker.sock:/tmp/docker.sock:ro \
		--name ${NETWORK}-proxy jwilder/nginx-proxy

start:
	cd .docker && docker-compose up -d

stop:
	cd .docker && docker-compose stop

down:
	cd .docker && docker-compose down

clean:
	cd .docker && docker-compose down
	docker rm -f ${NETWORK}-proxy
	docker network rm ${NETWORK}