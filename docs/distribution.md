# Distribution

This repository is the source of truth for its two skills. Consumers install
them directly from the `skills/` tree. There is no publish pipeline.

## Consumer ownership

- `putio-frontend-dev` and `putio-sdk-dev` are maintained here.
- `putio-cli` is maintained in
  [putdotio/putio-cli](https://github.com/putdotio/putio-cli).
- Global consumers install the owner copy with the `skills` CLI.
- Harness-local and repository-local copies are not sources of truth.

## Quality gate

Every pull request and push to `main` runs `pnpm run verify`. A scheduled
workflow repeats the same keyless gate monthly.
