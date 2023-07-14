#!/usr/bin/env bash
####################
set -e
####################
readonly TOR_DIR=/app/data/tor/lightning
readonly SERVICE_NAME=lightning
readonly HIDDEN_PORT=9735
readonly INT_PORT=9735
###################
check_cln_network(){
  case ${CLN_NETWORK} in
    mainnet) ;;
    testnet) ;;
    regtest) ;;
    *) printf 'Expected CLN_NETWORK: [ mainnet | testnet | regtest ]\n' 1>&2; return 1 ;;
  esac
}
set_tor_config(){
  cat << EOF >> /etc/tor/torrc
HiddenServiceDir ${TOR_DIR}/${CLN_NETWORK}
HiddenServicePort ${HIDDEN_PORT} 127.0.0.1:${INT_PORT}
EOF
}
start_tor(){
  su -c 'tor > /dev/null &' ${CONTAINER_USER}
}
setup(){
  check_cln_network
  su -c "mkdir -p ${TOR_DIR}" ${CONTAINER_USER}
  set_tor_config
  start_tor
}
###################
setup
