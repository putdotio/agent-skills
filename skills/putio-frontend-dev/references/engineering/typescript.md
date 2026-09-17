# TypeScript repo defaults

Default TypeScript package layout: `putio-sdk-typescript`. TypeScript app repos keep the same verify-first delivery shape.

## Defaults

- Use Vite+ (`vp`) for install, check, build, and test flows.
- Expose one repo-local `verify` script and let CI call it directly.
- Use the same repo shape across TypeScript libraries and apps.
- Use GitHub Actions for release orchestration.
- If the repo uses semantic-release for npm publishing and release notes, run it from the release workflow by default.
- Keep CI/CD-only semantic-release plugins in the workflow `extra_plugins` list with exact versions. Add them to repo `devDependencies` only when the repo intentionally supports local release execution.
- When using semantic-release, configure both the commit analyzer and release notes generator with the `conventionalcommits` preset and include `conventional-changelog-conventionalcommits` in the workflow plugin list.
- When `@semantic-release/git` writes a release commit, tag, GitHub Release, or asset, use the `putio-releaser` identity rules in the [delivery model checklist](../delivery/model.md#checklist).

## Expected shape

- local commands for `check`, `build`, `test`, and `verify`
- CI setup with full-SHA-pinned `voidzero-dev/setup-vp` for repos that use Vite+ (`vp`), including release jobs
- `vp install` before verification or release
- Secret-bearing npm release and publish jobs follow the cache and pinning rules in [release security](../delivery/release-security.md#actions-and-toolchains)
- `verify` on pull requests and `main` pushes
- a GitHub Actions delivery job on `main` after `verify` passes

## Build tooling

- Use the current team default toolchain for package builds, including Vite+ and `tsdown` where appropriate.
- Keep build-tool choice behind repo scripts so the workflow model does not change when packaging details do.
- A different build tool keeps the same verify/release shape unless there is a strong reason not to.
- For release-critical TypeScript build scripts, prefer typed `.ts` or `.mts` files when the repo's Node runtime can execute them without release-only dependencies.
