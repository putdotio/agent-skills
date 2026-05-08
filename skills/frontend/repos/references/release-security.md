# Release Supply Chain

Use this when touching GitHub Actions workflows that publish packages, upload app builds, sign artifacts, deploy apps, promote beta builds, backfill releases, or build standalone binaries.

## Trusted Refs

- Secret-bearing jobs check out fixed trusted refs: beta from `main`, release from a published `v*` tag, or an explicitly validated protected ref
- Treat the workflow run ref and the checkout ref as separate trust boundaries. A GitHub Environment branch or tag policy constrains the run ref; it does not prove that `inputs.ref` is safe to check out later
- Do not let arbitrary `workflow_dispatch` inputs choose code for a job that loads secrets, signs artifacts, publishes packages, or uploads release assets
- For manual backfill flows, validate the tag/ref in a separate secretless job, make build jobs depend on it, and use `actions/checkout` `with.ref`
- Prefer repo settings that make the intended refs real: restrict `main` to `put-io`, require reviewers on release environments, and consider action SHA pinning on release workflows. Protect release tags only when the release automation can use a bypassable dedicated release app or equivalent trusted identity

## Repo Settings Model

- The default put.io posture is trusted-team direct pushes to `main`, strict release/deploy boundaries
- Public frontend-owned repos: protect `main` so only the `put-io` team can push, while force-pushes and branch deletes stay blocked. Do not require PRs on `main` unless the repo owner wants that workflow
- Private repos without paid GitHub protection: document that branch protection is unavailable, then compensate with Environment gates, fixed checkout refs, action pinning, validated manual inputs, and least-privilege deploy credentials
- Release tags such as `v*` should be created by trusted release automation or release admins only. If semantic-release or a similar workflow creates tags with `GITHUB_TOKEN`, do not add repo-level tag rules that would break releases. Keep tag rules off until the repo has a bypassable dedicated release app or equivalent trusted identity, then restrict `v*` creation, update, and deletion to that identity plus org admins
- Secret-bearing jobs still target protected Environments with required reviewers and self-review prevention, even when trusted team members can push directly to `main`

### Allowing The put.io Team To Push

- In GitHub branch protection, create a rule for `main`, leave "Require a pull request before merging" off, enable "Restrict who can push to matching branches", and add the `put-io` team or release app as allowed push actors
- Keep force-push and delete protection enabled for `main`
- If using rulesets instead, avoid a broad bypass that also permits force-push or delete. Prefer a no-bypass baseline rule for deletion/force-push protection plus a narrow update rule that only `put-io` can bypass

### Release Tags

- The current lightweight setup leaves `v*` tag rules off when workflows create tags with `GITHUB_TOKEN`; treat that as intentional interim state, not as a completed tag protection control
- Compensate with workflow hardening: protected release Environments, fixed trusted refs, validated manual inputs, action SHA pinning, least-privilege `permissions`, and provenance or artifact digest checks before publishing or promoting
- For hard tag protection, create a dedicated release GitHub App, mint an installation token inside the approved release workflow, and allow that app plus org admins to bypass a `v*` tag ruleset

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
- release tag policy for `v*`: protected by a dedicated release identity, or intentionally unprotected with workflow provenance controls
- Environment reviewers, self-review prevention, and branch/tag policy
- Actions cache contents and cache write/read boundaries
- Actions permission policy and job-level `permissions`
- where secrets live: repo, org, Environment, or external manager

## Docs To Update

When release, cache, provenance, or signing behavior changes, update repo-local docs in the same change. Usual homes are `docs/DISTRIBUTION.md`, `README.md`, `CONTRIBUTING.md`, setup docs, or the repo-local `AGENTS.md`.
