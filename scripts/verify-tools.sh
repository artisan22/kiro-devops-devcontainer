#!/usr/bin/env bash
# Set STRICT=1 to fail if any tool is missing (used in CI).
missing=0
check() {
  local name=$1; shift
  if command -v "$name" >/dev/null 2>&1; then
    printf '%-15s ' "$name"; "$@" 2>&1 | head -n1
  else
    printf '%-15s MISSING\n' "$name"; missing=$((missing + 1))
  fi
}
check git git --version
check gh gh --version
check aws aws --version
check terraform terraform version
check tflint tflint --version
check terragrunt terragrunt --version
check terraform-docs terraform-docs --version
check tfsec tfsec --version
check kubectl kubectl version --client
check helm helm version --short
check databricks databricks --version
check python3 python3 --version
check node node --version
check uv uv --version
check kiro-cli kiro-cli --version
check checkov checkov --version
check pre-commit pre-commit --version
check jq jq --version
check yq yq --version
check rg rg --version
check shellcheck shellcheck --version
echo
if [ "$missing" -gt 0 ]; then
  echo "$missing tool(s) missing"; [ "${STRICT:-0}" = "1" ] && exit 1
else
  echo "All tools present"
fi
exit 0