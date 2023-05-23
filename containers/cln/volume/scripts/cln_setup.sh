#!/usr/bin/env bash
####################
set -e
####################
readonly CLN_DATA=/app/data/.lightning
readonly CLN_CLI_DATA=${HOME}/.lightning
readonly BASE_CFG_DIR=/app/config/cln
readonly BASE_TOR_DIR=/app/data/tor/lightning
readonly LN_TOR_PORT=9735
####################
set_lightning_cli_cfg(){
  ln -sf ${CLN_DATA} ${CLN_CLI_DATA}
}
copy_base_cfg(){
  case ${CLN_NETWORK} in
    mainnet) cat ${BASE_CFG_DIR}/${CLN_NETWORK} > ${CLN_DATA}/config ;;
    testnet) cat ${BASE_CFG_DIR}/${CLN_NETWORK} > ${CLN_DATA}/config ;;
    regtest) cat ${BASE_CFG_DIR}/${CLN_NETWORK} > ${CLN_DATA}/config ;;
    *) printf 'Expected CLN_NETWORK: [ mainnet | testnet | regtest ]\n' 1>&2; return 1 ;;
  esac
}
set_cln_alias(){
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "alias" "${CLN_ALIAS}" 
}
set_tor_config(){
  if ! echo ${TOR_PROXY} | grep '^enabled$' > /dev/null; then
    return 0
  fi
  local tor_hostname_path="${BASE_TOR_DIR}/${CLN_NETWORK}/hostname"
  if ! [ -e ${tor_hostname_path} ]; then
    printf "Not found hostname at: ${tor_hostname_path}\n" 1>&2
    return 1
  fi
  local tor_hostname=$(cat ${tor_hostname_path})
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "announce-addr" "${tor_hostname}:${LN_TOR_PORT}" 
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "proxy" "127.0.0.1:9050" 
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "always-use-proxy" "true" 
}
trustedcoin_enabled(){
  echo ${CLN_TRUSTEDCOIN_PLUGIN} | grep '^enabled$' > /dev/null
}
set_trustedcoin_plugin(){
  if trustedcoin_enabled; then /app/scripts/trustedcoin_setup.sh ${CLN_DATA}
  elif [ -e "${CLN_DATA}/plugins/trustedcoin" ]; then
    rm -r ${CLN_DATA}/plugins/trustedcoin
  fi
}
setup(){
  mkdir -p ${CLN_DATA}/plugins
  set_lightning_cli_cfg
  copy_base_cfg
  set_cln_alias
  set_tor_config
  set_trustedcoin_plugin
}
####################
setup
