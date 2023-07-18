#!/usr/bin/env bash
####################
set -e
####################
chmod +x scripts/*.sh
####################
if [ -e .env ]; then
  source .env
fi
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
  if ! [ -e .env ]; then printf 'You must copy the .env.example file to .env\n' 1>&2; return 1; fi
  if [ -z ${CLN_CONTAINER_NAME} ]; then printf 'Undefined env CLN_CONTAINER_NAME\n' 1>&2; return 1; fi
  if [ -z ${NETWORK} ]; then printf 'Undefined env NETWORK\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_CLI_PATH} ]; then printf 'Undefined env BITCOIN_CLI_PATH\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_HOSTNAME} ]; then printf 'Undefined env BITCOIN_RPC_HOSTNAME\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_PORT} ]; then printf 'Undefined env BITCOIN_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_USERNAME} ]; then printf 'Undefined env BITCOIN_RPC_USERNAME\n' 1>&2; return 1; fi
  if [ -z ${BITCOIN_RPC_PASSWORD} ]; then printf 'Undefined env BITCOIN_RPC_PASSWORD\n' 1>&2; return 1; fi
  if [ -z ${CLN_NETWORK} ]; then printf 'Undefined env CLN_NETWORK\n' 1>&2; return 1; fi
  if [ -z ${CLN_ALIAS} ]; then printf 'Undefined env CLN_ALIAS\n' 1>&2; return 1; fi
  if [ -z ${TRUSTEDCOIN} ]; then printf 'Undefined env CLN_TRUSTEDCOIN_PLUGIN\n' 1>&2; return 1; fi
  if [ -z ${CLN_BASE_FEE_MSAT} ]; then printf 'Undefined env CLN_BASE_FEE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_PPM_FEE} ]; then printf 'Undefined env CLN_PPM_FEE\n' 1>&2; return 1; fi
  if [ -z ${CLN_MIN_CH_CAPACITY_SAT} ]; then printf 'Undefined env CLN_MIN_CH_CAPACITY_SAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MAX_HTLC_INFLIGHT} ]; then printf 'Undefined env CLN_MAX_HTLC_INFLIGHT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MAX_HTLC_SIZE_MSAT} ]; then printf 'Undefined env CLN_MAX_HTLC_SIZE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${CLN_MIN_HTLC_SIZE_MSAT} ]; then printf 'Undefined env CLN_MIN_HTLC_SIZE_MSAT\n' 1>&2; return 1; fi
  if [ -z ${TOR_PROXY} ]; then printf 'Undefined env TOR_PROXY\n' 1>&2; return 1; fi
  if [ -z ${SPARKO} ]; then printf 'Undefined env SPARKO\n' 1>&2; return 1; fi
  if [ -z ${SPARKO_EXT_PORT} ]; then printf 'Undefined env SPARKO_EXT_PORT\n' 1>&2; return 1; fi
  if [ -z ${SPARKO_INT_PORT} ]; then printf 'Undefined env SPARKO_INT_PORT\n' 1>&2; return 1; fi
  if [ -z ${SPARKO_USER} ]; then printf 'Undefined env SPARKO_USER\n' 1>&2; return 1; fi
  if [ -z ${SPARKO_PASSWORD} ]; then printf 'Undefined env SPARKO_PASSWORD\n' 1>&2; return 1; fi
  if [ -z ${CLN_REST} ]; then printf 'Undefined env CLN_REST\n' 1>&2; return 1; fi
  if [ -z ${CLN_REST_INT_PORT} ]; then printf 'Undefined env CLN_REST_INT_PORT\n' 1>&2; return 1; fi
  if [ -z ${CLN_REST_INT_DOCPORT} ]; then printf 'Undefined env CLN_REST_INT_DOCPORT\n' 1>&2; return 1; fi
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
  if [ "${TRUSTEDCOIN}" == 'enabled' ]; then return 0; fi
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
    environment:
      - BITCOIN_RPC_HOSTNAME=${BITCOIN_RPC_HOSTNAME} 
      - BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT} 
      - BITCOIN_RPC_USERNAME=${BITCOIN_RPC_USERNAME} 
      - BITCOIN_RPC_PASSWORD=${BITCOIN_RPC_PASSWORD} 
      - CLN_NETWORK=${CLN_NETWORK} 
      - CLN_ALIAS=${CLN_ALIAS} 
      - TRUSTEDCOIN=${TRUSTEDCOIN} 
      - CLN_EXPOSE_RPC=${CLN_EXPOSE_RPC} 
      - CLN_INT_RPC_PORT=${CLN_INT_RPC_PORT} 
      - CLN_BASE_FEE_MSAT=${CLN_BASE_FEE_MSAT} 
      - CLN_PPM_FEE=${CLN_PPM_FEE} 
      - CLN_MIN_CH_CAPACITY_SAT=${CLN_MIN_CH_CAPACITY_SAT} 
      - CLN_MAX_HTLC_INFLIGHT=${CLN_MAX_HTLC_INFLIGHT} 
      - CLN_MAX_HTLC_SIZE_MSAT=${CLN_MAX_HTLC_SIZE_MSAT} 
      - CLN_MIN_HTLC_SIZE_MSAT=${CLN_MIN_HTLC_SIZE_MSAT} 
      - TOR_PROXY=${TOR_PROXY}
      - SPARKO=${SPARKO}
      - SPARKO_EXT_PORT=${SPARKO_EXT_PORT} 
      - SPARKO_INT_PORT=${SPARKO_INT_PORT}
      - SPARKO_USER=${SPARKO_USER}
      - SPARKO_PASSWORD=${SPARKO_PASSWORD}
      - CLN_REST=${CLN_REST}
      - CLN_REST_EXT_PORT=${CLN_REST_EXT_PORT}
      - CLN_REST_INT_PORT=${CLN_REST_INT_PORT}
      - CLN_REST_EXT_DOCPORT=${CLN_REST_EXT_DOCPORT}
      - CLN_REST_INT_DOCPORT=${CLN_REST_INT_DOCPORT}
    ports:
      - ${SPARKO_EXT_PORT}:${SPARKO_INT_PORT}
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
up_build_common(){
  check_env
  create_network
  generate_docker_compose
  setup_directories
  set_script_permissions
  copy_bitcoin_cli
  run_custom
}
####################
build(){
  up_build_common
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g)
}
up(){
  up_build_common
  start_containers
}
shutdown(){
  scripts/gracefully_stop.sh "${CONTAINER_NAMES}"
}
clean(){
  printf 'Are you sure? (Y/n): '
  read input
  if [ "${input}" != 'Y' ]; then printf 'Abort!\n' 1>&2; return 1; fi
  for i in "${CONTAINERS[@]}"; do
    rm -rfv ./containers/${i}/volume/data
  done
}
lightning-cli(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    printf 'Expected: [ method ] [ params ]\n' 1>&2
    printf 'Examples:\n'
    printf "\t ./control.sh lightning-cli \'getinfo\' \'{}\'\n"
    printf "\t ./control.sh lightning-cli \'listpeers\' \'{\"id\": \"peer_id\"}\'\n"
    return 1
  fi
  local command="{\"jsonrpc\": 2.0, \"id\": 1, \"method\": \"${1}\", \"params\": ${2}}"
  local network
  case ${CLN_NETWORK} in
    mainnet) network=bitcoin ;;
    testnet) network=testnet ;;
    regtest) network=regtest ;;
    *) printf 'Invalid CLN_NETWORK\n' 1>&2; return 1 ;;
  esac
  echo ${command} | socat - UNIX-CONNECT:./containers/cln/volume/data/.lightning/${network}/lightning-rpc
}
####################
case ${1} in
  up) up ;;
  build) build ;;
  down) shutdown ;;
  clean) clean ;;
  lightning-cli) lightning-cli "${2}" "${3}" ;;
  nop) ;;
  *) printf 'Expected: [ build | up | down | lightning-cli | clean ]\n' 1>&2; return 1 ;;
esac
