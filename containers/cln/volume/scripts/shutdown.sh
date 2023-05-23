#!/usr/bin/env bash
####################
set -e
####################
readonly DEST=/usr/bin/stop-container
####################
install(){
  cat << EOF > ${DEST}
#!/usr/bin/env bash
set -e
su -c 'lightning-cli stop' ${CONTAINER_USER}
EOF
  chmod +x ${DEST}
}
####################
install
