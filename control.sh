#!/usr/bin/env bash
####################
set -e
####################
readonly LOCAL_DIR="$(dirname ${0})"
if [ -e "${LOCAL_DIR}/scripts/gracefully_stop.sh" ]; then
  chmod +x ${LOCAL_DIR}/scripts/*.sh
fi
if [ -e "${LOCAL_DIR}/.env" ]; then
  source ${LOCAL_DIR}/.env
fi
####################
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
  if ! [ -e ${LOCAL_DIR}/.env ]; then printf 'You must copy the .env.example file to .env\n' 1>&2; return 1; fi
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
    mkdir -p ${LOCAL_DIR}/containers/${i}/volume/scripts
    mkdir -p ${LOCAL_DIR}/containers/${i}/volume/config
  done
}
set_script_permissions(){
  for i in ${CONTAINERS[@]}; do
    if [ -e ${LOCAL_DIR}/containers/${i}/volume/scripts/init.sh ]; then
      chmod +x ${LOCAL_DIR}/containers/${i}/volume/scripts/*.sh
    fi
    if [ -e ${LOCAL_DIR}/containers/${i}/volume/scripts/custom/init.sh ]; then
      chmod +x ${LOCAL_DIR}/containers/${i}/volume/scripts/custom/*.sh
    fi
  done
  if [ -e ${LOCAL_DIR}/scripts/custom/init.sh ]; then
    chmod +x ${LOCAL_DIR}/scripts/custom/*.sh
  fi
}
create_network(){
  if ! docker network ls | grep "${NETWORK}" > /dev/null; then
    docker network create -d bridge ${NETWORK}
  fi
}
start_containers(){
  cd ${LOCAL_DIR}
  docker-compose up \
    --remove-orphans \
    &
  cd - 1>/dev/null
}
copy_bitcoin_cli(){
  local destination="${LOCAL_DIR}/containers/${CLN_CONTAINER}/volume/data/bitcoin"
  if [ -e "${destination}/bitcoin-cli" ] || [ "${TRUSTEDCOIN}" == 'enabled' ]; then return 0; fi
  mkdir -p ${destination}
  cp ${BITCOIN_CLI_PATH} ${destination}/
}
generate_docker_compose(){
  cat << EOF > ${LOCAL_DIR}/docker-compose.yml
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
  if [ -e ${LOCAL_DIR}/scripts/custom/init.sh ]; then
    ${LOCAL_DIR}/scripts/custom/init.sh
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
  cd ${LOCAL_DIR}
  docker-compose build \
    --build-arg CONTAINER_USER=${USER} \
    --build-arg CONTAINER_UID=$(id -u) \
    --build-arg CONTAINER_GID=$(id -g)
  cd - 1>/dev/null
}
up(){
  up_build_common
  start_containers
}
shutdown(){
  cd ${LOCAL_DIR}
  scripts/gracefully_stop.sh "${CONTAINER_NAMES}"
  cd - 1>/dev/null
}
clean(){
  printf 'Are you sure? (Y/n): '
  read input
  if [ "${input}" != 'Y' ]; then printf 'Abort!\n' 1>&2; return 1; fi
  for i in "${CONTAINERS[@]}"; do
    rm -rfv ${LOCAL_DIR}/containers/${i}/volume/data
  done
}
lightning-cli(){
  if [ -z "${1}" ]; then printf 'Expected: <command>\n' 1>&2; return 1; fi
  docker exec ${CLN_CONTAINER_NAME} su -c "lightning-cli ${1}" ${USER}
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
