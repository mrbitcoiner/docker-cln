#!/usr/bin/env bash
####################
set -e
####################
readonly SPARKO_BIN_PATH=/app/data/sparko
readonly CLN_CONFIG_PATH=${HOME}/.lightning/config
readonly AMD64_DOWNLOAD='https://github.com/fiatjaf/sparko/releases/download/v2.9/sparko_linux_amd64'
readonly ARM64_DOWNLOAD='https://github.com/fiatjaf/sparko/releases/download/v2.9/sparko_linux_arm64'
readonly AMD64_CHECKSUM='2db2b4eede6f0a8d519cf24720ee697a4b224d975437479c65d25e578aedb5c2'
readonly ARM64_CHECKSUM='15ad564733a817befede0c672bafa7530a248165a1020538208ca3e413555db0'
readonly SPARKO_PORT=10050
####################
mkdirs(){
  mkdir -p ${SPARKO_BIN_PATH}
}
download(){
  if [ -e ${SPARKO_BIN_PATH}/sparko ]; then return 0; fi
  case "$(arch)" in
    aarch64) 
      cd ${SPARKO_BIN_PATH}
      wget ${ARM64_DOWNLOAD} -O sparko
      if ! [ "${ARM64_CHECKSUM}" == "$(sha256sum ${SPARKO_BIN_PATH}/sparko | awk '{print $1}')" ]; then 
        printf 'Sparko checksum does not match\n' 1>&2; return 1
      fi
    ;;
    x86_64) 
      cd ${SPARKO_BIN_PATH}
      wget ${AMD64_DOWNLOAD} -O sparko
      if ! [ "${AMD64_CHECKSUM}" == "$(sha256sum ${SPARKO_BIN_PATH}/sparko | awk '{print $1}')" ]; then 
        printf 'Sparko checksum does not match\n' 1>&2; return 1
      fi
    ;;
  esac
}
set_permissions(){
  chmod +x ${SPARKO_BIN_PATH}/sparko
}
set_cln_config(){
  if ! grep '^plugin=/app/data/sparko/sparko$' ${CLN_CONFIG_PATH} > /dev/null; then
    cat << EOF >> ${CLN_CONFIG_PATH}
plugin=${SPARKO_BIN_PATH}/sparko
sparko-host=0.0.0.0
sparko-port=10050
sparko-login=cln:zMfDBA4EwNmu7r8NYRhgggbdTBieMYI5
EOF
  fi
}
####################
mkdirs
download
set_permissions
set_cln_config
