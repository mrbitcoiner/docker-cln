#!/usr/bin/env bash
####################
set -e
####################
source .env
readonly SPARKO_PORT=10050 
readonly CLN_REST_PORT=3002
readonly CLN_REST_DOCPORT=4001
####################
check_vars(){
  if [ -z ${CLN_INT_RPC_PORT} ]; then printf 'Unavailable env CLN_INT_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${CLN_EXT_RPC_PORT} ]; then printf 'Unavailable env CLN_EXT_RPC_PORT\n' 1>&2; return 1; fi
  if [ -z ${CLN_CONTAINER_NAME} ]; then printf 'Unavailable env CLN_CONTAINER_NAME\n' 1>&2; return 1; fi
  if [ -z ${NETWORK} ]; then printf 'Unavailable env NETWORK\n' 1>&2; return 1; fi
}
generate_custom_docker_compose(){
  cat << EOF > docker-compose.yml
services:
  cln:
    container_name: ${CLN_CONTAINER_NAME} 
    build: ./containers/cln
    volumes:
      - ./containers/cln/volume:/app
    ports:
      - ${CLN_EXT_RPC_PORT}:${CLN_INT_RPC_PORT}
      - ${SPARKO_PORT}:${SPARKO_PORT}
      - ${CLN_REST_PORT}:${CLN_REST_PORT}
      - ${CLN_REST_DOCPORT}:${CLN_REST_DOCPORT}
    networks:
      - cln

networks:
  cln:
    name: ${NETWORK} 
    external: true
EOF
}
####################
check_vars
generate_custom_docker_compose

