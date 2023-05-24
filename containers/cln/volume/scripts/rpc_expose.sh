#!/usr/bin/env bash
####################
set -e
####################
readonly CLN_DATA='/app/data/.lightning'
####################
check_network(){
  case "${CLN_NETWORK}" in
    mainnet) printf 'RPC exposure over TCP not available on mainnet\n' 1>&2; return 1 ;;
    testnet) ;;
    regtest) ;;
    *) printf "RPC can only be exposed over TPC on testnet and regtest. Got: ${CLN_NETWORK}\n" 1>&2; return 1 ;;
  esac
}
check_rpc_enabled(){
  if ! echo ${CLN_EXPOSE_RPC} | grep '^enabled$' > /dev/null; then exit 0; fi
}
check_variables(){
  if [ -z "${CLN_EXPOSE_RPC}" ] || [ -z "${CLN_INT_RPC_PORT}" ]; then
    printf "Expected CLN_RPC env variables to be defined\n" 1>&2
    return 1
  fi
}
start_forwarding(){
  socat TCP-LISTEN:${CLN_INT_RPC_PORT},fork,reuseaddr UNIX-CONNECT:${CLN_DATA}/${CLN_NETWORK}/lightning-rpc &
}
setup(){
  check_rpc_enabled
  check_network
  check_variables
}
####################
setup
start_forwarding
