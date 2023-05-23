# DOCKER-CLN
## Build and run core lightning from source

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
docker exec -it cln su -c "lightning-cli getinfo" ${USER}
```

* Stop with
```bash
./control.sh down
```
