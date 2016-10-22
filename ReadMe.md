cc-ng-openapi
=============

Serve OpenAPI definitions for a Cloud Controller NG API

# Synopsis

```
make build
make doc
./cc-ng-openapi-server https://api.192.168.77.77.nip.io
```

# Description

This repo builds a small server that adds 2 endpoints to a Cloud Controller NG:

* `GET v2/openapi`
* `GET v3/openapi`

These endpoints return a JSON representation of the OpenAPI/Swagger definitions
for the v2 and v3 APIs for the Cloud Controller itself. The data from the
definition payloads can be used to generate many things:

* API Documentation
* Client Code
* Server Code
* API Tests
* API CLIs
* Console UI Code
* etc

# Makefile Targets

This repository has a Makefile for automating these basic tasks:

* `make build`

  Create the OpenAPI JSON payloads from the config files. Also build the
  `./cc-ng-openapi-server` program.

* `make openapi`

  Just build the OpenAPI JSON files.

* `make server`

  Just build the server.

* `make doc`

  Generate the API docs using `swagger-codegen`.

* `make run`
* `make test`
* `make docker-build`
* `make docker-run`
* `make docker-shell`
* `make docker-push`

# Running the CC NG API Server

To start the API server, use the following invocation:

```
make run
```

## Testing

To run the API server without a Cloud Foundry CC, do this:

```
./cc-ng-openapi-server test
```
