#!/usr/bin/env bash

BASHLIB="`find $PWD -type d | grep -E '/(bin|lib)$' | xargs -n1 printf "%s:"`"
PATH="$BASHLIB:$PATH"
source bash+ :std
use Test::More

#------------------------------------------------------------------------------
d=test/data
v2y=v2/openapi.yaml
v2j=v2/openapi.json
v3y=v2/openapi.yaml
v3j=v2/openapi.json
yval() { perl -pe 's/.*: //'; }
yget2() { grep "$1" $v2y | yval; }
yget3() { grep "$1" $v3y | yval; }
want() { cat $d/$1; }

#------------------------------------------------------------------------------
# Check v2 API version
is "`yget2 version`" "`want api_version`" "v2 API version is correct"
is "`yget3 version`" "`want api_version`" "v3 API version is correct"

done_testing
