# DOCKER-CLN
## Build and run Core Lightning from source

### Are you without a full node? Just enable trustedcoin in .env

### Features
* AARCH64 and X86_64 processors support
* lightning-cli wrapper (check ./control.sh help)

### Optional features (check .env):
* Trustedcoin plugin
* Sparko plugin
* Cln Rest plugin
* Expose Core Lightning unix socket via TCP
* Wrap TCP socket into a unix socket for development purposes
* Integration with [docker-rtl](https://github.com/mrbitcoiner/docker-rtl)

### Getting Started
* Setup [docker-bitcoind](https://github.com/mrbitcoiner/docker-bitcoind) (Optional)

* Observation: Follow control script instructions.

* Clone and open this repository
```bash
git clone https://github.com/mrbitcoiner/docker-cln && cd docker-cln
```

* Build the image
```bash
./control.sh build
```

* Start the container with
```bash
./control.sh up
```

* Run lightning-cli commands 
```bash
./control.sh lightning-cli 'method' '{"param1": "value1", "param2": "value2"}'
```

* Stop with
```bash
./control.sh down
```

### Updating

* Stop the container, rebuild the image and start the container
```bash
./control.sh down || true && ./control.sh build && ./control.sh up
```
