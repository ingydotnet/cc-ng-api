cc-ng-openapi
=============

Serve OpenAPI definitions for a Cloud Controller NG API

# Synopsis

Assuming you have Helion Cloud Foundry running in Vagrant in `~/hcf/`:

```
cd ~/hcf/
git clone git@github.com:ingydotnet/cc-ng-openapi
cd cc-ng-openapi/
make
make build
make test
vagrant ssh
cd hcf/cc-ng-openapi/
make hcf
make docker-run
exit
cf curl v2/openapi
cf curl v3/openapi
curl -ks https://openapi.192.168.77.77.nip.io/v2/openapi
curl -ks https://openapi.192.168.77.77.nip.io/v3/openapi
```

# Description

This repo builds OpenAPI definitions for the v2 and v3 Cloud Foundry Cloud
Controller NG APIs, from more succinct SSOT source data files:

* src/cc-ng-openapi-v2.yaml
* src/cc-ng-openapi-v3.yaml

The OpenAPI definition payloads can be used to generate many things:

* API Documentation
* Client Code
* Server Code
* API Tests
* API CLIs
* Console UI Code
* etc

This repo generates a single file Ruby controller (`openapi_controller.rb`)
that adds these endpoints to the CC API:

* `GET v2/openapi`
* `GET v3/openapi`

These endpoints return a JSON representation of the OpenAPI/Swagger
definitions.

The `Makefile` can inject the Ruby code into a running Helion Cloud Foundry
setup. See "Makefile" below.

This repo also provides a Go server (packaged in a Docker container) that
serves the 2 OpenAPI docs. The server can be registered as a route/endpoint
to a Cloud Foundry installation.

# Makefile

This repository has a Makefile for automating all the basic tasks:

* `make build`

  Create the OpenAPI JSON payloads from the config files.

* `make test`

  Test that the OpenAPI documents match the Cloud Controller NG version for
  which they are meant to represent.

* `make run`

  Run the `cc-ng-openapi-server.go` server locally.

* `make doc`

  Generate the API docs from the OpenAPI definitions using `swagger-codegen`.

* `make hcf`

  Inject the OpenAPI Ruby controller into a running HCF.

* `make docker-run`

  Run the `cc-ng-openapi-server` Docker image.

* `make docker-build`

  Build the `cc-ng-openapi-server` Docker image.

* `make docker-shell`

  Build the `cc-ng-openapi-server` Docker image.

* `make docker-push`

# Setup and Prerequisites

This code was written and tested using an HCF instance running on Vagrant on a
Mac. The `hcf` and `docker-run` Makefile targets are meant to be run from
inside a running HCF Vagrant box.

The best thing to do is clone this repo inside your local `hcf` directory. Then
you can see/edit/make the same files both on your Mac and inside Vagrant.

The `make build` target which generates the `openapi.yaml` files can be run
from anywhere, but some prerequisites are required. Assuming you are on a Mac,
run these commands:

```
brew update
brew install swagger-codegen
brew install node
npm install -g coffee-script
npm install -g jyj
npm install -g schematype
npm install lodash
npm install js-yaml
```

# Maintenance

To keep these API documents up to date, you need to hand edit these files:

* src/cc-ng-openapi-v2.yaml
* src/cc-ng-openapi-v3.yaml

Everything else gets generated from them.

## Testing

By running `make test` you find out if the OpenAPI defintions match the Cloud
Controller code that they will be used with.

If you are working inside a `hcf/cc-ng-openapi` directory, the
`cloud_controller_ng` directory will be found automatically. You can override
the Cloud Controller repo with the `CCNG_REPO` environment variable. For
example:

```
CCNG_REPO=~/src/cloud_controller_ng make test
```
