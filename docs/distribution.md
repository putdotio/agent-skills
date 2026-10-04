# Distribution

This repository is the source of truth for its two skills. Consumers install
them directly from the `skills/` tree with the `skills` CLI. There is no
publish pipeline.

Harness-local and repository-local copies are not sources of truth; re-sync
them instead of editing them. The full owner map, including `putio-cli`, is
the [skill fleet inventory](skill-fleet.md#inventory).

## Quality gate

Every pull request and push to `main` runs `pnpm run verify`
([workflow](../.github/workflows/verify.yml)) and an offline check of relative
Markdown links and anchors ([workflow](../.github/workflows/links.yml)).
A [scan](../.github/workflows/scan.yml) runs Gitleaks and TruffleHog on every
pull request, Actionlint and Zizmor on pull requests that change `.github/`,
and all four weekly.
