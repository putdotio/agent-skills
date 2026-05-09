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
- Package/library/CLI/skill release jobs use the approval-free `release` Environment as a secret boundary with `deployment: false`; app deploy, beta, signing, promotion, and store-submission jobs keep deployment records when they represent real deployments
- Release workflows store `PUTIO_RELEASE_BOT_CLIENT_ID` as a protected Environment variable and `PUTIO_RELEASE_BOT_PRIVATE_KEY` as a protected Environment secret
- Push-back jobs mint a `putio-release-bot` installation token and set matching `GIT_AUTHOR_*` / `GIT_COMMITTER_*`. Commit metadata is not authorization: `GITHUB_TOKEN` writes as `github-actions[bot]`
- If a third-party publish action creates commits internally, verify it accepts release-bot identity inputs or honors `GIT_AUTHOR_*` / `GIT_COMMITTER_*`

### Allowing the put.io Team to Push

- Branch protection: rule for `main`, "Require a pull request before merging" off, "Restrict who can push" on, allowed actors `put-io` and `putio-release-bot`
- Rulesets: prefer a no-bypass baseline rule for deletion/force-push protection plus a narrow update rule for allowed push actors

### Release Tags

- Tag ruleset: protect `v*`; allow only `putio-release-bot` and org-admin bypass for creation, update, and deletion
- Workflows that create GitHub Releases, upload release assets, or move `v*` tags use a `putio-release-bot` installation token
- Keep the release path pinned, least-privilege, ref-validated, and provenance-checked before publishing or promoting

## Inputs

- Pass `workflow_dispatch` inputs through `env` and sanitized step outputs before shell use
- Pass inputs through `env`, validate format and length, then use shell variables such as `$TAG_NAME` or `$env:TAG_NAME`. For later action inputs, emit sanitized step outputs rather than reusing raw `${{ inputs.* }}`
- Keep multiline untrusted input out of `$GITHUB_ENV`; sanitize it first or use heredoc-safe patterns that cannot be broken by attacker-controlled delimiters
- Move non-secret metadata prep before any secret-loading step whenever possible

## Actions and Toolchains

- Use GitHub-hosted floating runner labels for routine CI and release jobs: `ubuntu-latest`, `windows-latest`, and `macos-latest`. Pin a runner image only when the OS image is part of the tested toolchain contract, and document that reason next to the workflow or in the repo release docs
- Pin release, publish, upload, signing, and deploy actions to full commit SHAs with a trailing comment for the human version tag
- In release paths, preserve the repo's normal toolchain contract when it can be pinned. For repos that use Vite+ (`vp`), use a full-SHA-pinned `voidzero-dev/setup-vp` plus `vp install` / `vp run ...`. For pnpm repos that do not use Vite+, use full-SHA-pinned `actions/setup-node` for the Node version, then full-SHA-pinned `pnpm/action-setup@v6` with `cache: true`, then `pnpm install --frozen-lockfile`
- For semantic-release action workflows, keep CI/CD-only release plugins in `extra_plugins` rather than repo `devDependencies`, and pin every plugin entry to an exact version
- Verify downloaded runtime or toolchain archives before extraction or embedding. Pair functional smoke tests with provenance checks
- For Node SEA or binary builds, download the official checksum file, match the exact platform archive name, hash the archive, and fail before extraction on mismatch
- Keep security-sensitive build logic typed when the repo supports it without extra dependencies. In TypeScript repos, prefer `.ts` or `.mts` scripts over loosely typed `.mjs` for release-critical logic
- Shell installers for downloaded binaries normalize the final executable mode, for example `0755`, and reject group/world-writable install directories unless the repo exposes an explicit opt-in for shared installs

## SST Deploy Roles

- Bind GitHub OIDC deploy roles to the repo and protected Environment that owns the deploy, and keep AWS account IDs, Route 53 zone IDs, certificate ARNs, and role ARNs in repo variables
- For first SST deploys, start with enough AWS access for SST bootstrap plus the app's components, then trim after a successful deploy with CloudTrail or IAM Access Analyzer evidence
- Record the steady-state policy in the repo's release or infra docs, including the component-specific actions observed during deploy
- For `sst.aws.StaticSite`, include the SST state and asset buckets, the app bucket prefix, CloudFront, the hosted zone, read access to the existing ACM certificate, and the SSM `/sst/*` parameter path
- For `StaticSite` assets and invalidations, include S3 bucket refresh reads used by the Pulumi AWS provider: ACL, CORS, policy, public-access-block, request-payment, tagging, website, versioning, logging, lifecycle, replication, encryption, and object-lock configuration
- When SST creates CloudFront key-value store metadata for a static site, include `cloudfront-keyvaluestore:DescribeKeyValueStore` and `cloudfront-keyvaluestore:UpdateKeys` for the deploy role

## Caches and Generated Trees

- Regenerate or verify generated dependency trees inside signed or release jobs. Examples include full CocoaPods `Pods` trees and other generated vendor directories
- Cache download artifacts where possible, then regenerate and verify generated trees before signing or publishing
- If a generated-tree cache is unavoidable, namespace by workflow, event, trust level, platform, and lockfile; release jobs consume only caches from the same trust level
- `bootstrap-ci.sh`-style shortcuts that skip regeneration only from lockfile equality are acceptable for local speed, but risky when a generated tree came from a shared CI cache

## Provenance

- Release workflows should build and upload the release artifact from the release tag
- Promote an existing beta, TestFlight, App Store Connect, npm, or GitHub artifact into release only when provenance is recorded and verified
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
