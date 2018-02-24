FROM ubuntu:16.04
#FROM debian:stretch

ARG BUILD_UID=1000
ARG BUILD_GID=1000
RUN (test $(getent group $BUILD_GID) || addgroup -gid $BUILD_GID buildgroup) && \
    (test $(getent passwd $BUILD_UID) || adduser --disabled-password --gecos "" -uid $BUILD_UID -gid $BUILD_GID builduser)

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get install --no-install-recommends -y \
        build-essential \
        software-properties-common \
        devscripts \
        equivs \
	git

COPY debian/control /tmp/deps/debian/
WORKDIR /tmp/deps
RUN apt-get update && \
    mk-build-deps --install --remove --tool 'apt-get --no-install-recommends -y --verbose-versions' debian/control && \
    dpkg-checkbuilddeps

USER $BUILD_UID
WORKDIR /home/builduser/workdir

