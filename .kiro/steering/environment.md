# Environment and safety rules

> Changes to this file change what the agent is allowed to do. Treat it like
> infrastructure code: changes require review (see CODEOWNERS).

Runs in a Dev Container. Kiro CLI runs inside it; Kiro IDE runs on the host and
shares this `.kiro/` folder.

## Safety rules (read-only by default)
- Prefer read-only commands: `terraform plan`, `aws ... describe/list/get`,
  `databricks bundle validate`, `kubectl get/describe`.
- Never run these without explicit approval in chat:
  - `terraform apply/destroy/import`, `terraform state` changes
  - AWS commands that create, update, delete, put or terminate resources
  - `databricks bundle deploy/destroy`, job or cluster deletion
  - `kubectl apply/delete`, `helm install/upgrade/uninstall`
  - `git push --force`
- Before proposing infra changes run `terraform fmt`, `terraform validate`,
  `tflint` and `checkov`, and report findings.
- Always name the target account, region, workspace and environment before any
  change.

## Credentials
- AWS: `aws sso login --use-device-code`. Databricks: `databricks auth login --host <url>`.
- Never write tokens or keys into repo files.

## Conventions
- Commit `.terraform.lock.hcl`; never commit state or `.terraform/`.
- Do not modify `.devcontainer/` without asking.