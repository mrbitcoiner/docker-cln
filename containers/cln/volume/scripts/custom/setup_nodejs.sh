#!/usr/bin/env bash
####################
set -e
####################
readonly NODEJS_DATA_PATH='/app/data/nodejs'
readonly NODEJS_ARM64_DOWNLOAD='https://nodejs.org/dist/v18.16.1/node-v18.16.1-linux-arm64.tar.xz'
readonly NODEJS_AMD64_DOWNLOAD='https://nodejs.org/dist/v18.16.1/node-v18.16.1-linux-x64.tar.xz'
readonly NODEJS_ARM64_CHECKSUM='144eb4103e0193de8a41187817261d35970f1a13a11e779e16a4f1d9c99bcc82'
readonly NODEJS_AMD64_CHECKSUM='ecfe263dbd9c239f37b5adca823b60be1bb57feabbccd25db785e647ebc5ff5e'
####################
mkdirs(){
  mkdir -p ${NODEJS_DATA_PATH}
}
download_nodejs(){
  if [ -e ${NODEJS_DATA_PATH}/nodejs.tar.xz ]; then return 0; fi
  cd ${NODEJS_DATA_PATH}
  case "$(arch)" in
    aarch64)
      wget ${NODEJS_ARM64_DOWNLOAD} -O nodejs.tar.xz
      if ! [ "${NODEJS_ARM64_CHECKSUM}" == "$(sha256sum nodejs.tar.xz | awk '{print $1}')" ]; then
        printf 'NodeJs checksum does not match' 1>&2; return 1
      fi
      tar -xvf nodejs.tar.xz
      mv node-v* nodejs
    ;;
    x86_64)
      wget ${NODEJS_AMD64_DOWNLOAD} -O nodejs.tar.xz
      if ! [ "${NODEJS_AMD64_CHECKSUM}" == "$(sha256sum nodejs.tar.xz | awk '{print $1}')" ]; then
        printf 'NodeJs checksum does not match' 1>&2; return 1
      fi
      tar -xvf nodejs.tar.xz
      mv node-v* nodejs
    ;;
  esac
}
add_nodejs_to_path(){
  if ! [ -e /app/data/PATH.env ]; then touch /app/data/PATH.env; fi
  if ! grep  "^PATH=.*${NODEJS_DATA_PATH}/nodejs/bin.*$" /app/data/PATH.env > /dev/null 2>&1; then
    source /app/data/PATH.env
    cat << EOF > /app/data/PATH.env
PATH=${NODEJS_DATA_PATH}/nodejs/bin:${PATH}
EOF
  fi
}
####################
mkdirs
download_nodejs
add_nodejs_to_path
# clone_cln_rest
# install_cln_rest

