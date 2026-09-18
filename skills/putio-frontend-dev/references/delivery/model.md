# Repo delivery model

Use this as the default frontend repo shape at put.io. Package repos publish continuously. App repos deploy continuously.

Preserve an established multi-app task graph and its owner-defined verification
lanes. The single-entrypoint shape below is a starting point for new setups,
not a reason to replace scoped checks or fold separate package/device proof
into every default run. Retain full gates where the owner requires them.

## Core model

- `VERIFY` runs on pull requests and `main` pushes.
- delivery runs on `main` only, after `VERIFY` passes.
- GitHub Actions owns orchestration; the repo owns build, test, and publish-ready or deploy-ready commands.
- The repo exposes one local `verify` entrypoint that CI calls directly.
- Delivery is continuous: every merge to `main` is assumed publishable or deployable.
- Delivery targets: a package registry for packages; preview or production hosting for web apps; TestFlight, beta tracks, or store delivery for native apps; staging or production environments for internal tools. Deploys are the app equivalent of package publishing.
- One canonical owner per concern; do not duplicate a rule across commands, workflows, and docs.

## Default shape

1. One repo-local verify command or script.
2. One `verify` CI job that runs it.
3. One delivery job gated on `verify`
4. Conventional commits or another deterministic release or deploy signal.
5. No manual version bump or deploy checklist flow in normal delivery.
6. No repo-local release-only tooling by default; prefer workflow-level execution.

Inspection summary example:

```text
repo kind: app
verify entrypoint: make verify
delivery target: TestFlight beta on main
versioning: fastlane + git tags
template gaps: missing .github/pull_request_template.md
```

## Checklist

- `VERIFY` covers lint, typecheck, build, tests, and any package-specific guardrails.
- Workflow logic stays thin; repo commands own the complexity.
- Orchestration stays in GitHub Actions unless an established repo standard says otherwise.
- Repos hosted on GitHub include collaboration templates when they improve review or triage, especially `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/*`
- Package release jobs are safe to no-op when there are no releasable commits.
- Delivery jobs use only the permissions and secrets they need.
- App repos expose one repo-local deploy command per delivery target, such as `deploy-preview`, `deploy-beta`, or `deploy-production`, so workflow YAML stays thin. Do not overload one generic `deploy`.
- Beta and preview builds ship continuously. Add stricter promotion gates only where the product or platform requires them.
- Secret-bearing release, deploy, signing, publish, beta, backfill, and binary-build jobs follow [release security](./release-security.md).
- Release jobs that create follow-up commits, release tags, GitHub Releases, or release assets use a `putio-releaser` installation token. Set commit author and committer metadata to the app bot identity. `GITHUB_TOKEN` and a spoofed human or team mailbox do not qualify.
- Release automation fetches full git history when versioning depends on commits or tags.
- For Swift, Kotlin, and other ecosystems, keep this model and choose the smallest repo-native toolchain that CI can call unchanged.

Semantic-release example:

```json
{
  "plugins": [
    ["@semantic-release/commit-analyzer", { "preset": "conventionalcommits" }],
    ["@semantic-release/release-notes-generator", { "preset": "conventionalcommits" }]
  ]
}
```

## Collaboration templates

Keep review and triage prompts in the repo.

- Pull request templates ask for the most useful evidence for the kind of change:
  - screenshots or screen recordings for UI, layout, onboarding, animation, or copy changes, with the upload route named: `gh pr create --attach ./file.png` or `gh pr comment <n> --attach ./file.mp4` (gh 2.99+); a template that omits the route gets media committed to the branch
  - sanity checks for risky or user-visible flows
  - before and after benchmark numbers for performance-sensitive changes
  - rollout, risk, or follow-up notes when the change touches auth, persistence, release flow, or external integrations
- Issue templates ask for reproducible signals:
  - steps to reproduce
  - expected versus actual behavior
  - logs, console output, screenshots, or videos when relevant
  - environment details when platform differences matter
- Keep templates short. Prefer `N/A` prompts over mandatory essays.
- Templates are the detailed source of truth for review and triage prompts. `CONTRIBUTING.md` summarizes the expectation without copying the full checklist.
- Release and publishing behavior belongs in `docs/DISTRIBUTION.md`: delivery model, publish target, protected Environment requirements, release bot identity, tag policy, and release-specific smoke checks. `CONTRIBUTING.md` links there as contributor navigation.
