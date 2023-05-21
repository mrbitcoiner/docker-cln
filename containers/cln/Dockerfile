FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=nointeractive
ARG CONTAINER_USER
ARG CONTAINER_UID
ARG CONTAINER_GID

ENV CONTAINER_USER=${CONTAINER_USER}

RUN apt update
RUN apt upgrade -y

ADD ./volume/scripts/user_setup.sh /scripts/user_setup.sh
RUN /scripts/user_setup.sh ${CONTAINER_USER} ${CONTAINER_UID} ${CONTAINER_GID}

ADD ./volume/scripts/init.sh /scripts/init.sh
ENTRYPOINT ["/scripts/init.sh"]
