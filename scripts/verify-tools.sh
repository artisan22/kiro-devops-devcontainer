#!/usr/bin/env bash
# Prints the version of every tool the dev container must provide.
# Used three ways: manually, from post-create.sh, and in CI.
# STRICT=1 exits non-zero if any tool is missing, so CI fails loudly.
#
# Deliberately no `set -e`: we want to report ALL missing tools, not stop at the first.
set -uo pipefail

missing=0

# check <binary> <command...>: print the first line of the version output,
# or MISSING if the binary is not on PATH.
check() {
  local name=$1
  shift
  if command -v "$name" >/dev/null 2>&1; then
    printf '%-15s ' "$name"
    "$@" 2>&1 | head -n1
  else
    printf '%-15s MISSING\n' "$name"
    missing=$((missing + 1))
  fi
}

# Source control
check git git --version
check gh gh --version

# Cloud and infrastructure
check aws aws --version
check terraform terraform version
check tflint tflint --version
check terragrunt terragrunt --version
check terraform-docs terraform-docs --version
check tfsec tfsec --version
check checkov checkov --version
check kubectl kubectl version --client
check helm helm version --short

# Data
check databricks databricks --version

# Runtimes and agent tooling
check python3 python3 --version
check node node --version
check uv uv --version
check kiro-cli kiro-cli --version
check pre-commit pre-commit --version

# Utilities
check jq jq --version
check yq yq --version
check rg rg --version
check shellcheck shellcheck --version

echo
if [ "$missing" -gt 0 ]; then
  echo "$missing tool(s) missing"
  [ "${STRICT:-0}" = "1" ] && exit 1
else
  echo "All tools present"
fi
exit 0