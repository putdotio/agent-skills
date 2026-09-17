# Application repo defaults

Use this when the repo is an application rather than a published package. The
verify-first shape in the [delivery model](./delivery/model.md) applies
unchanged; deploys are the app equivalent of package publishing.

## Delivery targets

- Web apps: preview or production hosting
- Native apps: TestFlight, beta tracks, or store delivery
- Internal apps or tools: staging or production environments

## Guardrails

- Prefer one repo-local deploy command per delivery target, such as `deploy-preview`, `deploy-beta`, or `deploy-production`, so workflow YAML stays thin. Do not overload one generic `deploy`
- Run deploy jobs from GitHub Actions after `VERIFY` passes, on a deterministic promotion signal, usually pushes or tags on `main`
- Use the smallest set of secrets and permissions required for each deploy target.
- Prefer continuous beta or preview delivery by default, with stricter promotion gates only where the product or platform requires them. No manual checklist-driven deploy flow unless the platform truly requires it.
