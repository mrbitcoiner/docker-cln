#!/usr/bin/env bash
####################
set -e
####################
su -c '/app/scripts/cln_build.sh' ${CONTAINER_USER}

if [ "${TOR_PROXY}" == 'enabled' ]; then
  /app/scripts/tor_setup.sh
fi
su -c '/app/scripts/bitcoin_cli_setup.sh' ${CONTAINER_USER}
su -c '/app/scripts/cln_setup.sh' ${CONTAINER_USER}
/app/scripts/shutdown.sh
su -c '/app/scripts/rpc_expose.sh' ${CONTAINER_USER}

su -c 'lightningd' ${CONTAINER_USER}
