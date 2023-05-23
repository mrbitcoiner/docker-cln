# DOCKER-CLN
## Build and run core lightning from source

### Don't want to run a full node? Just enable trustedcoin in .env and your problems are solved!
* Setup bitcoind
```bash
https://github.com/mrbitcoiner/docker-bitcoind
```

* Clone this repository
```bash
git clone https://github.com/mrbitcoiner/docker-cln
```

* Copy the .env.example file to .env and check the configurations

* Start with
```bash
./control.sh up
```

* Run lightning-cli commands 
```bash
./control.sh cli_wrapper 'getinfo'
```

* Stop with
```bash
./control.sh down
```
