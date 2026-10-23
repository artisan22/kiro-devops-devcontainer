# Kiro DevOps Dev Container

A ready-to-use dev container for DevOps, AWS, Terraform and Databricks work, with
Kiro CLI installed and a shared `.kiro/` config so Kiro IDE (on your host) and
Kiro CLI (in the container) follow the same rules.

## What's included

| Area | Tools |
|---|---|
| AI agent | Kiro CLI, uv/uvx (for MCP servers), Node LTS |
| AWS | AWS CLI v2 |
| Infrastructure as code | Terraform, tflint, terragrunt, terraform-docs, checkov |
| Kubernetes | kubectl, helm |
| Data | Databricks CLI, Python, pipx, PostgreSQL client |
| Everyday | git, GitHub CLI, jq, yq, ripgrep, fd, shellcheck, make, direnv, pre-commit |

Run `bash scripts/verify-tools.sh` inside the container to print every version.

## Quick start

1. Install Docker Desktop and VS Code with the Dev Containers extension.
2. Clone this repo and open it in VS Code.
3. Run **Dev Containers: Reopen in Container**. The first build takes a few minutes.
4. Sign in to each tool once. Credentials live in named Docker volumes, so they
   survive rebuilds.

```bash
kiro-cli
aws configure sso
aws sso login --use-device-code
databricks auth login --host https://<workspace>.cloud.databricks.com
gh auth login
```

## Hybrid workflow with Kiro IDE

Kiro IDE does not natively support the Dev Containers extension at the time of
writing, so the IDE stays on your host and the CLI runs in the container. Both read
the same `.kiro/` folder.

1. Plan in Kiro IDE (host): write specs and commit them under `.kiro/specs/`.
2. Implement in the container: run `kiro-cli` and point it at a spec.
3. Review on the host: the workspace is mounted, so diffs appear immediately.

## What's in `.kiro/`

- `steering/environment.md`: tool list, read-only-by-default safety rules,
  credential guidance. Changes here change agent behavior; CODEOWNERS applies.
- `settings/mcp.json`: AWS documentation, Terraform and Databricks documentation
  MCP servers. This file is strict JSON, so notes live here: pin the `@latest`
  versions and confirm the package names against the AWS Labs MCP docs.

## Updating versions

Tool versions are pinned for reproducible builds and bumped by hand.

- Review them periodically (for example quarterly): the Feature options in
  `devcontainer.json` (Terraform, tflint, terragrunt, Python, Node), the base image
  tag and `yq` URL in the Dockerfile, the Actions versions in the workflow, and the
  MCP server versions.
- Bump the value, open a pull request, and let the CI build gate the change.

## Security notes

- Kiro's Autopilot mode can run many steps without per-step approval. The steering
  file asks the agent to confirm before mutating cloud resources, but that is
  guidance, not enforcement. Use least-privilege roles and non-production accounts.
- The Kiro, uv and Databricks installers are fetched with `curl | sh`. Pin them
  where the vendor supports versioned URLs.
- Never mount `~/.ssh` or the Docker socket unless you need to.
- Do not commit tokens.

## CI

`.github/workflows/devcontainer.yml` builds the container and runs
`STRICT=1 bash scripts/verify-tools.sh` on changes to the container config.
It builds linux/amd64 only; verify Apple Silicon manually.


## Windows and Mac notes

**Both:** run `git config --global core.autocrlf input`, and give Docker Desktop at
least 4 CPUs and 8 GB memory. `.gitattributes` forces LF on shell scripts so they run
inside the Linux container.

**Windows:** use the WSL 2 engine in Docker Desktop. Keep the `ssh-agent` service
running if you use SSH keys; VS Code forwards it into the container. Files on `C:\`
are slow under Docker; if installs feel slow, consider keeping the checkout inside
WSL2 or a Docker volume (this affects whether Kiro IDE on the host can see the files).

**Mac:** use Docker Desktop's default (VirtioFS) file sharing. Tested on Apple Silicon
(arm64); CI covers Intel/AMD (amd64), so both architectures have been verified.

**Credentials** are stored in named volumes, so each dev signs in once per machine.