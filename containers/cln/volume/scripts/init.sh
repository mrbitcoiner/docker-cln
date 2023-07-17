#!/usr/bin/env bash
####################
set -e
####################
su -c '/app/scripts/cln_build.sh' ${CONTAINER_USER}

/app/scripts/tor_setup.sh
su -c '/app/scripts/bitcoin_cli_setup.sh' ${CONTAINER_USER}
su -c '/app/scripts/cln_setup.sh' ${CONTAINER_USER}
/app/scripts/shutdown.sh
su -c '/app/scripts/rpc_expose.sh' ${CONTAINER_USER}
su -c '/app/scripts/trustedcoin_setup.sh' ${CONTAINER_USER}
su -c '/app/scripts/setup_cln_rest.sh' ${CONTAINER_USER}
su -c '/app/scripts/setup_sparko.sh' ${CONTAINER_USER}

if [ -e /app/scripts/custom/init.sh ]; then
  su -c '/app/scripts/custom/init.sh' ${CONTAINER_USER}
fi

su -c 'lightningd' ${CONTAINER_USER}
