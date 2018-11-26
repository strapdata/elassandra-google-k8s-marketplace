IMAGE_BASENAME=elassandra
IMAGE_DIR=strapdata-factory
REGISTRY=gcr.io
IMAGE_NAME=$(REGISTRY)/$(IMAGE_DIR)/$(IMAGE_BASENAME)
TAG ?= 6.2.3.8
HASH=$(shell date | md5sum | cut -f 1 -d ' ')

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## build the image
	docker build . -t $(IMAGE_NAME) --arg ELASSANDRA_VERSION=$(TAG)

publish: ## push the image to docker hub
	docker push $(IMAGE_NAME)
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(HASH)
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):$(HASH)
	docker push $(IMAGE_NAME):$(TAG)


run: ## run the container
	docker run -i -t --rm --name="$(IMAGE_BASENAME)" $(IMAGE_NAME) bash

up: build run ## build then run the container

stop: ## stop and remove the container
	docker stop $(IMAGE_NAME); docker rm $(IMAGE_NAME)

release: build publish ## build and publish the image to docker hub


.PHONY: build publish release run up stop