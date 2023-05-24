#!/usr/bin/env bash
####################
set -e
####################
chmod +x scripts/*.sh
get_env(){ 
  scripts/get_env.sh '.env' "${1}" 
}
####################
readonly "$(get_env 'CLN_CONTAINER')"  
readonly CONTAINERS=("${CLN_CONTAINER}")
readonly "$(get_env 'NETWORK')"
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
env_set(){
  if [ -z "${1}" ] || [ -z "${2}" ]; then print_err "Expected: [ key ] [ value ]"; fi
  local key="${1}"
  local value="${2}"
  local FILE='.env'
  scripts/set_dotenv.sh "${FILE}" "${key}" "${value}"
}
set_user_env(){
  env_set "CONTAINER_UID" "$(id -u)"
  env_set "CONTAINER_GID" "$(id -g)"
  env_set "CONTAINER_USER" "${USER}"
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
    --build-arg $(get_env 'CLN_EXPOSE_RPC') \
    --build-arg $(get_env 'CLN_INT_RPC_PORT') \
    --build-arg $(get_env 'CLN_BASE_FEE_MSAT') \
    --build-arg $(get_env 'CLN_PPM_FEE') \
    --build-arg $(get_env 'CLN_MIN_CH_CAPACITY_SAT') \
    --build-arg $(get_env 'CLN_MAX_HTLC_INFLIGHT') \
    --build-arg $(get_env 'CLN_MAX_HTLC_SIZE_MSAT') \
    --build-arg $(get_env 'CLN_MIN_HTLC_SIZE_MSAT') \
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
  if ! get_env "BITCOIN_CLI_PATH" > /dev/null; then
    return 0
  fi
  local $(get_env "BITCOIN_CLI_PATH")
  local destination=./containers/${CLN_CONTAINER}/volume/data/bitcoin
  if ! [ -e ${destination}/bitcoin-cli ]; then
    mkdir -p ${destination}
    cp ${BITCOIN_CLI_PATH} ${destination}/
  fi
}
generate_docker_compose(){
  local $(get_env "CLN_INT_RPC_PORT")
  local $(get_env "CLN_EXT_RPC_PORT")
  cat << EOF > docker-compose.yml
services:
  cln:
    container_name: ${CLN_CONTAINER} 
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
####################
boot(){
  create_network
  generate_docker_compose
  setup_directories
  set_script_permissions
  set_user_env
  copy_bitcoin_cli
  build_images
  start_containers
}
shutdown(){
  scripts/gracefully_stop.sh "${CONTAINERS}"
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
  docker exec -it ${CLN_CONTAINER} su -c 'lightning-cli '"${command}"'' ${USER}
}
create_cln_socket(){
  local $(get_env "CLN_EXPOSE_RPC")
  if ! echo "${CLN_EXPOSE_RPC}" | grep '^enabled$' 1> /dev/null; then return 0; fi
  local $(get_env "CLN_EXT_RPC_PORT")
  socat UNIX-LISTEN:cln.sock,fork,reuseaddr TCP:127.0.0.1:${CLN_EXT_RPC_PORT} &
}
####################
case ${1} in
  up) boot ;;
  down) shutdown ;;
  clean) clean ;;
  cli_wrapper) cli_wrapper "${2}" ;;
  sock_forward) create_cln_socket ;;
  nop) ;;
  *) print_err 'Expected: [ up | down | sock_forward | cli_wrapper | clean ]' ;;
esac
