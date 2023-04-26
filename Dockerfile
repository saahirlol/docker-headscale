# Dockerfile for Headscale

# Use the official Ubuntu 20.04 base image
FROM ubuntu:20.04

# Set environment variables
ENV HEADSCALE_VERSION=<HEADSCALE VERSION>
ENV ARCH=<ARCH>
ENV USERS="α☒β"

# Install dependencies and download the Headscale package
RUN apt-get update && \
    apt-get install -y wget nano && \
    wget --output-document=headscale.deb \
    https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${ARCH}.deb

# Install Headscale
RUN dpkg --install headscale.deb

# Create the necessary directories
RUN mkdir -p /var/headscale && \
    mkdir -p /etc/headscale

# Copy the configuration file into the container
COPY config.yaml /etc/headscale/config.yaml

# Expose the default Headscale port
EXPOSE 8080

# Create a script to create users
RUN echo '#!/bin/bash' > create_users.sh && \
    echo 'IFS="☒"' >> create_users.sh && \
    echo 'for user in $USERS; do' >> create_users.sh && \
    echo '  headscale users create $user' >> create_users.sh && \
    echo 'done' >> create_users.sh && \
    echo 'exec "$@"' >> create_users.sh && \
    chmod +x create_users.sh

# Set the entrypoint to create users and start the Headscale service
ENTRYPOINT ["./create_users.sh", "headscale", "serve", "-c", "/etc/headscale/config.yaml"]
