<div align="center">
  <p>
    <img src="https://static.put.io/images/putio-boncuk.png" width="72" alt="put.io logo">
  </p>

  <h1>putdotio/skills</h1>

  <p>Shared agent skills for put.io development workflows.</p>
</div>

## Installation

Install all shared put.io skills globally:

```bash
npx --yes skills add putdotio/skills -g --all -y
```

## Tessl

Use [Tessl](https://tessl.io/) to review and publish the skills in this repo to the `putio` workspace.

```bash
make verify
./scripts/review-skills.sh
./scripts/optimize-skills.sh frontend/frontend-dev
```

Per-skill checks:

```bash
./scripts/tessl.sh review run --json --workspace putio skills/frontend/frontend-dev
./scripts/tessl.sh plugin lint skills/frontend/frontend-dev
./scripts/tessl.sh plugin publish --dry-run skills/frontend/frontend-dev
```

Publishing from GitHub Actions expects `TESSL_TOKEN` in the protected `release` Environment. See [Distribution](docs/DISTRIBUTION.md) for the publish flow and plugin naming.

## Publishable skill shape

Published skills keep their package metadata next to the skill. Use [Distribution](docs/DISTRIBUTION.md) as the source of truth for `.tessl-plugin/plugin.json`, optional `agents/openai.yaml`, and Tessl publishing behavior.

## Docs

- [Distribution](./docs/DISTRIBUTION.md) for publish flow and repository release details
- [Evals](./docs/EVALS.md) for scenario layout and registry Impact checks
- [Security](./SECURITY.md) for private vulnerability reporting

## Repo Internals

- [Agent guide](./AGENTS.md) for repo-specific automation guidance
- [Scripts reference](./scripts/README.md) for helper script notes

## Contributing

Use [Contributing](./CONTRIBUTING.md) for skill-authoring workflow and review expectations.

## License

Licensed under the [MIT License](./LICENSE).
