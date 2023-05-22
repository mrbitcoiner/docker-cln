FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=nointeractive
RUN apt update
RUN apt upgrade -y
RUN apt install -y \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext \
  libevent-dev tor

ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID
ARG BITCOIN_RPC_HOSTNAME
ARG BITCOIN_RPC_PORT
ARG BITCOIN_RPC_USERNAME
ARG BITCOIN_RPC_PASSWORD
ARG CLN_NETWORK
ARG CLN_ALIAS
ARG CLN_TRUSTEDCOIN_PLUGIN
ARG TOR_PROXY

ENV CONTAINER_USER=${CONTAINER_USER}
ENV PATH=/app/data/bitcoin:/app/data/lightning/lightningd:/app/data/lightning/cli:${PATH}
ENV BITCOIN_RPC_HOSTNAME=${BITCOIN_RPC_HOSTNAME}
ENV BITCOIN_RPC_PORT=${BITCOIN_RPC_PORT}
ENV BITCOIN_RPC_USERNAME=${BITCOIN_RPC_USERNAME}
ENV BITCOIN_RPC_PASSWORD=${BITCOIN_RPC_PASSWORD}
ENV CLN_NETWORK=${CLN_NETWORK}
ENV CLN_ALIAS=${CLN_ALIAS}
ENV CLN_TRUSTEDCOIN_PLUGIN=${CLN_TRUSTEDCOIN_PLUGIN}
ENV TOR_PROXY=${TOR_PROXY}

ADD ./volume/scripts/user_setup.sh /scripts/user_setup.sh
RUN /scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID}

ADD ./volume/scripts/init.sh /scripts/init.sh
ENTRYPOINT ["/scripts/init.sh"]
