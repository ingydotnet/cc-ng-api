NAME := cc-ng-openapi-server
DOCKER_USER ?= $(USER)
DOCKER_NAME := $(DOCKER_USER)/$(NAME)

CC_API_URL ?= https://api.192.168.77.77.nip.io

# Check for node, coffee, stp, etc

build: openapi server

openapi: v2/openapi.json v3/openapi.json
	@echo Building OpenAPI definitions...

server:
	@echo Building server...

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

docker-build: build
	docker build -t $(DOCKER_NAME) .

docker-run:
	docker run -d --net=hcf $(DOCKER_NAME)

docker-shell:
	docker run -it --rm --net=hcf --entrypoint=bash $(DOCKER_NAME)

docker-push:
	docker push $(DOCKER_NAME)

clean:
	rm -fr v2 v3
