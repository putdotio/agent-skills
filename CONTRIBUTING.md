# Contributing

This repository stores shared agent skills for put.io development workflows.

## Setup

There is no repo-local bootstrap step beyond access to Tessl for review and publish workflows. Use `./scripts/tessl.sh`; it pins the Tessl CLI through `TESSL_CLI_VERSION` and defaults to version `0.90.0`

## Working in the repo

- shared skills live under `skills/*`
- keep top-level `SKILL.md` files concise and self-activating
- move detailed examples, doctrine, and checklists into adjacent `references/*` files
- put shared guidance in one owning skill or reference

## Validation

For focused changes, review the affected skill directly:

```bash
./scripts/tessl.sh review run --json --workspace putio skills/<group>/<name>
```

For broader changes, use the repository scripts:

```bash
make verify
./scripts/review-skills.sh
```

If you change publishable skill metadata such as `.tessl-plugin/plugin.json` or `agents/openai.yaml`, run the plugin checks documented in [Overview](./README.md) and keep the picker-facing metadata aligned with the skill branding and scope.

## Pull Requests

Helpful pull requests usually include:

- the affected skill paths
- the Tessl review output or score changes when relevant
- a short note about activation, boundary, or doctrine changes

## Docs

- keep [Overview](./README.md) focused on overview, installation, and publish-facing navigation
- keep contributor workflow in this file
- keep security reporting in [Security](./SECURITY.md)
- keep agent-specific routing in [Agent guide](./AGENTS.md)
