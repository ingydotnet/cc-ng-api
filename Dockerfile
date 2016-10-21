FROM golang
COPY v2/ /v2/
COPY v3/ /v3/
COPY bin/ /bin/
COPY etc/ /etc/
COPY src/ /src/
WORKDIR /
ENTRYPOINT "cc-ng-openapi-server.sh"
