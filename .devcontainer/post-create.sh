#!/usr/bin/env bash
# Runs once after the container is created (see postCreateCommand).
# Installs Python-based CLIs with pipx so each gets an isolated environment and
# cannot conflict with project dependencies.
#
# Warn-only on purpose: a failure here must not block the container from opening.
# CI runs verify-tools.sh with STRICT=1, which catches a missing tool.
set -uo pipefail

for pkg in checkov pre-commit; do
  # --force keeps the script idempotent if the tool already exists.
  pipx install --force "$pkg" || echo "WARN: could not install $pkg"
done

bash "$(dirname "$0")/../scripts/verify-tools.sh"