# TypeScript repo defaults

Default TypeScript package layout: `putio-sdk-typescript`. TypeScript libraries and apps share the verify-first [delivery model](../delivery/model.md).

## Defaults

- Use Vite+ (`vp`) for install, check, build, and test flows, with local `check`, `build`, `test`, and `verify` commands.
- In CI, set up with a full-SHA-pinned `voidzero-dev/setup-vp`, including release jobs, and run `vp install` before verification or release.
- npm packages release through the shared `frontend-release-npm` workflow in [putdotio/.github](https://github.com/putdotio/.github); its README owns the calling contract.
- Repos that run semantic-release in their own workflow keep CI/CD-only plugins in the workflow `extra_plugins` list with exact versions, adding them to repo `devDependencies` only when the repo intentionally supports local release execution. Configure both the commit analyzer and release notes generator with the `conventionalcommits` preset and include `conventional-changelog-conventionalcommits` in the plugin list.
- Release writes by `@semantic-release/git` or GitHub Release plugins use the `putio-releaser` identity from [release security](../delivery/release-security.md#repo-settings-model); secret-bearing jobs follow its [cache and pinning rules](../delivery/release-security.md#actions-and-toolchains).

## Build tooling

- Use the current team default toolchain for package builds, including Vite+ and `tsdown` where appropriate.
- Keep build-tool choice behind repo scripts so the workflow model does not change when packaging details do.
- For release-critical TypeScript build scripts, prefer typed `.ts` or `.mts` files when the repo's Node runtime can execute them without release-only dependencies.
