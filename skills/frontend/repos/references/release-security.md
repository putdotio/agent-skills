# Release Supply Chain

Use this when touching GitHub Actions workflows that publish packages, upload app builds, sign artifacts, deploy apps, promote beta builds, backfill releases, or build standalone binaries.

## Trusted Refs

- Secret-bearing jobs check out fixed trusted refs: beta from `main`, release from a published `v*` tag, or an explicitly validated protected ref
- Treat the workflow run ref and the checkout ref as separate trust boundaries. A GitHub Environment branch or tag policy constrains the run ref; it does not prove that `inputs.ref` is safe to check out later
- `workflow_dispatch` inputs are validated and bounded in a secretless step before they influence jobs that load secrets, sign artifacts, publish packages, or upload release assets
- For manual backfills, validate the tag/ref in a separate secretless job, make build jobs depend on it, and use a sanitized output in `actions/checkout` `with.ref`

## Repo Settings Model

- Public frontend-owned repos use four defaults: `main` push allowlist, protected `v*` tags, approval-free continuous release Environments, and `putio-release-bot` for automated GitHub writes
- Private repos without paid GitHub protection document the limitation and compensate with Environment gates, fixed checkout refs, action pinning, validated manual inputs, and least-privilege credentials
- Reviewer-gated Environments are separate production deploy, signing, promotion, or store-submission gates when a repo explicitly needs them
- Release workflows store `PUTIO_RELEASE_BOT_APP_ID` as a protected Environment variable and `PUTIO_RELEASE_BOT_PRIVATE_KEY` as a protected Environment secret
- Push-back jobs mint a `putio-release-bot` installation token and set matching `GIT_AUTHOR_*` / `GIT_COMMITTER_*`. Commit metadata is not authorization: `GITHUB_TOKEN` writes as `github-actions[bot]`
- If a third-party publish action creates commits internally, verify it accepts release-bot identity inputs or honors `GIT_AUTHOR_*` / `GIT_COMMITTER_*`

### Allowing the put.io Team to Push

- Branch protection: rule for `main`, "Require a pull request before merging" off, "Restrict who can push" on, allowed actors `put-io` and `putio-release-bot`
- Rulesets: avoid a broad bypass that also permits force-push or delete. Prefer a no-bypass baseline rule for deletion/force-push protection plus a narrow update rule for allowed push actors

### Release Tags

- Tag ruleset: protect `v*`; allow only `putio-release-bot` and org-admin bypass for creation, update, and deletion
- Workflows that create GitHub Releases, upload release assets, or move `v*` tags use a `putio-release-bot` installation token
- Keep the release path pinned, least-privilege, ref-validated, and provenance-checked before publishing or promoting

## Inputs

- Never interpolate `workflow_dispatch` inputs directly inside shell `run:` scripts
- Pass inputs through `env`, validate format and length, then use shell variables such as `$TAG_NAME` or `$env:TAG_NAME`. For later action inputs, emit sanitized step outputs rather than reusing raw `${{ inputs.* }}`
- Keep multiline untrusted input out of `$GITHUB_ENV`; sanitize it first or use heredoc-safe patterns that cannot be broken by attacker-controlled delimiters
- Move non-secret metadata prep before any secret-loading step whenever possible

## Actions and Toolchains

- Pin release, publish, upload, signing, and deploy actions to full commit SHAs with a trailing comment for the human version tag
- In release paths, preserve the repo's normal toolchain contract when it can be pinned. For repos that use Vite+ (`vp`), use a full-SHA-pinned `voidzero-dev/setup-vp` plus `vp install` / `vp run ...`. Fall back to pinned `actions/setup-node`, `corepack enable`, and `pnpm install --frozen-lockfile` when the repo does not use Vite+ or when Vite+ setup cannot be trusted for that release path
- Verify downloaded runtime or toolchain archives before extraction or embedding. Functional smoke tests prove behavior; they do not prove provenance
- For Node SEA or binary builds, download the official checksum file, match the exact platform archive name, hash the archive, and fail before extraction on mismatch
- Keep security-sensitive build logic typed when the repo supports it without extra dependencies. In TypeScript repos, prefer `.ts` or `.mts` scripts over loosely typed `.mjs` for release-critical logic
- Shell installers for downloaded binaries normalize the final executable mode, for example `0755`, and reject group/world-writable install directories unless the repo exposes an explicit opt-in for shared installs

## Caches and Generated Trees

- Do not restore generated dependency trees across trust boundaries into signed or release jobs. Examples include full CocoaPods `Pods` trees and other generated vendor directories
- Cache download artifacts where possible, then regenerate and verify generated trees before signing or publishing
- If a generated-tree cache is unavoidable, namespace by workflow, event, trust level, platform, and lockfile; release jobs must not consume caches written by PR or beta jobs
- `bootstrap-ci.sh`-style shortcuts that skip regeneration only from lockfile equality are acceptable for local speed, but risky when a generated tree came from a shared CI cache

## Provenance

- Release workflows should build and upload the release artifact from the release tag
- Do not promote an existing beta, TestFlight, App Store Connect, npm, or GitHub artifact into release unless provenance is recorded and verified
- Required promotion provenance: commit SHA, tag, build number or package version, artifact digest, workflow run id, and the originating artifact identity
- When reviewing findings, separate stale evidence from current truth. If a direct cache or checkout path was removed, keep only the surviving path that still reaches signing, publishing, or promotion

## Live Settings to Check

Before final severity or remediation calls, inspect live GitHub state:

- `main` branch push restrictions or documented private-repo fallback
- release tag policy for `v*`: protected by `putio-release-bot` plus org-admin bypass, or a documented private-repo fallback when GitHub plan limits apply
- Environment approval posture, branch policy, and tag policy
- Actions cache contents and cache write/read boundaries
- Actions permission policy and job-level `permissions`
- where secrets live: repo, org, Environment, or external manager

## Docs to Update

When release, cache, provenance, or signing behavior changes, update repo-local docs in the same change. Put release and publishing behavior in `docs/DISTRIBUTION.md`; keep `CONTRIBUTING.md` focused on contributor setup and validation, and let `README.md` / `AGENTS.md` link to the distribution doc when useful.
