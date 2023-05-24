#!/usr/bin/env bash
####################
set -e
####################
readonly CONTAINERS="${1}"
####################
check_arguments(){
  if [ -z "${CONTAINERS}" ]; then printf 'Expected [ containers ]\n' 1>&2; return 1; fi
}
try_shutdown(){
  for i in "${CONTAINERS[@]}"; do
    docker exec -it ${i} stop-container 
  done
}
shutdown_order(){
  try_shutdown || true
}
still_running(){
  local still_running=false
  for i in "${CONTAINERS[@]}"; do
    if docker ps -f name=${i} | grep '^.*   '${i}'$' > /dev/null; then
      still_running=true
      break
    fi
  done
  ${still_running}
}
loop(){
  local counter=0
  local max=60
  while [ ${counter} -le ${max} ] && still_running; do
    printf "\rWaiting gracefully shutdown ${counter}/${max}s"
    counter=$((${counter} + 1))
    sleep 1
  done
  printf '\n'
}
clean(){
  docker-compose down
}
run(){
  check_arguments
  shutdown_order
  loop
  clean
}
####################
run
