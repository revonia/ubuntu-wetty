FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl vim sudo gnupg2 ca-certificates lsb-release \
    python3 python3-pip nodejs npm nginx apache2-utils envsubst openssl \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | gpg --dearmor -o /usr/share/keyrings/tailscale-archive-keyring.gpg \
    && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
        | tee /etc/apt/sources.list.d/tailscale.list \
    && apt-get update && apt-get install -y tailscale \
    && npm install -g wetty \
    && apt-get clean

COPY nginx.conf.template /etc/nginx/templates/default.conf.template

COPY --chmod=755 start.sh /start.sh

EXPOSE 80
CMD ["/start.sh"]
