
# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-26.04-v4

# Download URLs
ARG ARECA_VERSION=8.2.6
ARG ARECA_URL=https://downloads.sourceforge.net/project/areca-backup/areca-stable/areca-backup-${ARECA_VERSION}/areca-${ARECA_VERSION}-linux-x86-64.tar.gz
ARG JSCH_URL=https://sourceforge.net/projects/jsch/files/jsch.jar/0.1.55/jsch-0.1.55.jar/download

# Define working directory
WORKDIR /tmp

# Download Areca and Jsch
RUN \
    apt-get update && apt-get install -y wget && \
    add-pkg --virtual build-dependencies \
        curl \
        && \
    mkdir -p /defaults && \
    # Download.
    wget -O /defaults/areca.tar.gz ${ARECA_URL} && \
    wget -O /defaults/jsch.jar ${JSCH_URL} && \
    # Cleanup.
    del-pkg build-dependencies && \
    rm -rf /tmp/* /tmp/.[!.]*

# Unpack Areca
RUN \
    tar -xvzf /defaults/areca.tar.gz -C /defaults && \
    mv /defaults/areca-${ARECA_VERSION}-linux-x86-64 /defaults/areca && \
    rm -f /defaults/areca.tar.gz

# Install dependencies.
RUN \
    add-pkg \
        default-jre \
        gtk+2.0 \
        bash

# Copy the fixed Jsch lib
RUN \
    rm -f /defaults/areca/lib/jsch.jar && \
    mv /defaults/jsch.jar /defaults/areca/lib/jsch.jar

ENV APP_NAME="Areca Backup" \
    APP_VERSION=${ARECA_VERSION} \
    S6_KILL_GRACETIME=8000

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://areca-backup.sourceforge.io/legacy/images/logo.jpg && \
    install_app_icon.sh "$APP_ICON_URL"

# Enable ACL support (for Ubuntu)
RUN \
    ldconfig -p | grep libacl && \
    ln -s /usr/lib/x86_64-linux-gnu/libacl.so.1 /defaults/areca/lib/libacl.so

COPY startapp.sh /startapp.sh

# Grant execution permission to startapp.sh script
RUN \
    chmod +x /startapp.sh
