FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DSTAGING_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="DOSBox Staging"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/dosbox-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    xz-utils && \
  if [ -z ${DSTAGING_VERSION+x} ]; then \
    DSTAGING_VERSION=$(curl -sX GET "https://api.github.com/repos/dosbox-staging/dosbox-staging/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/dosbox.tar.xz -L \
    "https://github.com/dosbox-staging/dosbox-staging/releases/download/${DSTAGING_VERSION}/dosbox-staging-linux-x86_64-${DSTAGING_VERSION}.tar.xz" && \
  mkdir /opt/dosbox && \
  tar xf \
    /tmp/dosbox.tar.xz -C \
    /opt/dosbox --strip-components=1 && \
  mkdir -p \
    /usr/share/icons/hicolor/128x128/apps && \
  cp \
    /usr/share/selkies/www/icon.png \
    /usr/share/icons/hicolor/128x128/apps/dosbox.png && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
