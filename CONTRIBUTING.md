# Contributing

## Setup

Install [pnpm](https://pnpm.io/installation), then:

```bash
pnpm install --frozen-lockfile
```

## Change a skill

Skill layout, frontmatter, picker metadata, and eval rules live in
[AGENTS.md](AGENTS.md). Pull requests state the affected skills and any
activation or boundary change.

## Validate

```bash
pnpm run verify
```

The gate lints the workflow files and runs
[`@uinaf/skillcheck`](https://github.com/uinaf/skillcheck) structural lint on
every skill package. CI runs the same keyless gate.
