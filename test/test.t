#!/usr/bin/env bash

BASHLIB="`find $PWD -type d | grep -E '/(bin|lib)$' | xargs -n1 printf "%s:"`"
PATH="$BASHLIB:$PATH"
source bash+ :std
use Test::More

#------------------------------------------------------------------------------
d=test/data
v2j=v2/openapi.json
v3j=v2/openapi.json
jval() { perl -pe 's/.*: "(.*)",?/$1/'; }
jget2() { grep "$1" $v2j | head -1 | jval; }
jget3() { grep "$1" $v3j | head -1 | jval; }
want() { cat $d/$1; }

#------------------------------------------------------------------------------
# Check v2 API version
is "`jget2 version`" "`want api_version`" "v2 API version is correct"
is "`jget3 version`" "`want api_version`" "v3 API version is correct"

done_testing
