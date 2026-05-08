# Release Supply Chain

Use this when touching GitHub Actions workflows that publish packages, upload app builds, sign artifacts, deploy apps, promote beta builds, backfill releases, or build standalone binaries.

## Trusted Refs

- Secret-bearing jobs check out fixed trusted refs: beta from `main`, release from a published `v*` tag, or an explicitly validated protected ref
- Treat the workflow run ref and the checkout ref as separate trust boundaries. A GitHub Environment branch or tag policy constrains the run ref; it does not prove that `inputs.ref` is safe to check out later
- Do not let arbitrary `workflow_dispatch` inputs choose code for a job that loads secrets, signs artifacts, publishes packages, or uploads release assets
- For manual backfill flows, validate the tag/ref in a separate secretless job, make build jobs depend on it, and use `actions/checkout` `with.ref`
- Prefer repo settings that make the intended refs real: restrict `main` to `put-io` plus the release app, require reviewers on release environments, protect release tags, and consider action SHA pinning on release workflows

## Repo Settings Model

- The default put.io posture is trusted-team direct pushes to `main`, strict release/deploy boundaries, and a dedicated release bot for automated GitHub writes
- Public frontend-owned repos: protect `main` so only the `put-io` team and `putio-release-bot` can push, while force-pushes and branch deletes stay blocked. Do not require PRs on `main` unless the repo owner wants that workflow
- Private repos without paid GitHub protection: document that branch protection is unavailable, then compensate with Environment gates, fixed checkout refs, action pinning, validated manual inputs, and least-privilege deploy credentials
- Release tags such as `v*` are protected in public frontend-owned repos. Only `putio-release-bot` and org admins should create, update, or delete them
- Secret-bearing jobs still target protected Environments with required reviewers and self-review prevention, even when trusted team members can push directly to `main`
- Release workflows store `PUTIO_RELEASE_BOT_APP_ID` as a protected Environment variable and `PUTIO_RELEASE_BOT_PRIVATE_KEY` as a protected Environment secret
- Commit metadata is not authorization. When a release job pushes version bumps, tags, releases, or generated metadata, mint a `putio-release-bot` installation token and set `GIT_AUTHOR_*` and `GIT_COMMITTER_*` to the app bot identity. `GITHUB_TOKEN` means `github-actions[bot]`, not `devsputio` or `devs@put.io`

### Allowing The put.io Team To Push

- In GitHub branch protection, create a rule for `main`, leave "Require a pull request before merging" off, enable "Restrict who can push to matching branches", and add the `put-io` team plus `putio-release-bot` as allowed push actors
- Keep force-push and delete protection enabled for `main`
- Release jobs that push back to `main` use `putio-release-bot`, not `GITHUB_TOKEN`, a human PAT, or spoofed human commit metadata
- If using rulesets instead, avoid a broad bypass that also permits force-push or delete. Prefer a no-bypass baseline rule for deletion/force-push protection plus a narrow update rule that only `put-io` can bypass

### Release Tags

- Public frontend-owned repos protect `v*` tags with an active tag ruleset. Only `putio-release-bot` and org admins bypass creation, update, and deletion restrictions
- Release workflows that create GitHub Releases, upload release assets, or create/move `v*` tags mint a `putio-release-bot` installation token inside the approved release workflow
- Keep workflow hardening in place: protected release Environments, fixed trusted refs, validated manual inputs, action SHA pinning, least-privilege `permissions`, and provenance or artifact digest checks before publishing or promoting

## Inputs

- Never interpolate `workflow_dispatch` inputs directly inside shell `run:` scripts
- Pass inputs through `env`, validate format and length, then use shell variables such as `$TAG_NAME` or `$env:TAG_NAME`
- Keep multiline untrusted input out of `$GITHUB_ENV`; sanitize it first or use heredoc-safe patterns that cannot be broken by attacker-controlled delimiters
- Move non-secret metadata prep before any secret-loading step whenever possible

## Actions And Toolchains

- Pin release, publish, upload, signing, and deploy actions to full commit SHAs with a trailing comment for the human version tag
- In release paths, prefer deterministic first-party setup over mutable convenience actions when that action can influence artifacts. For TypeScript package release jobs, pinned `actions/setup-node`, `corepack enable`, and `pnpm install --frozen-lockfile` is the safer fallback when `voidzero-dev/setup-vp` is not pinned or is too broad
- Verify downloaded runtime or toolchain archives before extraction or embedding. Functional smoke tests prove behavior; they do not prove provenance
- For Node SEA or binary builds, download the official checksum file, match the exact platform archive name, hash the archive, and fail before extraction on mismatch
- Keep security-sensitive build logic typed when the repo supports it without extra dependencies. In TypeScript repos, prefer `.ts` or `.mts` scripts over loosely typed `.mjs` for release-critical logic

## Caches And Generated Trees

- Do not restore generated dependency trees across trust boundaries into signed or release jobs. Examples include full CocoaPods `Pods` trees and other generated vendor directories
- Cache download artifacts where possible, then regenerate and verify generated trees before signing or publishing
- If a generated-tree cache is unavoidable, namespace by workflow, event, trust level, platform, and lockfile; release jobs must not consume caches written by PR or beta jobs
- `bootstrap-ci.sh`-style shortcuts that skip regeneration only from lockfile equality are acceptable for local speed, but risky when a generated tree came from a shared CI cache

## Provenance

- Release workflows should build and upload the release artifact from the release tag
- Do not promote an existing beta, TestFlight, App Store Connect, npm, or GitHub artifact into release unless provenance is recorded and verified
- Required promotion provenance: commit SHA, tag, build number or package version, artifact digest, workflow run id, and the originating artifact identity
- When reviewing findings, separate stale evidence from current truth. If a direct cache or checkout path was removed, keep only the surviving path that still reaches signing, publishing, or promotion

## Live Settings To Check

Before final severity or remediation calls, inspect live GitHub state:

- `main` branch push restrictions or documented private-repo fallback
- release tag policy for `v*`: protected by `putio-release-bot` plus org-admin bypass, or a documented private-repo fallback when GitHub plan limits apply
- Environment reviewers, self-review prevention, and branch/tag policy
- Actions cache contents and cache write/read boundaries
- Actions permission policy and job-level `permissions`
- where secrets live: repo, org, Environment, or external manager

## Docs To Update

When release, cache, provenance, or signing behavior changes, update repo-local docs in the same change. Usual homes are `docs/DISTRIBUTION.md`, `README.md`, `CONTRIBUTING.md`, setup docs, or the repo-local `AGENTS.md`.
