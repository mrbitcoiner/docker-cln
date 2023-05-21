#!/usr/bin/env bash
####################
set -e
####################
readonly CLN_REPO='https://github.com/elementsproject/lightning'
readonly COMMIT_VERSION='v0.11.2'
####################

if [ -e /app/data/lightning ]; then exit 0; fi
git clone ${CLN_REPO} /app/data/lightning
cd /app/data/lightning
git checkout ${COMMIT_VERSION}
pip3 install --upgrade pip
pip3 install mako
pip3 install poetry
export PATH=/home/${CONTAINER_USER}/.local/bin:${PATH}
poetry install 
source $(poetry env info --path)/bin/activate
./configure
make
