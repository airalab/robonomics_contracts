#!/bin/sh

NODEJS=/usr/bin/nodejs
if [ -x /usr/bin/node ]; then
    NODEJS=/usr/bin/node
fi

$NODEJS `dirname $0`/scripts/aira_deploy.js "$@" 
