# Base image allows for configurable versions
ARG BASE_VERSION=latest
FROM ghcr.io/kairos-io/hadron:${BASE_VERSION}

# Ensure /etc/kairos directory exists
RUN mkdir -p /etc/kairos

# Add metadata labels required by AuroraBoot to generate the ISO
LABEL KAIROS_FLAVOR="hadron"
LABEL KAIROS_IMAGE_LABEL="${BASE_VERSION}"
LABEL KAIROS_NAME="kairos-custom"
LABEL KAIROS_VERSION="${BASE_VERSION}"

# Add custom Kairos configuration
COPY staging/base/config.yaml /etc/kairos/config.yaml
COPY staging/manifests/ /var/lib/k0s/manifests/

ARG OS_USERNAME="kairos"
ARG OS_PASSWORD="changeme"
ARG ZARF_VERSION="v0.75.1"

# Replace placeholders with actual build arguments
RUN sed -i "s/KAIROS_USERNAME_PLACEHOLDER/${OS_USERNAME}/g" /etc/kairos/config.yaml && \
    sed -i "s/KAIROS_PASSWORD_PLACEHOLDER/${OS_PASSWORD}/g" /etc/kairos/config.yaml

# Download and install Zarf CLI using ADD (avoids needing curl in minimal base)
ADD https://github.com/zarf-dev/zarf/releases/download/${ZARF_VERSION}/zarf_${ZARF_VERSION}_Linux_amd64 /usr/local/bin/zarf
RUN chmod +x /usr/local/bin/zarf

# If you have extra scripts (like cloud-init runcmds or systemd services)
# COPY custom-service.service /etc/systemd/system/
# RUN systemctl enable custom-service
