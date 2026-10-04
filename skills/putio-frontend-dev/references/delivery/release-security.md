# Release supply chain

Use this when touching GitHub Actions workflows that publish packages, upload app builds, sign artifacts, deploy apps, promote beta builds, backfill releases, or build standalone binaries.

Policy and live posture live in the put.io Notion workspace under Frontend / Delivery. Read the matching page before a release, posture, or secrets decision:

- [Delivery model](https://app.notion.com/p/3ded546ba2f58103ae8ce55b0f7a7f9d): targets, release identities, and trusted refs
- [Release security](https://app.notion.com/p/3ded546ba2f581a39ec9e28f38e6d3fc): repository rulesets, Environments, runners and CI cost, AWS deploy roles, dependency updates, the supply-chain incident runbook, and the live settings to check
- [Secrets management](https://app.notion.com/p/3ded546ba2f581e19b74c6d119adb228): where CI values live and how a new release Environment is created

Public frontend repos use shared default-branch and release-tag rulesets with no required pull requests, reviews, or status checks. Verify live provider settings before any severity, remediation, or status claim; repo docs and workflow files describe intent.

The rest of this file covers the workflow mechanics agents write.

## Triggers and inputs

- Do not use `pull_request_target` for workflows that check out, install, build, test, package, publish, sign, deploy, or otherwise execute project code. Keep fork and outsider code on `pull_request` with read-only credentials and no release secrets
- For manual backfills, validate the tag or ref in a separate secretless job, make build jobs depend on it, and pass its sanitized output to `actions/checkout` `with.ref`
- Pass `workflow_dispatch` inputs through `env`, validate format and length, then use shell variables such as `$TAG_NAME` or `$env:TAG_NAME`. For later action inputs, emit sanitized step outputs rather than reusing raw `${{ inputs.* }}`
- Keep multiline untrusted input out of `$GITHUB_ENV`; sanitize it first or use heredoc-safe patterns that attacker-controlled delimiters cannot break
- Move non-secret metadata prep before any secret-loading step where possible

## Release identity

- Package, library, CLI, and skill release jobs use the `release` Environment with `deployment: false`. App deploy, beta, signing, promotion, and store-submission jobs keep deployment records, as does any Environment with custom deployment protection rules
- Store `PUTIO_CI_APP_CLIENT_ID` as a protected Environment variable and `PUTIO_CI_APP_PRIVATE_KEY` as a protected Environment secret
- Jobs that push commits, create or push tags, create GitHub Releases, upload release assets, or move `v*` tags mint a `putio-ci` installation token and set matching `GIT_AUTHOR_*` / `GIT_COMMITTER_*`. Commit metadata is not authorization: `GITHUB_TOKEN` writes as `github-actions[bot]`, and a spoofed human or team mailbox does not qualify
- If a third-party publish action creates commits internally, verify it accepts release-bot identity inputs or honors `GIT_AUTHOR_*` / `GIT_COMMITTER_*`

## Actions and toolchains

- Take runner labels from the repo's existing workflows and the Release security page; do not invent labels. Routine Linux CI runs on Arm; jobs that produce or depend on x86_64 artifacts run on x86_64
- Pin an OS image when it is part of the tested toolchain contract, and document that reason next to the workflow or in the repo release docs
- npm publish jobs use the shared `frontend-release-npm` workflow in [putdotio/.github](https://github.com/putdotio/.github), which owns the runner default. Configure the package on npm with the GitHub owner/repo, workflow filename, and optional Environment; grant the release job `id-token: write`; keep `package.json` repository metadata aligned with that repo. Do not replace OIDC with a long-lived `NPM_TOKEN` without an explicit secret-boundary decision. When migrating a package to OIDC, remove the legacy `NPM_TOKEN` secret and its workflow mapping in the same change
- Pin release, publish, upload, signing, and deploy actions to full commit SHAs with an exact version comment such as `# v1.10.0`, not `# v1`, so Dependabot's `github-actions` updates can move them. Before committing a pin, verify the SHA still exists upstream and resolves to the advertised tag
- In secret-bearing jobs, preserve the repo's pinned toolchain but skip dependency caches. For Vite+ (`vp`) repos, use a full-SHA-pinned `voidzero-dev/setup-vp` with `cache: false`, then `vp install` / `vp run ...`. For pnpm repos without Vite+, use full-SHA-pinned `actions/setup-node` and `pnpm/action-setup@v6` without package-manager cache, then `pnpm install --frozen-lockfile`
- For semantic-release action workflows, keep CI/CD-only release plugins in `extra_plugins` rather than repo `devDependencies`, and pin every plugin entry to an exact version
- Keep checkout credentials unpersisted through install, build, and pack steps when possible. If semantic-release must push a version bump, introduce the release-bot write credential only at the release boundary, after dependency lifecycle scripts have finished
- Verify downloaded runtime or toolchain archives before extraction or embedding. For Node SEA or binary builds, download the official checksum file, match the exact platform archive name, hash the archive, and fail before extraction on mismatch
- Keep security-sensitive build logic typed when the repo supports it without extra dependencies. In TypeScript repos, prefer `.ts` or `.mts` scripts over loosely typed `.mjs` for release-critical logic
- Shell installers for downloaded binaries normalize the final executable mode, for example `0755`, and reject group/world-writable install directories unless the repo exposes an explicit opt-in for shared installs

## Caches and generated trees

- Verify jobs may use dependency caches; secret-bearing release, publish, signing, and deploy jobs install fresh. Include `${{ github.event_name }}` in cache keys so `pull_request` jobs cannot poison caches that privileged `push: main`, `workflow_dispatch`, or tag-driven jobs consume
- Regenerate or verify generated dependency trees, such as full CocoaPods `Pods` trees, inside signed or release jobs. Cache download artifacts where possible, then regenerate and verify before signing or publishing
- If a generated-tree or tool cache is unavoidable in a privileged job, namespace it by workflow, event, trust level, platform, and lockfile. Privileged jobs consume only caches written by the same trusted event class, and still verify the restored tree against the lockfile before signing or publishing
- `bootstrap-ci.sh`-style shortcuts that skip regeneration only from lockfile equality are acceptable for local speed, but risky when a generated tree came from a shared CI cache

## Handoffs and provenance

- For simple static surfaces where build, e2e, and deploy can safely share one trusted environment-scoped job, deploy the tested output from the runner filesystem and keep post-deploy smoke in a separate read-only job
- Versioned releases build and upload from the release tag, then deploy from the published boundary: GitHub Release asset, package registry version, container image digest, app-store/TestFlight build, or provider-native package. Verify the payload before loading deploy credentials where practical. Do not re-upload a published payload as an Actions artifact solely for deploy
- Promote an existing beta, TestFlight, App Store Connect, npm, or GitHub artifact into release only when provenance is recorded and verified: commit SHA, tag, build number or package version, artifact digest, workflow run id, and the originating artifact identity
- When reviewing findings, separate stale evidence from current truth. If a direct cache or checkout path was removed, keep only the surviving path that still reaches signing, publishing, or promotion

## Docs to update

Update the repo's `docs/DISTRIBUTION.md` in the same change when release, cache, provenance, or signing behavior changes; [collaboration templates](./model.md#collaboration-templates) lists what it holds.
