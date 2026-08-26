<div align="center">
  <p>
    <img src="https://static.put.io/images/putio-boncuk.png" width="72" alt="put.io logo">
  </p>

  <h1>putdotio/agent-skills</h1>

  <p>Standalone skills for put.io development.</p>
</div>

## Catalog

| Skill | Use it for |
| --- | --- |
| [`putio-frontend-dev`](skills/putio-frontend-dev/SKILL.md) | End-user apps, shared frontend packages, test harnesses, and frontend delivery. |
| [`putio-sdk-dev`](skills/putio-sdk-dev/SKILL.md) | Typed API clients and SDK packages. |

## Install

Browse the catalog:

```bash
pnpm dlx skills add putdotio/agent-skills --list
```

Install one skill globally for Codex and Claude Code:

```bash
pnpm dlx skills add putdotio/agent-skills -g -y -a codex -a claude-code -s putio-frontend-dev
```

Replace `putio-frontend-dev` with another catalog name. Omit `-g` for a
repository-local installation.

## Contributing

```bash
corepack enable pnpm
pnpm install --frozen-lockfile
pnpm run verify
```

CI runs the same keyless gate: workflow lint plus
[`@uinaf/skillcheck`](https://github.com/uinaf/skillcheck) structural lint.

See [Distribution](docs/distribution.md) for consumer ownership and
[Skill fleet](docs/skill-fleet.md) for the put.io skill inventory.

## Security

Report security or privacy issues through [Security](SECURITY.md).

## License

Licensed under the [MIT License](LICENSE).
