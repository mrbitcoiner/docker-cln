#!/usr/bin/env bash
####################
set -e
####################

printf 'Running\n'

# temporary
su -c '/app/scripts/cln_build.sh' ${CONTAINER_USER}
tail -f /dev/null
