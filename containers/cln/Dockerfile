FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=nointeractive
ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID

ENV CONTAINER_USER=${CONTAINER_USER}
ENV PATH=/app/data/bitcoin:/app/data/lightning/lightningd:/app/data/lightning/cli:${PATH}

RUN apt update
RUN apt upgrade -y
RUN apt install -y \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext libevent-dev

ADD ./volume/scripts/user_setup.sh /scripts/user_setup.sh
RUN /scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID}

ADD ./volume/scripts/init.sh /scripts/init.sh
ENTRYPOINT ["/scripts/init.sh"]
