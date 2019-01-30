TAG ?= 6.2.3.10-ci-test-2
$(info ---- TAG = $(TAG))
REGISTRY ?= gcr.io/strapdata-gcp-partnership

include tools/gcloud.Makefile
include tools/crd.Makefile
include tools/var.Makefile
include tools/app.Makefile


UPSTREAM_IMAGE = docker.io/strapdata/elassandra:$(TAG)
#UPSTREAM_IMAGE = container-nexus.azure.strapcloud.com/gcr/elassandra:$(TAG)
APP_MAIN_IMAGE ?= $(REGISTRY)/elassandra:$(TAG)
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elassandra/deployer:$(TAG)

NAME ?= elassandra-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "image.name": "$(APP_MAIN_IMAGE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/elassandra/deployer \
            .build/elassandra/elassandra


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
	    --build-arg REGISTRY="$(REGISTRY)/elassandra" \
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
