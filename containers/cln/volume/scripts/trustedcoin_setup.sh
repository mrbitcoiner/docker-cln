#!/usr/bin/env bash
####################
set -e
####################
readonly TRUSTEDCOIN_AARCH64='https://github.com/nbd-wtf/trustedcoin/releases/download/v0.6.1/trustedcoin-v0.6.1-linux-arm64.tar.gz'
readonly TRUSTEDCOIN_X86_64='https://github.com/nbd-wtf/trustedcoin/releases/download/v0.6.1/trustedcoin-v0.6.1-linux-amd64.tar.gz'
readonly CLN_DATA="${1}"
####################
check_cln_network(){
  case "${CLN_NETWORK}" in
    mainnet) ;;
    testnet) ;;
    *) printf "Trustedcoin not supported for network: ${CLN_NETWORK}\n" 1>&2; return 1 ;;
  esac
}
check_args(){
  if [ -z "${CLN_DATA}" ]; then printf 'Expected: [CLN_DATA]\n' 1>&2; return 1; fi
}
download_and_install(){
  if [ -e "${CLN_DATA}/plugins/trustedcoin" ]; then return 0; fi;
  cd /tmp
  case "$(arch)" in
    aarch64) wget ${TRUSTEDCOIN_AARCH64} ;;
    x86_64) wget ${TRUSTEDCOIN_X86_64} ;;
    *) printf "Unsupported arch: $(arch)\n" 1>&2; return 1 ;;
  esac
  tar -xf trustedcoin*
  chmod +x trustedcoin
  mv trustedcoin ${CLN_DATA}/plugins
}
set_config(){
  /app/scripts/set_dotenv.sh "${CLN_DATA}/config" "disable-plugin" "bcli"
}
setup(){
  check_cln_network
  download_and_install
  set_config
}
####################
check_args
setup


