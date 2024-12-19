FROM ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Custom Jellyfin version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="custom"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV JELLYFIN_WEB_DIR="/app/jellyfin-web/dist"

# Set DNS to Google's public DNS
RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null && \
    echo "nameserver 8.8.4.4" | tee -a /etc/resolv.conf > /dev/null

# Install dependencies in a single layer to reduce network calls
RUN \
  apt-get clean && \
  apt-get update && \
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    wget && \
  echo "**** install nodejs *****" && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get install -y nodejs npm && \
  echo "**** install jellyfin *****" && \
  wget -O - https://repo.jellyfin.org/jellyfin_team.gpg | gpg --dearmor | tee /usr/share/keyrings/jellyfin.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main" | tee /etc/apt/sources.list.d/jellyfin.list && \
  apt-get update && \
  apt-get install -y jellyfin && \
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

# Expose ports
EXPOSE 8096 8920

# Set volume
VOLUME /config

# Default command
CMD ["/usr/bin/jellyfin", "-d", "/config"]
