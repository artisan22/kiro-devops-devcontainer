# Base: Microsoft's Ubuntu dev container image. Provides the non-root `vscode`
# user, git, sudo and common shell tooling. The floating `ubuntu` tag tracks the
# latest LTS; Step 10 pins it to an exact tag once the build is verified.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USERNAME=vscode

# Fail the build if ANY command in a pipeline fails. Without pipefail, a failed
# `curl ... | sh` below would be ignored and the tool would silently be missing.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# OS packages. Language runtimes, AWS CLI, Terraform and Kubernetes tooling come
# from Dev Container Features (see devcontainer.json), not from here.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl unzip ca-certificates jq ripgrep fd-find shellcheck make direnv \
       postgresql-client less vim-tiny dnsutils \
    && rm -rf /var/lib/apt/lists/*

# yq (mikefarah). dpkg picks amd64 or arm64, so one Dockerfile serves Intel
# Windows laptops and Apple Silicon Macs. Pinned to a version in Step 10.
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$(dpkg --print-architecture)" \
      -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Databricks CLI via the vendor's installer (installs system-wide, so run as root).
RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Pre-create the directories that devcontainer.json mounts as named volumes.
# Docker copies this ownership into a brand-new volume; otherwise the volume is
# root-owned and the non-root user cannot write credentials into it.
RUN mkdir -p /home/${USERNAME}/.kiro /home/${USERNAME}/.local/share/kiro-cli \
      /home/${USERNAME}/.aws /home/${USERNAME}/.databricks \
      /home/${USERNAME}/.terraform.d/plugin-cache \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.kiro /home/${USERNAME}/.local \
      /home/${USERNAME}/.aws /home/${USERNAME}/.databricks /home/${USERNAME}/.terraform.d

# Everything below runs as the non-root user: user-scoped installs only.
USER ${USERNAME}

# Kiro CLI and uv both install into ~/.local/bin.
ENV PATH=$PATH:/home/${USERNAME}/.local/bin
RUN curl -fsSL https://cli.kiro.dev/install | bash
RUN curl -LsSf https://astral.sh/uv/install.sh | sh