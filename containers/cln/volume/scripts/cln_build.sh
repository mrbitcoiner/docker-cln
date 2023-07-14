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
poetry run pip3 install --upgrade pip
poetry run pip3 install mako
poetry run pip3 install mrkd
poetry install || true
poetry run ./configure
poetry run make
