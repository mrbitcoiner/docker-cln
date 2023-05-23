#!/usr/bin/env bash
####################
set -e
####################
su -c '/app/scripts/cln_build.sh' ${CONTAINER_USER}

if echo ${TOR_PROXY} | grep '^enabled$' > dev/null; then
  /app/scripts/tor_setup.sh
fi
su -c '/app/scripts/bitcoin_cli_setup.sh' ${CONTAINER_USER}
su -c '/app/scripts/cln_setup.sh' ${CONTAINER_USER}
/app/scripts/shutdown.sh

su -c 'lightningd' ${CONTAINER_USER}
