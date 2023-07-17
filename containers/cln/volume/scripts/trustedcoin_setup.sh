#!/usr/bin/env bash
####################
set -e
####################
readonly TRUSTEDCOIN_AARCH64='https://github.com/nbd-wtf/trustedcoin/releases/download/v0.6.1/trustedcoin-v0.6.1-linux-arm64.tar.gz'
readonly TRUSTEDCOIN_X86_64='https://github.com/nbd-wtf/trustedcoin/releases/download/v0.6.1/trustedcoin-v0.6.1-linux-amd64.tar.gz'
readonly TRUSTEDCOIN_AARCH64_CHECKSUM='b55afcda78aad02ff839634cd33a92b4733eade89d6ec2ed3599a59f13a7bc0b'
readonly TRUSTEDCOIN_X86_64_CHECKSUM='274a16be5b103d889909cc0ebf61bc7353b903f82133b2591b65422dd05704ff'
readonly CLN_CONFIG_PATH="${HOME}/.lightning/config"
readonly TRUSTEDCOIN_PATH='/app/data/trustedcoin'
####################
verify_enabled(){
  if [ "${TRUSTEDCOIN}" != 'enabled' ]; then exit 0; fi 
}
check_cln_network(){
  case "${CLN_NETWORK}" in
    mainnet) ;;
    testnet) ;;
    *) printf "Trustedcoin not supported for network: ${CLN_NETWORK}\n" 1>&2; return 1 ;;
  esac
}
download(){
  mkdir -p ${TRUSTEDCOIN_PATH}
  if [ -e ${TRUSTEDCOIN_PATH}/trustedcoin ]; then return 0; fi;
  cd ${TRUSTEDCOIN_PATH}
  case "$(arch)" in
    aarch64)
      wget ${TRUSTEDCOIN_AARCH64} -O trustedcoin.tar.gz
      if ! [ "${TRUSTEDCOIN_AARCH64_CHECKSUM}" == "$(sha256sum trustedcoin.tar.gz | awk '{print $1}')" ]; then
        printf 'Invalid trustedcoin checksum\n' 1>&2; return 1
      fi
    ;;
    x86_64)
      wget ${TRUSTEDCOIN_X86_64} -O trustedcoin.tar.gz
      if ! [ "${TRUSTEDCOIN_X86_64_CHECKSUM}" == "$(sha256sum trustedcoin.tar.gz | awk '{print $1}')" ]; then
        printf 'Invalid trustedcoin checksum\n' 1>&2; return 1
      fi
    ;;
    *) printf "Unsupported arch: $(arch)\n" 1>&2; return 1 ;;
  esac
  tar -xf trustedcoin.tar.gz
  chmod +x trustedcoin
}
install(){
  /app/scripts/set_dotenv.sh "${CLN_CONFIG_PATH}" "disable-plugin" "bcli"
  if ! grep "^plugin=${TRUSTEDCOIN_PATH}/trustedcoin$" ${CLN_CONFIG_PATH} > /dev/null; then 
    cat << EOF >> ${CLN_CONFIG_PATH}
plugin=${TRUSTEDCOIN_PATH}/trustedcoin
EOF
  fi
}
setup(){
  verify_enabled
  check_cln_network
  download
  install
}
####################
setup
