# syntax=docker/dockerfile:1
FROM php:8.4-cli-bookworm

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        locales \
        nodejs \
        npm \
        openssh-client \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY . /app

# ========== SSH plugin for local Trae rollout containers ==========
COPY ssh_plugin/ /tmp/ssh_plugin/
RUN chmod +x /tmp/ssh_plugin/install_ssh.sh /tmp/ssh_plugin/entrypoint.sh \
    && /tmp/ssh_plugin/install_ssh.sh \
    && cp /tmp/ssh_plugin/entrypoint.sh /usr/local/bin/ssh_plugin_entrypoint \
    && chmod +x /usr/local/bin/ssh_plugin_entrypoint \
    && rm -rf /tmp/ssh_plugin
# ========== end SSH plugin ==========

RUN git config --global --add safe.directory /app \
    && git config --global user.email "rl-scaring@example.local" \
    && git config --global user.name "RL Scaring Baseline" \
    && git init \
    && git add -A \
    && git commit -m "baseline"

EXPOSE 22
ENTRYPOINT ["/usr/local/bin/ssh_plugin_entrypoint"]
CMD ["bash"]
