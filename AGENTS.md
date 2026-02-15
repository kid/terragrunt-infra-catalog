# AGENTS.md

This repository is a Terragrunt/OpenTofu catalog with RouterOS and Proxmox
modules, plus Go-based terratest integration tests under `test/`.

## Quick Start

- Enter the Nix dev shell for tooling: `nix develop`
- Format all code (treefmt): `nix fmt`
- Run formatter checks (CI-style): `nix flake check`

## Build / Lint / Test Commands

### Nix / Treefmt

- Format everything (preferred): `nix fmt`
- Check formatting (CI): `nix flake check`

Treefmt is configured in `flake.nix` to run:

- `nixfmt` for `.nix`
- `hclfmt` for `.hcl`
- `terraform fmt` for `.tofu`, `.tfvars`, `.tftest.hcl`

### OpenTofu / Terraform

This repo is a module catalog, so there is no single root stack.
Run tofu in a specific module directory when needed.

- Format a module manually: `tofu fmt -recursive`
- Validate a module: `tofu validate`

### Terragrunt

Terragrunt is used by consumers; there are no terragrunt stacks in this repo.
If you add stacks later, document the commands in this file.

### Go Tests (Terratest)

Tests live under `test/` as a separate Go module.

- Run all tests: `go test ./...`
- Run all tests with verbose output: `go test -v ./...`

#### Run a Single Test

- From `test/`: `go test -run TestSsh -v`
- From repo root: `go test -run TestSsh -v ./test`

#### Run a Single Subtest

Use `-run` with a regex that matches both the parent test and subtest:

- Example: `go test -run TestSsh/trusted1 -v ./test`

Note: these tests connect to real RouterOS devices and decrypt
`../secrets/dev/routeros.sops.yaml`. They will fail without access.

## Repository Layout

- `modules/`: OpenTofu modules
- `modules/_shared/`: shared provider generation helpers (terragrunt generate)
- `test/`: terratest suite (Go module)

## Code Style Guidelines

### General

- Prefer clarity over cleverness; keep modules small and composable.
- Do not hardcode secrets; use SOPS or external inputs.
- Keep changes localized and avoid reorganizing unrelated resources.
- Favor deterministic ordering of lists/maps to avoid diff churn.

### OpenTofu / Terraform Style

- Use `.tofu` files for OpenTofu modules (already standard here).
- Keep resource blocks grouped by function (dns, dhcp, firewall, etc.).
- Use `locals` for computed maps/lists and keep them near usage.
- Use `for_each` with stable keys; avoid `count` unless ordering is irrelevant.
- Use `lookup`, `try`, and `coalesce` for optional inputs to avoid null errors.
- Use `nonsensitive()` only when necessary (e.g., for keys in for_each).
- Provide `comment` fields where RouterOS supports them.
- For RouterOS rules, use `create_before_destroy` when changing sequences.
- Prefer `depends_on` only when implicit dependencies are insufficient.
- Keep variable naming consistent and descriptive (snake_case in HCL).

### Naming Conventions

- Resources: descriptive names scoped to function (e.g. `routeros_ip_dns.server`).
- Locals: short, domain-specific names (e.g. `vlans_rules`, `rules_map`).
- Variables: `snake_case`, avoid abbreviations unless standard (e.g., `ntp`).
- Use consistent VLAN naming across modules (`trusted`, `guest`, `mgmt`).

### Imports / Outputs

- Keep imports in module files close to the resource they import.
- Outputs should be explicit, stable, and prefixed with module purpose.

### Formatting

- Run `nix fmt` after changes.
- Keep blocks aligned with two-space indentation (as in existing files).
- Avoid trailing whitespace and keep a newline at EOF.

### Go Test Style (test/)

- Use standard Go formatting (`gofmt`).
- Use table-driven tests for repeated checks.
- Keep helpers in `helpers.go` and avoid duplicating logic.
- Use `t.Run` for subtests with clear, user-facing names.
- Use `t.Fatalf` for unrecoverable setup failures.

### Error Handling

- In HCL, guard optional values with `try()` or `lookup()`.
- In Go tests, fail fast on secret decode or connection errors.
- Use explicit error messages that name the resource or action.

## Tooling Notes

- `flake.nix` defines dev shell dependencies: `opentofu`, `terragrunt`, `tofu-ls`.
- `treefmt` excludes `*.sops.*` from formatting.
- Shell scripts should use `bash` with `set -euo pipefail`.

## Cursor / Copilot Rules

No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md`
were found in this repository at the time of writing.

## Tips for Agents

- Prefer minimal, targeted edits; avoid touching unrelated modules.
- Verify module changes with `tofu validate` when possible.
- For tests, ensure you have RouterOS access and SOPS keys.
- When adding modules, include `_variables.tofu`, `_versions.tofu`, and
  `_outputs.tofu` if applicable for consistency.
