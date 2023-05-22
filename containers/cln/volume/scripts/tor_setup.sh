#!/usr/bin/env bash
####################
set -e
####################
readonly TOR_DIR=/app/data/tor
readonly SERVICE_NAME=lightning
readonly PORT=9735
###################

su -c "mkdir -p ${TOR_DIR}" ${CONTAINER_USER}

cat << EOF >> /etc/tor/torrc
HiddenServiceDir ${TOR_DIR}/${SERVICE_NAME}
HiddenServicePort ${PORT} 127.0.0.1:${PORT}
EOF

su -c 'tor &' ${CONTAINER_USER}

