FROM debian:bookworm-slim

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Custom Jellyfin version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="custom"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV JELLYFIN_WEB_DIR="/app/jellyfin-web/dist"

# Install dependencies
RUN \
  echo "**** install base dependencies *****" && \
  apt-get update && \
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
  echo "**** install nodejs *****" && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y \
    nodejs \
    npm && \
  echo "**** install jellyfin *****" && \
  curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian bookworm main" | tee /etc/apt/sources.list.d/jellyfin.list && \
  apt-get update && \
  apt-get install -y \
    jellyfin && \
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
  npm ci && \
  npm run build:production && \
  mkdir -p /app/jellyfin-web/dist

# Expose ports
EXPOSE 8096 8920

# Set volume
VOLUME /config

# Default command
CMD ["/usr/bin/jellyfin", "-d", "/config"]
