# TypeScript Repo Defaults

Use the new `putio-sdk-typescript` layout as the default TypeScript package reference, and keep the same verify-first delivery shape for TypeScript app repos too.

## Defaults

- Use Vite+ (`vp`) for install, check, build, and test flows.
- Expose one repo-local `verify` script and let CI call it directly.
- Prefer the same repo shape across TypeScript libraries and apps so setup and maintenance stay boring.
- Prefer GitHub Actions for release orchestration.
- If the repo uses semantic-release for npm publishing and release notes, run it from the release workflow by default.
- Keep CI/CD-only semantic-release plugins in the workflow `extra_plugins` list with exact versions. Add them to repo `devDependencies` only when the repo intentionally supports local release execution.
- When using semantic-release, configure both the commit analyzer and release notes generator with the `conventionalcommits` preset and include `conventional-changelog-conventionalcommits` in the workflow plugin list.
- When `@semantic-release/git` writes a release commit, mint a `putio-release-bot` installation token and set `GIT_AUTHOR_*` and `GIT_COMMITTER_*` so commit metadata matches the app bot identity.
- If `main` or `v*` is protected, verify `putio-release-bot` is allowed before relying on version-bump commits, tag creation, GitHub Releases, or asset uploads.

## Expected Shape

- local commands for `check`, `build`, `test`, and `verify`
- CI setup with full-SHA-pinned `voidzero-dev/setup-vp` for repos that use Vite+ (`vp`), including release jobs
- `vp install` before verification or release
- Use full-SHA-pinned `actions/setup-node` for the Node version, then full-SHA-pinned `pnpm/action-setup@v6` with `cache: true`, then `pnpm install --frozen-lockfile` for TypeScript repos that do not use Vite+ (`vp`)
- `verify` on pull requests and `main` pushes
- a GitHub Actions delivery job on `main` after `verify` passes

## Build Tooling

- Use the current team default toolchain for package builds, including Vite+ and `tsdown` where appropriate.
- Keep build-tool choice behind repo scripts so the workflow model does not change when packaging details do.
- If a repo needs a different build tool, preserve the same verify/release shape unless there is a strong reason not to.
- For release-critical TypeScript build scripts, prefer typed `.ts` or `.mts` files when the repo's Node runtime can execute them without adding release-only dependencies.
