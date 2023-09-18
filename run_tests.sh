#!/bin/sh

echo "Install dependencies"
npm install --silence

test_directory=./test
exit_code=0

for entry in "$test_directory"/*.test.js
do
  echo "Running test: $entry"
  npx hardhat test --network neonlabs $entry
  if [ $? -ne 0 ]; then
    exit_code=$?
  fi
  sleep 5
done

exit $exit_code