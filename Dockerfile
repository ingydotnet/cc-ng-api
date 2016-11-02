FROM golang
COPY v2/ /v2/
COPY v3/ /v3/
COPY src/docker/ /
WORKDIR /
ENTRYPOINT "/bin/cc-ng-openapi-server.sh"
