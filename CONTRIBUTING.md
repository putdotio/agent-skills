# Contributing

## Setup

```bash
corepack enable pnpm
pnpm install --frozen-lockfile
```

## Change a skill

- Keep each skill under `skills/<name>/`.
- Put routing and shared constraints in `SKILL.md`.
- Put conditional procedures in focused references.
- Keep frontmatter and `agents/openai.yaml` aligned.
- Update an eval only when its scenario or acceptance criteria changed.

## Validate

```bash
pnpm run verify
```

The gate checks workflow syntax and every skill package. Pull requests should
state the affected skills and any activation or boundary change.
