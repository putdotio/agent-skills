# Scripts

Helpers for local Tessl review loops in this repo.

## Full verification

Run the canonical local gate:

```bash
npm ci
make verify
```

This validates OpenAI interface prompt limits, then runs workflow lint, plugin
lint, Tessl Review, and a publish dry-run.

## Batch review

Run Tessl review across every skill:

```bash
./scripts/review-skills.sh
```

When Tessl authentication is unavailable, the wrapper runs `plugin lint` for each
skill package instead. This keeps unauthenticated CI useful while authenticated
local and publish paths can still run scored reviews.

Override the threshold or pass extra review flags:

```bash
TESSL_THRESHOLD=92 ./scripts/review-skills.sh
./scripts/review-skills.sh --threshold 95
```

The wrapper pins the Tessl CLI through `TESSL_CLI_VERSION` and defaults to
version `0.90.0`, the npm `latest` version verified on July 3, 2026. Bump that
default intentionally instead of relying on moving npm latest.

The batch wrapper does not support JSON output. For structured output, run Tessl directly on one skill:

```bash
npx tessl@0.90.0 review run --workspace putio skills/frontend/repos
npx tessl@0.90.0 review run --json --workspace putio --threshold 90 skills/frontend/repos
```

## Optimize one skill

Apply one Tessl optimization pass to a single skill:

```bash
./scripts/optimize-skills.sh frontend/repos
./scripts/optimize-skills.sh frontend/repos --threshold 92
```

This mutates files. Review the diff before committing.

## Publish changed skills

Publish changed Tessl plugins from the trusted `main` workflow:

```bash
./scripts/publish-skills.sh
```

Local runs default to dry-run mode. Set `PUBLISH_DRY_RUN=false` only when you
intend to publish from an authenticated trusted checkout.

## Notes

- `review-skills.sh` is the batch entrypoint for local Tessl Review runs
- `publish-skills.sh` is the workflow entrypoint for linting and publishing
  changed plugins, including any eval scenarios under `evals/`
- `tessl.sh` runs the pinned Tessl CLI with `npx`
- `optimize-skills.sh` applies mutations, so run it intentionally and inspect the resulting diff
- CI runs `./scripts/review-skills.sh` on pull requests and pushes to `main`.
  Unauthenticated CI falls back to `plugin lint`; authenticated local and publish
  paths still run scored reviews before publishing `main` changes under
  `skills/**`
