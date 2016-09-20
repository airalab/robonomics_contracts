#!/bin/sh

## Most
node -h 1>/dev/null 2>/dev/null && node `dirname $0`/scripts/aira_deploy.js "$@"

## Ubuntu
nodejs -h 1>/dev/null 2>/dev/null && nodejs `dirname $0`/scripts/aira_deploy.js "$@"
