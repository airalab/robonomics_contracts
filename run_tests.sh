#!/bin/sh

echo "Install dependencies: "
npm install

echo "TEST RUN: "
npx hardhat test --network neonlabs