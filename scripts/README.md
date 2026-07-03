# Scripts

Helpers for local Tessl review loops in this repo.

## Batch review

Run Tessl review across every skill:

```bash
./scripts/review-skills.sh
```

When Tessl authentication is unavailable, the wrapper runs `tile lint` for each
skill package instead. This keeps unauthenticated CI useful while authenticated
local and publish paths can still run scored reviews.

Override the threshold or pass extra review flags:

```bash
TESSL_THRESHOLD=92 ./scripts/review-skills.sh
./scripts/review-skills.sh --threshold 95
```

The wrapper pins the Tessl CLI through `TESSL_CLI_VERSION` and defaults to
version `0.80.0`; bump that default intentionally instead of relying on moving npm
latest.

The batch wrapper does not support JSON output. For structured output, run Tessl directly on one skill:

```bash
npx tessl@0.80.0 skill review skills/frontend/repos
npx tessl@0.80.0 skill review --json --threshold 90 skills/frontend/repos
```

## Optimize one skill

Apply one Tessl optimization pass to a single skill:

```bash
./scripts/optimize-skills.sh frontend/repos
./scripts/optimize-skills.sh frontend/repos --threshold 92
```

This mutates files. Review the diff before committing.

## Notes

- `review-skills.sh` is the batch entrypoint for local skill review
- `tessl.sh` runs the pinned Tessl CLI with `npx`
- `optimize-skills.sh` applies mutations, so run it intentionally and inspect the resulting diff
- CI runs `./scripts/review-skills.sh` on pull requests and pushes to `main`.
  Unauthenticated CI falls back to `tile lint`; authenticated local and publish
  paths still run scored reviews before publishing `main` changes under
  `skills/**`
