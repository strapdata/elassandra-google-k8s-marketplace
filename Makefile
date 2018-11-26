include app.Makefile
include crd.Makefile
include gcloud.Makefile
include var.Makefile

TAG ?= 6.2.3.8
$(info ---- TAG = $(TAG))

REGISTRY = gcr.io/strapdata-factory
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elassandra/deployer:$(TAG)
NAME ?= elassandra-1
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/elassandra/deployer \
            .build/elassandra/elassandra


.build/elassandra: | .build
	mkdir -p "$@"


.build/elassandra/deployer: deployer/* \
                           chart/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/elassandra
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/elassandra" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
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
	    --build-arg BASE_IMAGE="container-nexus.azure.strapcloud.com/gcr/elassandra:$(TAG)" \
	    --tag "$(REGISTRY)/elassandra:$(TAG)" \
	    -f elassandra/Dockerfile \
	    .
	docker push "$(REGISTRY)/elassandra:$(TAG)"
	@touch "$@"
