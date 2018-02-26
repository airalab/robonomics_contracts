## Airalab smart contracts 

[![Build Status](https://travis-ci.org/airalab/core.svg?branch=master)](https://travis-ci.org/airalab/core)
[![GitHub release](https://img.shields.io/github/release/airalab/core.svg)]()

> Keep all significant smart-contracts in this repository.

- [API Reference](https://airalab.github.io/core/docs)
- [ABIs](https://github.com/airalab/core/tree/master/abi)
- [EthPM](https://www.ethpm.com/registry)

## How to build
Tested on Truffle@3.4.11     
To build a single package run in it's directory:
```
truffle compile
```

To install dependencies:
```
truffle install airalab-token airalab-common
```

To publish a package to EthPM register run:
```
truffle publish
```

Configuration of RPC is located in truffle.js file. Here's links to our packages in EthPM:   
- [airalab-common](https://www.ethpm.com/registry/packages/39)
- [airalab-token](https://www.ethpm.com/registry/packages/40)
- [airalab-liability](https://www.ethpm.com/registry/packages/41)
