NAME := cc-ng-openapi-server
DOCKER_USER ?= $(USER)
DOCKER_NAME := $(DOCKER_USER)/$(NAME)
HCF_CC_PATH := /var/vcap/packages/cloud_controller_ng/cloud_controller_ng

CC_API_URL ?= https://api.192.168.77.77.nip.io

# TODO Check for node, coffee, stp, etc

build: v2/openapi.json v3/openapi.json

test:
	@echo API test not yet implemented

run: build
	@echo 'Try: curl http://localhost:8080/v2/openapi'
	@echo 'Try: curl http://localhost:8080/v3/openapi'
	@echo
	go run src/$(NAME).go

doc: build
	swagger-codegen -i openapi-v2.yaml -l html2 -o doc/v2/
	swagger-codegen -i openapi-v3.yaml -l html2 -o doc/v3/

hcf-injection: check-hcf openapi_controller.rb
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

#------------------------------------------------------------------------------
check-hcf:
	@docker ps | grep ' api-int' >/dev/null || \
	    { echo 'HCF not running here'; exit 1; }

openapi_controller.rb: build
	cat src/openapi_controller.1 \
	    v2/openapi.json \
	    src/openapi_controller.2 \
	    v3/openapi.json \
	    src/openapi_controller.3 \
	    > $@

%/openapi.json: %/openapi.yaml
	jyj $< > $@

%/openapi.yaml: src/cc-ng-openapi-%.yaml %
	./bin/generate-openapi $< > $@

v2 v3:
	mkdir $@

clean:
	rm -fr data doc openapi_controller.rb v2 v3
