#!/bin/bash

route-registrar -configPath /etc/route-registar.yaml &> /var/log/route-registar.log &

docker run -it --rm --net hcf --entrypoint bash ingy/cc-ng-openapi-server &> /var/log/cc-ng-openapi-server.log  &
