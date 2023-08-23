Robonomics platform contracts 
=============================

[![Build Status](https://travis-ci.org/airalab/robonomics_contracts.svg?branch=master)](https://travis-ci.org/airalab/robonomics_contracts)
[![GitHub release](https://img.shields.io/github/release/airalab/robonomics_contracts/all.svg)]()

> Keep all significant smart-contracts in this repository.

How to use
----------


To build contracts run in it's directory:

```
npx hardhat compile
```


To run testing framework:

```
npx hardhat test --network neonlabs
```

Notice
------

* Malleable ECDSA signatures is vulnerable, please check it before using, [description](https://yondon.blog/2019/01/01/how-not-to-use-ecdsa/). 
