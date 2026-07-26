# Agent Guide

Instructions for contributors in this repo.

- Treat `AGENTS.md` as a routing layer, not a manual. Keep deeper detail inside each skill's `SKILL.md`.
- Keep `README.md` concise and consumer-facing.
- Shared put.io skills live under `skills/*`.
- Prefer repo-relative links in checked-in Markdown.
- Put common workflow once in the most relevant source file.
- Keep skill descriptions self-activating: say what the skill does, when to use it, and the main boundary when overlap is likely.
- When changing a skill, update any adjacent examples or references that would drift with it.
- When changing a skill, run `./scripts/tessl.sh review run --workspace putio skills/<group>/<name>`; for broader skill work, run `make verify` and use the feedback to tighten wording and workflow.
- `scripts/tessl.sh` owns the audited local Tessl CLI pin. Keep the `setup-tessl` workflow versions aligned with it.
- Publishable skill package metadata lives in `.tessl-plugin/plugin.json`. Follow [Distribution](docs/DISTRIBUTION.md) for publishing and credential rotation.
- `CLAUDE.md` should remain a symlink to this file.
