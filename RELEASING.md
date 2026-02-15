# Releasing modules

This repository uses Conventional Commits and creates independent releases
per module in `modules/` using GitHub Actions.

## Commit format

Use the module folder name as the scope.

Examples:

- `feat(ros-dns): add dns static entries`
- `fix(ros-firewall): correct rule ordering`
- `feat(ros-dhcp-server)!: drop legacy lease format`

Breaking changes should use `!` in the header or a `BREAKING CHANGE:` footer.

Commit linting runs on pull requests and requires a non-empty scope.

StandardJS linting runs on pull requests for the CI scripts under `.github/`.

## Release preview

Pull requests get a release preview comment per module. The preview uses a
semantic-release dry run and only appears when module changes are detected.

## Tags and changelogs

- Tags are created as `module-<name>-vX.Y.Z`
- Changelogs live at `modules/<name>/CHANGELOG.md`

## How releases are generated

On push to `main`, the workflow:

1. Discovers module directories under `modules/` (excluding `_shared`).
2. Runs semantic-release per module.
3. Creates a GitHub Release when relevant commits are found.

Releases only consider commits that:

- Touch files under `modules/<name>/`, and
- Use Conventional Commit scopes that match the module name.
