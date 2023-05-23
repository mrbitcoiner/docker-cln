#!/usr/bin/env bash
####################
set -e
####################
readonly BITCOIN_CONFIG_DIR="/app/data/.bitcoin"
readonly BITCOIN_HOME_DIR="${HOME}/.bitcoin"
####################
mkdir -p ${BITCOIN_CONFIG_DIR}
ln -sf ${BITCOIN_CONFIG_DIR} ${BITCOIN_HOME_DIR}

cat << EOF > ${BITCOIN_CONFIG_DIR}/bitcoin.conf
rpcuser=${BITCOIN_RPC_USERNAME}
rpcpassword=${BITCOIN_RPC_USERNAME}
rpcconnect=${BITCOIN_RPC_HOSTNAME}
rpcport=${BITCOIN_RPC_PORT}
EOF

