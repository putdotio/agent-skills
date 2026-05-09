# Agent Guide

Instructions for contributors in this repo.

- Treat `AGENTS.md` as a routing layer, not a manual. Keep deeper detail inside each skill's `SKILL.md`.
- Keep `README.md` concise and consumer-facing.
- Shared put.io skills live under `skills/*`.
- Prefer repo-relative links in checked-in Markdown.
- Put common workflow once in the most relevant source file.
- Keep skill descriptions self-activating: say what the skill does, when to use it, and the main boundary when overlap is likely.
- When changing a skill, update any adjacent examples or references that would drift with it.
- When changing a skill, run `./scripts/tessl.sh skill review skills/<group>/<name>`; for broader skill work, run `./scripts/review-skills.sh` and use the feedback to tighten wording and workflow. `scripts/tessl.sh` uses an installed `tessl` CLI first and falls back to `npx tessl` only when needed.
- `CLAUDE.md` should remain a symlink to this file.
