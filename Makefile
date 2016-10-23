NAME := cc-ng-openapi-server
DOCKER_USER ?= $(USER)
DOCKER_NAME := $(DOCKER_USER)/$(NAME)
HCF_CC_PATH := /var/vcap/packages/cloud_controller_ng/cloud_controller_ng

CC_API_URL ?= https://api.192.168.77.77.nip.io

# Check for node, coffee, stp, etc

build: openapi

openapi: v2/openapi.json v3/openapi.json

doc: openapi
	swagger-codegen -i openapi-v2.yaml -l html2 -o doc/v2/
	swagger-codegen -i openapi-v3.yaml -l html2 -o doc/v3/

run: build
	./$(NAME) $(CC_API_URL)

test: openapi
	go run ./$(NAME).go

%/openapi.json: %/openapi.yaml
	jyj $< > $@

%/openapi.yaml: src/cc-ng-openapi-%.yaml %
	cp $< $@

v2 v3:
	mkdir $@

hcf-injection: openapi_controller.rb
	@docker ps | grep ' api-int' >/dev/null || \
	    { echo 'HCF not running here'; exit 1; }
	docker cp openapi_controller.rb \
	    api-int:$(HCF_CC_PATH)/app/controllers/v3/openapi_controller.rb
	docker exec api-int pkill -f 'ruby.*yml'
	@echo 'HCF CC restarting. Wait about 5-10 seconds.'

openapi_controller.rb: openapi
	cat src/openapi_controller.1 \
	    v2/openapi.json \
	    src/openapi_controller.2 \
	    v3/openapi.json \
	    src/openapi_controller.3 \
	    > $@

docker-build: build
	docker build -t $(DOCKER_NAME) .

docker-run:
	docker run -d --net=hcf $(DOCKER_NAME)

docker-shell:
	docker run -it --rm --net=hcf --entrypoint=bash $(DOCKER_NAME)

docker-push:
	docker push $(DOCKER_NAME)

clean:
	rm -fr v2 v3 openapi_controller.rb
