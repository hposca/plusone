AWS_REGION := us-west-2
ECR_PATH := ${AWS_ACCOUNT}.dkr.ecr.us-west-2.amazonaws.com
ROOT_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: all
all: prepare build local_integration_test

#
# Cleaning
#
.PHONY: clean
clean:
	rm -rf ${ROOT_DIR}/.stamps/

.PHONY: delete_all
delete_all:
	docker-compose down --rmi local --volumes

.PHONY: bruteforce_delete
bruteforce_delete:
	docker container ls -aq | xargs docker container stop; docker container ls -aq | xargs docker rm ; docker container prune --force; docker image prune --force; docker volume prune --force

.PHONY: fresh
fresh: delete_all clean

#
# Running
#
.PHONY: prepare
prepare: | .stamps/docker.login .stamps/prepared
.stamps/prepared:
	@touch ${ROOT_DIR}/$@

.PHONY: up
up: | docker
	docker-compose up -d plusone

.PHONY: run
run: | docker
	docker-compose up plusone

.PHONY: shell
shell: | docker
	docker-compose run --entrypoint /bin/sh plusone

.PHONY: shell-ports
shell-ports: | docker
	docker-compose run --service-ports --entrypoint /bin/sh plusone

.PHONY: build
build: | docker
	docker-compose build

.PHONY: force-build
force-build: | docker
	docker-compose build --no-cache

.PHONY: local_integration_test
local_integration_test: up | docker
	sleep 3
	./simple_validation.sh

#
# Auxiliary targets
#
.stamps: Makefile
	@mkdir -p $@

.PHONY: docker
docker: | .stamps/docker.installed
.stamps/docker.installed: | .stamps
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "You need to install docker before running this."; \
		exit 1; \
	fi
	@if ! command -v docker-compose >/dev/null 2>&1; then \
		echo "You need to install docker-compose before running this."; \
		exit 1; \
	fi
	@touch ${ROOT_DIR}/$@
