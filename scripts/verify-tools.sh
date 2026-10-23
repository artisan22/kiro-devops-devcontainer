#!/usr/bin/env bash
# Prints the version of every tool the dev container must provide.
# Used three ways: manually, from post-create.sh, and in CI.
# STRICT=1 exits non-zero if any tool is missing or broken, so CI fails loudly.
#
# Deliberately no `set -e`: we want to report ALL problems, not stop at the first.
set -uo pipefail

problems=0

# check <binary> <version command...>
# A tool counts as a problem if it is not on PATH, if its version command exits
# non-zero, or if it prints nothing. "On PATH" alone is not proof it works.
check() {
  local name=$1
  shift
  if ! command -v "$name" >/dev/null 2>&1; then
    printf '%-15s MISSING\n' "$name"
    problems=$((problems + 1))
    return
  fi
  local out rc
  out=$("$@" 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ] || [ -z "$out" ]; then
    printf '%-15s BROKEN (exit %s)\n' "$name" "$rc"
    problems=$((problems + 1))
    return
  fi
  printf '%-15s %s\n' "$name" "$(printf '%s\n' "$out" | head -n1)"
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
# shellcheck prints its name on line 1 and the version on line 2.
check shellcheck bash -c 'shellcheck --version | sed -n 2p'

echo
if [ "$problems" -gt 0 ]; then
  echo "$problems tool(s) missing or broken"
  [ "${STRICT:-0}" = "1" ] && exit 1
else
  echo "All tools present"
fi
exit 0