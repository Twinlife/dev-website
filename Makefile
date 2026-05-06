NAME=twinlife
VERSION=0.6.0
BUILD=debug
DIST_DIR=twinlife-$(VERSION)
DIST_FILE=twinlife-$(VERSION).tar.gz

MAKE_ARGS += -XTWINLIFE_BUILD=$(BUILD)

TSC=tsc

ALR?=alr --non-interactive
OPENAPI=$(ALR) exec -- openapi-generator
OPENAPI_OPTIONS=--additional-properties projectName=twinlife \
                --additional-properties openApiName=OpenAPI \
                --additional-properties httpSupport=Curl \
                --model-package Twinlife.Rest -o .

-include Makefile.conf

include Makefile.defaults

# Model generation arguments with Dynamo
# --package XXX.XXX.Models db uml/xxx.zargo
DYNAMO_ARGS=db
DYNAMO=alr exec -- dynamo

build:: lib-setup
	$(BUILD_COMMAND) $(GPRFLAGS) $(MAKE_ARGS)

docker-build:
	sudo docker --debug build --progress=plain --no-cache -t twinlife-build -f docker/Dockerfile .

docker-runtime:
	sudo docker --debug build --progress=plain --no-cache -t twinlife -f docker/Dockerfile-runtime .

generate::
	mkdir -p db
	$(DYNAMO) generate $(DYNAMO_ARGS)

generate-rest:
	$(OPENAPI) generate --generator-name ada -i twincodes-api.yaml $(OPENAPI_OPTIONS)

generate-js:
	$(TSC) web/js/comments.ts

lib-setup::

package:
	$(DYNAMO) dist $(DIST_DIR) package.xml
	tar czf $(DIST_FILE) $(DIST_DIR)
