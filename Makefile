define HELP

Makefile targets:

    make build        - Generate v2/openapi.json v3/openapi.json openapi_controller.rb
    make test         - Test openapi.json files against a cloud_controller_ng
    make run          - Run the cc-ng-openapi-server.go server locally
    make doc          - Generate the API docs using swagger-codegen

    make hcf          - Inject openapi_controller.rb into a running HCF
    make docker-run   - Run Go server inside a running HCF
    make docker-build - Builf the Docker image for the Go server

    make clean        - Remove generated files

endef
export HELP

NAME := cc-ng-openapi-server
DOCKER_USER ?= $(USER)
DOCKER_NAME := $(DOCKER_USER)/$(NAME)
HCF_CC_PATH := /var/vcap/packages/cloud_controller_ng/cloud_controller_ng

ifneq ("$(wildcard ../src/cf-release/src/capi-release)","")
export CCNG_REPO ?= ../src/cf-release/src/capi-release/src/cloud_controller_ng
endif

#------------------------------------------------------------------------------
help:
	@echo "$$HELP"

build: v2/openapi.json v3/openapi.json openapi_controller.rb

test: check-ccng build test/data test/test-more-bash
	prove -lv test/

run: build
	@echo 'Try: curl http://localhost:8080/v2/openapi'
	@echo 'Try: curl http://localhost:8080/v3/openapi'
	@echo
	go run src/docker/$(NAME).go

doc: build
	swagger-codegen generate -i v2/openapi.json -l html2 -o doc/v2/
	swagger-codegen generate -i v3/openapi.json -l html2 -o doc/v3/

hcf: check-hcf openapi_controller.rb
	docker cp openapi_controller.rb \
	    api-int:$(HCF_CC_PATH)/app/controllers/v3/openapi_controller.rb
	docker exec api-int pkill -f 'ruby.*yml'
	@echo 'HCF CC restarting. Wait about 5-10 seconds.'

docker-run: check-hcf docker-build
	docker run -d --net=hcf $(DOCKER_NAME)

docker-build: build
	docker build -t $(DOCKER_NAME) .

docker-shell:
	docker run -it --rm --net=hcf --entrypoint=bash $(DOCKER_NAME)

docker-push:
	docker push $(DOCKER_NAME)

clean:
	rm -fr cloud_controller_ng \
	    data doc openapi_controller.rb \
	    test/{data,test-more-bash} v2 v3

#------------------------------------------------------------------------------
check-hcf:
	@docker ps | grep ' api-int' >/dev/null || \
	    { echo 'HCF not running here'; exit 1; }

check-ccng:
	@[ -n "$$CCNG_REPO" ] || \
	    { echo 'CCNG_REPO variable not set'; exit 1; }
	@[ -e "$$CCNG_REPO/config/routes.rb" ] || \
	    { echo "'$$CCNG_REPO' not a cloud_controller_ng repo"; exit 1; }

openapi_controller.rb: v2/openapi.json v3/openapi.json
	cat src/template/openapi_controller.1 \
	    v2/openapi.json \
	    src/template/openapi_controller.2 \
	    v3/openapi.json \
	    src/template/openapi_controller.3 \
	    > $@

%/openapi.json: src/openapi-%.yaml data/ccng-%.yaml %
	./bin/generate-openapi $^ > $@

data/ccng-v2.yaml data/ccng-v3.yaml: data/ccng.yaml
	rm -f data/ccng-errors.yaml
	./bin/format-ccng-data $<
	@if [[ -e data/ccng-errors.yaml ]]; then \
	    cat data/ccng-errors.yaml; \
	    echo; \
	    echo 'Errors found. Saved in data/ccng-errors.yaml. See above.'; \
	    exit 1; \
	fi

data/ccng.yaml: cloud_controller_ng/vendor/bundle
	mkdir -p data
	./bin/extract-ccng-data > $@

cloud_controller_ng/vendor/bundle:
	./bin/get-cloud_controller_ng-local

test/data:
	mkdir $@
	./bin/extract-test-data $@

test/test-more-bash:
	git clone https://github.com/ingydotnet/test-more-bash $@

v2 v3 data:
	mkdir -p $@
