#!/bin/sh

NODEJS=`whereis -b node | awk '{print $2}'`
if [ -x "$NODEJS" ]; then
    $NODEJS `dirname $0`/scripts/aira_deploy.js "$@" 
    exit 0
fi

NODEJS=`whereis -b nodejs | awk '{print $2}'`
if [ -x "$NODEJS" ]; then
    $NODEJS `dirname $0`/scripts/aira_deploy.js "$@" 
    exit 0
fi

echo "nodejs binary isn't found in PATH"
exit 1
