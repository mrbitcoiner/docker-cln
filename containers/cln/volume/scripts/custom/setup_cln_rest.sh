#!/usr/bin/env bash
####################
set -e
####################
source /app/data/PATH.env
readonly CLN_REST_DATA_PATH='/app/data/cln_rest'
readonly CLN_REST_REPO='https://github.com/Ride-The-Lightning/c-lightning-REST'
readonly CLN_REST_COMMIT='29de0b08613d4f7866e2c604d09ce25c690bc118'
readonly CLN_CONFIG_PATH=${HOME}/.lightning/config
readonly REST_PORT=3002
readonly REST_DOCPORT=4001
####################
clone_and_install_cln_rest(){
  if [ -e ${CLN_REST_DATA_PATH} ]; then return 0; fi
  git clone ${CLN_REST_REPO} ${CLN_REST_DATA_PATH}
  cd ${CLN_REST_DATA_PATH}
  git checkout ${CLN_REST_COMMIT}
  npm install
}
config_cln(){
  if ! grep "^plugin=${CLN_REST_DATA_PATH}/clrest.js$" > /dev/null; then
    cat << EOF >> ${CLN_CONFIG_PATH}
plugin=${CLN_REST_DATA_PATH}/clrest.js
rest-port=${REST_PORT}
rest-docport=${REST_DOCPORT}
rest-protocol=https
EOF
  fi
}
####################
clone_and_install_cln_rest
config_cln
