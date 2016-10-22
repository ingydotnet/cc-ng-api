#!/bin/bash

set -ex

ip_addr="$(
  ip addr |
  grep 'inet ' |
  tail -1 |
  perl -pe 's/.*?([\d\.]+).*/$1/'
)"
echo "host: $ip_addr" >> etc/route-registrar.yaml

route-registrar \
	-configPath etc/route-registrar.yaml \
	&> var/log/route-registrar.log &

sleep 1

go run src/cc-ng-openapi-server.go \
	&> /var/log/cc-ng-openapi-server.log
