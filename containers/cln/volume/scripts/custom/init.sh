#!/usr/bin/env bash
####################
set -e
####################
setup_sparko(){
  /app/scripts/custom/setup_sparko.sh
} 
setup_nodejs(){
  /app/scripts/custom/setup_nodejs.sh
}
setup_cln_rest(){
  /app/scripts/custom/setup_cln_rest.sh
}
####################
setup_sparko
setup_nodejs
setup_cln_rest
#tail -f /dev/null

