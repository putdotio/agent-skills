# Application Repo Defaults

Use this when the repo is an application rather than a published package.

## Core Model

- Keep the same `VERIFY` first rule as package repos.
- Treat deploys as the app equivalent of package publishing.
- Prefer one repo-local deploy command per delivery target, such as `deploy-preview`, `deploy-beta`, or `deploy-production`.
- Run deploy jobs from GitHub Actions after `VERIFY` passes.

## Expected Shape

- one repo-local `verify` entrypoint
- one CI verify job that runs it on pull requests and `main` pushes
- one or more deploy jobs gated on `verify`
- a deterministic promotion signal, usually pushes or tags on `main`
- no manual checklist-driven deploy flow unless the platform truly requires it

## Delivery Targets

- Web apps: preview or production hosting
- Native apps: TestFlight, beta tracks, or store delivery
- Internal apps or tools: staging or production environments

## Guardrails

- Keep deploy logic behind local commands so workflow YAML stays thin.
- Use the smallest set of secrets and permissions required for each deploy target.
- Prefer continuous beta or preview delivery by default, with stricter promotion gates only where the product or platform requires them.
- If the repo has multiple delivery targets, keep their commands explicit instead of overloading one generic `deploy`.
