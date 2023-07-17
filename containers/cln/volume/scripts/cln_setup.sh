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
mkdirs(){
  mkdir -p ${CLN_DATA}
}
set_config(){
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "${1}" "${2}" 
}
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
  set_config "alias" "${CLN_ALIAS}" 
}
set_tor_config(){
  if [ "${TOR_PROXY}" != 'enabled' ]; then return 0; fi
  local tor_hostname_path="${BASE_TOR_DIR}/${CLN_NETWORK}/hostname"
  if ! [ -e ${tor_hostname_path} ]; then
    printf "Not found hostname at: ${tor_hostname_path}\n" 1>&2
    return 1
  fi
  local tor_hostname=$(cat ${tor_hostname_path})
  set_config "announce-addr" "${tor_hostname}:${LN_TOR_PORT}" 
  set_config "proxy" "127.0.0.1:9050" 
  set_config "always-use-proxy" "true" 
}
set_min_ch_cap(){
  set_config "min-capacity-sat" "${CLN_MIN_CH_CAPACITY_SAT}"
}
set_max_htlc_inflight(){
  set_config "max-concurrent-htlcs" "${CLN_MAX_HTLC_INFLIGHT}"
}
set_max_htlc_size(){
  if [ "${CLN_MAX_HTLC_SIZE_MSAT}" == '0' ]; then return 0; fi 
  set_config "htlc-maximum-msat" "${CLN_MAX_HTLC_SIZE_MSAT}"
}
set_min_htlc_size(){
  set_config "htlc-minimum-msat" "${CLN_MIN_HTLC_SIZE_MSAT}"
}
set_base_fee(){
  set_config "fee-base" "${CLN_BASE_FEE_MSAT}"
}
set_ppm_fee(){
  set_config "fee-per-satoshi" "${CLN_PPM_FEE}"
}
setup(){
  mkdirs
  set_lightning_cli_cfg
  copy_base_cfg
  set_cln_alias
  set_min_ch_cap
  set_max_htlc_inflight
  set_max_htlc_size
  set_min_htlc_size
  set_base_fee
  set_ppm_fee
  set_tor_config
}
####################
setup
