#!/usr/bin/env bash
####################
set -e
####################
chmod +x scripts/*.sh
####################
source .env
readonly CONTAINER_NAMES=("${CLN_CONTAINER_NAME}")
readonly CLN_CONTAINER='cln'  
readonly CONTAINERS=("${CLN_CONTAINER}")
####################
print_err(){
  if [ -z "${1}" ]; then printf 'Expected: [msg]\n' 1>&2; return 1; fi
  printf "${1}\n" 1>&2
  return 1
}
check_env(){
  if [ -z ${CLN_CONTAINER_NAME} ]; then printf 'Undefined env CLN_CONTAINER_NAME\n' 1>&2; return 1; fi
  if [ -z ${NETWORK} ]; then printf 'Undefined env NETWORK\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_CLI_PATH} ]; then printf 'Undefined env BITCOIN_CLI_PATH\n' 1>&2; return 1; fi
  if [ -z ${CLN_EXPOSE_RPC} ]; then printf 'Undefined env CLN_EXPOSE_RPC\n' 1>&2; return 1; fi
  if [ -z ${CLN_INT_RPC_PORT} ]; then printf 'Undefined env CLN_INT_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${CLN_EXT_RPC_PORT} ]; then printf 'Undefined env CLN_EXT_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_HOSTNAME} ]; then printf 'Undefined env BITCOIN_RPC_HOSTNAME\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_PORT} ]; then printf 'Undefined env BITCOIN_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_USERNAME} ]; then printf 'Undefined env BITCOIN_RPC_USERNAME\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_PASSWORD} ]; then printf 'Undefined env BITCOIN_RPC_PASSWORD\n' 1>&2; return 1; fi
  if [ -z ${CLN_NETWORK} ]; then printf 'Undefined env CLN_NETWORK\n' 1>&2; return 1; fi
  if [ -z ${CLN_ALIAS} ]; then printf 'Undefined env CLN_ALIAS\n' 1>&2; return 1; fi
  if [ -z ${CLN_TRUSTEDCOIN_PLUGIN} ]; then printf 'Undefined env CLN_TRUSTEDCOIN_PLUGIN\n' 1>&2; return 1; fi
  if [ -z ${CLN_BASE_FEE_MSAT} ]; then printf 'Undefined env CLN_BASE_FEE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_PPM_FEE} ]; then printf 'Undefined env CLN_PPM_FEE\n' 1>&2; return 1; fi
  if [ -z ${CLN_MIN_CH_CAPACITY_SAT} ]; then printf 'Undefined env CLN_MIN_CH_CAPACITY_SAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MAX_HTLC_INFLIGHT} ]; then printf 'Undefined env CLN_MAX_HTLC_INFLIGHT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MAX_HTLC_SIZE_MSAT} ]; then printf 'Undefined env CLN_MAX_HTLC_SIZE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MIN_HTLC_SIZE_MSAT} ]; then printf 'Undefined env CLN_MIN_HTLC_SIZE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${TOR_PROXY} ]; then printf 'Undefined env TOR_PROXY\n' 1>&2; return 1; fi
}
setup_directories(){
  for i in ${CONTAINERS[@]}; do
    mkdir -p ./containers/${i}/volume/scripts
    mkdir -p ./containers/${i}/volume/config
  done
}
set_script_permissions(){
  for i in ${CONTAINERS[@]}; do
    if [ -e ./containers/${i}/volume/scripts/init.sh ]; then
      chmod +x ./containers/${i}/volume/scripts/*.sh
    fi
    if [ -e ./containers/${i}/volume/scripts/custom/init.sh ]; then
      chmod +x ./containers/${i}/volume/scripts/custom/*.sh
    fi
  done
  if [ -e ./scripts/custom/init.sh ]; then
    chmod +x ./scripts/custom/*.sh
  fi
}
build_images(){
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g) \
    --build-arg BITCOIN_RPC_HOSTNAME=${BITCOIN_RPC_HOSTNAME} \
    --build-arg BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT} \
    --build-arg BITCOIN_RPC_USERNAME=${BITCOIN_RPC_USERNAME} \
    --build-arg BITCOIN_RPC_PASSWORD=${BITCOIN_RPC_PASSWORD} \
    --build-arg CLN_NETWORK=${CLN_NETWORK} \
    --build-arg CLN_ALIAS=${CLN_ALIAS} \
    --build-arg CLN_TRUSTEDCOIN_PLUGIN=${CLN_TRUSTEDCOIN_PLUGIN} \
    --build-arg CLN_EXPOSE_RPC=${CLN_EXPOSE_RPC} \
    --build-arg CLN_INT_RPC_PORT=${CLN_INT_RPC_PORT} \
    --build-arg CLN_BASE_FEE_MSAT=${CLN_BASE_FEE_MSAT} \
    --build-arg CLN_PPM_FEE=${CLN_PPM_FEE} \
    --build-arg CLN_MIN_CH_CAPACITY_SAT=${CLN_MIN_CH_CAPACITY_SAT} \
    --build-arg CLN_MAX_HTLC_INFLIGHT=${CLN_MAX_HTLC_INFLIGHT} \
    --build-arg CLN_MAX_HTLC_SIZE_MSAT=${CLN_MAX_HTLC_SIZE_MSAT} \
    --build-arg CLN_MIN_HTLC_SIZE_MSAT=${CLN_MIN_HTLC_SIZE_MSAT} \
    --build-arg TOR_PROXY=${TOR_PROXY}
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
  local destination=./containers/${CLN_CONTAINER}/volume/data/bitcoin
  if ! [ -e ${destination}/bitcoin-cli ]; then
    mkdir -p ${destination}
    cp ${BITCOIN_CLI_PATH} ${destination}/
  fi
}
generate_docker_compose(){
  cat << EOF > docker-compose.yml
services:
  cln:
    container_name: ${CLN_CONTAINER_NAME} 
    build: ./containers/cln
    volumes:
      - ./containers/cln/volume:/app
    ports:
      - ${CLN_EXT_RPC_PORT}:${CLN_INT_RPC_PORT}
    networks:
      - cln

networks:
  cln:
    name: ${NETWORK} 
    external: true
EOF
}
run_custom(){
  if [ -e ./scripts/custom/init.sh ]; then
    ./scripts/custom/init.sh
  fi
}
####################
boot(){
  check_env
  create_network
  generate_docker_compose
  setup_directories
  set_script_permissions
  copy_bitcoin_cli
  run_custom
  build_images
  start_containers
}
shutdown(){
  scripts/gracefully_stop.sh "${CONTAINER_NAMES}"
}
clean(){
  printf 'Are you sure? (N/y): '
  read input
  if ! echo ${input} | grep '^y$'; then
    printf 'Abort!\n' 1>&2; return 1
  fi
  for i in "${CONTAINERS[@]}"; do
    rm -rfv ./containers/${i}/volume/data
  done
}
cli_wrapper(){
  if [ -z "${1}" ]; then printf 'Expected: [ command ]\n' 1>&2; return 1; fi
  local command="${1}"
  docker exec -it ${CLN_CONTAINER_NAME} su -c 'lightning-cli '"${command}"'' ${USER}
}
create_cln_socket(){
  if ! echo "${CLN_EXPOSE_RPC}" | grep '^enabled$' 1> /dev/null; then return 0; fi
  socat UNIX-LISTEN:cln.sock,fork,reuseaddr TCP:127.0.0.1:${CLN_EXT_RPC_PORT} &
  echo "$!" > sock.pid
}
stop_cln_socket(){
  if ! [ -e sock.pid ]; then printf 'Socket does not exist\' 1>&2; return 1; fi
  let pid="$(cat sock.pid)"
  if kill -0 ${pid}; then
    kill -2 ${pid}
    rm sock.pid
  fi
}
####################
case ${1} in
  up) boot ;;
  down) shutdown ;;
  clean) clean ;;
  cli_wrapper) cli_wrapper "${2}" ;;
  sock_forward) create_cln_socket ;;
  sock_stop) stop_cln_socket ;;
  nop) ;;
  *) printf 'Expected: [ up | down | sock_forward | sock_stop | cli_wrapper | clean ]\n' 1>&2; return 1 ;;
esac
