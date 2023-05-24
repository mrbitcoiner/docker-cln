#!/usr/bin/env bash
####################
set -e 
####################
readonly ENV_PATH=${1}
readonly KEY=${2}
####################
check_variables(){
  if [ -z "${ENV_PATH}" ] || [ -z "${KEY}" ]; then printf 'Expected: [ ENV_PATH ] [ KEY ]\n' 1>&2; return 1; fi
}
check_path(){
  if ! [ -e "${ENV_PATH}" ]; then printf "Path: ${ENV_PATH} does not exist\n" 1>&2; return 1; fi
}
return_env(){
  if ! grep '^'${KEY}'=.*$' ${ENV_PATH} 1> /dev/null; then printf "Key ${KEY} not found in ${ENV_PATH}\n" 1>&2; return 1; fi
  grep '^'${KEY}'=.*$' ${ENV_PATH}
}
get_env(){
  check_variables
  check_path 
  return_env
}
####################
get_env 
