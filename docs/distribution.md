# Distribution

This repository is the source of truth for its two skills. Consumers install
them directly from the `skills/` tree with the `skills` CLI. There is no
publish pipeline.

Harness-local and repository-local copies are not sources of truth; re-sync
them instead of editing them. The full owner map, including `putio-cli`, is
the [skill fleet inventory](skill-fleet.md#inventory).

## Quality gate

Every pull request, push to `main`, and manual dispatch runs `pnpm run verify`
and an offline check of relative Markdown links and anchors
([workflow](../.github/workflows/verify.yml)). The same job then runs the
shared [scan](https://github.com/putdotio/.github#actionsscan): on a push it
runs Actionlint and Zizmor when the pushed range changes `.github/`, and a
manual dispatch lints every workflow. GitHub secret scanning and push
protection cover secrets in this public repository.
