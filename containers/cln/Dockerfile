FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=nointeractive
RUN apt update
RUN apt upgrade -y
RUN apt install -y --no-install-recommends \
  autoconf automake build-essential git libtool libgmp-dev libsqlite3-dev \
  python3 python3-pip net-tools zlib1g-dev libsodium-dev gettext \
  libevent-dev tor wget socat python3-poetry pkg-config libpq-dev python3-dev \ 
  libffi-dev \
  && echo '0.1.0' > /version

ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID

ENV CONTAINER_USER=${CONTAINER_USER}
ENV CONTAINER_UID=${CONTAINER_UID}
ENV CONTAINER_GID=${CONTAINER_GID}
ENV PATH=/home/${CONTAINER_USER}/nodejs/nodejs/bin:/app/data/bitcoin:/app/data/lightning/lightningd:/app/data/lightning/cli:${PATH}

COPY ./volume/scripts /scripts
RUN /scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID} \
  && su -c '/scripts/setup_nodejs.sh' ${CONTAINER_USER}


ENTRYPOINT ["/scripts/init.sh"]
