#!/bin/sh

# echo "Install dependencies"
# npm install --quiet

test_directory=./test

for entry in "$test_directory"/*.test.js
do
  echo "Running test: $entry"
  npx hardhat test --network neonlabs $entry
  sleep 5
done