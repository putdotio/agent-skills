<div align="center">
  <p>
    <img src="https://static.put.io/images/putio-boncuk.png" width="72" alt="put.io logo">
  </p>

  <h1>putdotio/skills</h1>

  <p>Shared agent skills for put.io development workflows.</p>
</div>

## Installation

```bash
npx skills add putdotio/skills
```

Install one skill directly:

```bash
npx skills add https://github.com/putdotio/skills --skill putio-frontend-docs
```

## Tessl

Use [Tessl](https://tessl.io/) to review and publish the skills in this repo to the `putio` workspace.

```bash
./scripts/review-skills.sh
./scripts/optimize-skills.sh frontend/docs
```

Per-skill checks:

```bash
./scripts/tessl.sh skill review --json skills/frontend/docs
./scripts/tessl.sh tile lint skills/frontend/docs
./scripts/tessl.sh tile publish --dry-run skills/frontend/docs
```

Publishing from GitHub Actions expects `TESSL_TOKEN` in the protected `release` Environment. See [Distribution](docs/distribution.md) for the publish flow and tile naming.

## Publishable skill shape

Published skills keep their package metadata next to the skill. Use [Distribution](docs/distribution.md) as the source of truth for `tile.json`, optional `agents/openai.yaml`, and Tessl publishing behavior.

## Docs

- [Contributing](./CONTRIBUTING.md) for contributor workflow and validation
- [Distribution](./docs/distribution.md) for publish flow and repository release details
- [Security](./SECURITY.md) for private vulnerability reporting

## Repo Internals

- [Agent guide](./AGENTS.md) for repo-specific automation guidance
- [Scripts reference](./scripts/README.md) for helper script notes

## Contributing

Use [Contributing](./CONTRIBUTING.md) for skill-authoring workflow and review expectations.
