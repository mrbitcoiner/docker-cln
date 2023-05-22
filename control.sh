#!/usr/bin/env bash
####################
set -e
####################
readonly CONTAINERS=('cln')
readonly NETWORK='bitcoin'
####################
print_err(){
  if [ -z "${1}" ]; then printf 'Expected: [msg]\n' 1>&2; return 1; fi
  printf "${1}\n" 1>&2
  return 1
}
setup_directories(){
  for i in ${CONTAINERS[@]}; do
    mkdir -p ./containers/${i}/volume/data/config
    mkdir -p ./containers/${i}/volume/scripts
    mkdir -p ./containers/${i}/volume/config
  done
}
set_script_permissions(){
  for i in ${CONTAINERS[@]}; do
    if [ -e ./containers/${i}/volume/scripts/init.sh ]; then
      chmod +x ./containers/${i}/volume/scripts/*.sh
    fi
  done
}
copy_env(){
  if ! [ -e .env ]; then
    cp .env.example .env
  fi
}
env_set(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then print_err "Expected: [ key ] [ value ]"; fi
  local key="${1}"
  local value="${2}"
  local FILE='.env'
  if ! grep '^'${key}'=.*$' ${FILE} > /dev/null; then
    printf "${key}=${value}\n" >> ${FILE}
  else
    sed -i'.old' -e 's/^'${key}'=.*$/'${key}=${value}'/g' ${FILE}
  fi
}
set_user_env(){
  env_set "CONTAINER_UID" "$(id -u)"
  env_set "CONTAINER_GID" "$(id -g)"
  env_set "CONTAINER_USER" "${USER}"
}
get_env(){
  if [ -z "${1}" ]; then print_err 'Expected: [ env_key ]'; fi
  local key="${1}"
  local FILE='.env'
  if ! grep '^'${key}'=.*$' ${FILE} > /dev/null; then print_err "env_key not found: ${key}"
  else
    local key_value="$(grep '^'${key}'=.*$' ${FILE})"
    printf "${key_value}"
  fi 
}
set_args(){
  if [ -z ${1} ] || [ -z ${2} ]; then print_err 'Expected: [ network | tor_proxy ]'; fi 
  local network="${1}"
  local tor_proxy="${2}"
  case "${network}" in
    mainnet) env_set 'CLN_NETWORK' "${network}" ;;
    testnet) env_set 'CLN_NETWORK' "${network}" ;;
    *) print_err 'Expected network: [ mainnet | testnet ]' ;;
  esac
  case "${tor_proxy}" in
    enabled) env_set 'TOR_PROXY' "${tor_proxy}" ;;
    disabled) env_set 'TOR_PROXY' "${tor_proxy}" ;;
    *) print_err 'Expected tor_proxy: [ enabled | disabled ]' ;;
  esac
  
}
build_images(){
  docker-compose build \
    --build-arg $(get_env 'CONTAINER_USER') \
    --build-arg $(get_env 'CONTAINER_UID') \
    --build-arg $(get_env 'CONTAINER_GID') \
    --build-arg $(get_env 'BITCOIN_RPC_HOSTNAME') \
    --build-arg $(get_env 'BITCOIN_RPC_PORT') \
    --build-arg $(get_env 'BITCOIN_RPC_USERNAME') \
    --build-arg $(get_env 'BITCOIN_RPC_PASSWORD') \
    --build-arg $(get_env 'CLN_NETWORK') \
    --build-arg $(get_env 'CLN_ALIAS') \
    --build-arg $(get_env 'CLN_TRUSTEDCOIN_PLUGIN') \
    --build-arg $(get_env 'TOR_PROXY')
}
create_network(){
  if ! docker network ls | grep "${NETWORK}" > /dev/null; then
    docker network create -d bridge ${NETWORK}
  fi
}
start_containers(){
  docker-compose up \
    --remove-orphans \
    &
}
copy_bitcoin_cli(){
  if ! get_env "BITCOIN_CLI_PATH"; then
    return 0
  fi
  local $(get_env "BITCOIN_CLI_PATH")
  local destination=./containers/cln/volume/data/bitcoin
  if ! [ -e ${destination}/bitcoin-cli ]; then
    mkdir -p ${destination}
    cp ${BITCOIN_CLI_PATH} ${destination}/
  fi
 }
boot(){
  copy_env
  create_network
  setup_directories
  set_script_permissions
  set_user_env
  set_args "${1}" "${2}"
  copy_bitcoin_cli
  build_images
  start_containers
}
gracefully_shutdown(){
  for i in "${CONTAINERS[@]}"; do
    printf 'Implement gracefully shutdown\n'
    return 1
  done
}
shutdown(){
  if ! gracefully_shutdown; then
    docker-compose down
    print_err 'Force shutdown'
  else
    for i in "${CONTAINERS[@]}"; do
      docker rm "${i}"
    done
  fi
}
clean(){
  for i in "${CONTAINERS[@]}"; do
    rm -rfv ./containers/${i}/volume/data
  done
}
####################
case ${1} in
  up) boot ${2} ${3} ;;
  down) shutdown ;;
  clean) clean ;;
  nop) ;;
  *) print_err 'Expected: [ up | down | clean ]' ;;
esac

