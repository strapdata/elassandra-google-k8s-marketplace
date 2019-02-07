TAG ?= 6.2.3.10
$(info ---- TAG = $(TAG))
REGISTRY ?= gcr.io/strapdata-gcp-partnership/

REPO_NAME ?= elassandra

include tools/gcloud.Makefile
include tools/crd.Makefile
include tools/var.Makefile
include tools/app.Makefile

UPSTREAM_IMAGE = docker.io/strapdata/elassandra-debian-gcr:$(TAG)
#UPSTREAM_IMAGE = container-nexus.azure.strapcloud.com/gcr/elassandra:$(TAG)
APP_MAIN_IMAGE ?= $(REGISTRY)$(REPO_NAME):$(TAG)
APP_DEPLOYER_IMAGE ?= $(REGISTRY)$(REPO_NAME)/deployer:$(TAG)

NAME ?= elassandra-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "image.name": "$(APP_MAIN_IMAGE)" \
}

TESTER_IMAGE ?= $(REGISTRY)$(REPO_NAME)/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "tester.image": "$(TESTER_IMAGE)" \
}


app/build:: .build/elassandra/deployer \
            .build/elassandra/elassandra \
            .build/elassandra/tester \



.build/elassandra: | .build
	mkdir -p "$@"


.build/elassandra/deployer: deployer/* \
                           chart/elassandra/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/elassandra
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)$(REPO_NAME)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/elassandra/elassandra: elassandra/* \
							.build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/elassandra
	docker build \
	    --build-arg BASE_IMAGE="$(UPSTREAM_IMAGE)" \
	    --tag "$(APP_MAIN_IMAGE)" \
	    -f elassandra/Dockerfile \
	    .
	docker push "$(APP_MAIN_IMAGE)"
	@touch "$@"

.build/elassandra/tester:   .build/var/TESTER_IMAGE \
                           $(shell find apptest -type f) \
                           | .build/elassandra
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
