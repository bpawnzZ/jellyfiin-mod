FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JELLYFIN_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="computevideoutility"
ENV JELLYFIN_WEB_DIR="/app/jellyfin-web/dist"

RUN \
  echo "**** install jellyfin dependencies *****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    at \
    ca-certificates \
    curl \
    gnupg \
    nodejs=20.* \
    npm \
    mesa-va-drivers \
    xmlstarlet && \
  curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor | tee /usr/share/keyrings/jellyfin.gpg >/dev/null && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main' > /etc/apt/sources.list.d/jellyfin.list && \
  if [ -z ${JELLYFIN_RELEASE+x} ]; then \
    JELLYFIN_RELEASE=$(curl -sX GET https://repo.jellyfin.org/ubuntu/dists/noble/main/binary-amd64/Packages |grep -A 7 -m 1 'Package: jellyfin-server' | awk -F ': ' '/Version/{print $2;exit}'); \
  fi && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    jellyfin=${JELLYFIN_RELEASE} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Copy custom frontend
COPY jellyfin-web/ /app/jellyfin-web/

# Build custom frontend
WORKDIR /app/jellyfin-web
RUN \
  echo "**** build custom frontend ****" && \
  npm install -g npm@9.6.4 && \
  npm ci && \
  npm run build:production && \
  mkdir -p /app/jellyfin-web/dist

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
