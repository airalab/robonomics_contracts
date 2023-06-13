#!/bin/sh

echo "Install dependencies: "
npm install

truffle compile

echo "TEST RUN: "
truffle test