# Repo Delivery Model

Use this as the default frontend repo shape at put.io. Package repos publish continuously. App repos deploy continuously.

## Core Model

- `VERIFY` runs on pull requests and `main` pushes.
- delivery runs on `main` only, after `VERIFY` passes.
- GitHub Actions owns orchestration; the repo owns build, test, and publish-ready or deploy-ready commands.
- The repo exposes one local `verify` entrypoint that CI calls directly.
- Delivery is continuous: every merge to `main` is assumed publishable or deployable.
- Keep one canonical owner per concern instead of duplicating the same rule across commands, workflows, and docs.

## Default Shape

1. One repo-local verify command or script.
2. One `verify` CI job that runs it.
3. One delivery job gated on `verify`.
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
- Orchestration stays in GitHub Actions unless there is an established repo standard that says otherwise.
- Repos hosted on GitHub include collaboration templates when they improve review or triage, especially `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/*`.
- Package release jobs are safe to no-op when there are no releasable commits.
- Delivery jobs use only the permissions and secrets they actually need.
- Secret-bearing release, deploy, signing, publish, beta, backfill, and binary-build jobs follow [release security](./release-security.md).
- Release jobs that create follow-up commits, release tags, GitHub Releases, or release assets use `putio-releaser` and set commit author/committer metadata to the app bot identity.
- Protected `main` and `v*` push-back needs an allowed actor that matches the token. Use a `putio-releaser` installation token for release writes instead of relying on `GITHUB_TOKEN` or spoofing a human/team mailbox.
- Release automation fetches full git history when versioning depends on commits or tags.
- For Swift, Kotlin, and other ecosystems, keep this model and choose the smallest repo-native toolchain that CI can call unchanged.
- Packages publish. Apps deploy. The verify-first model stays the same.

Semantic-release example:

```json
{
  "plugins": [
    ["@semantic-release/commit-analyzer", { "preset": "conventionalcommits" }],
    ["@semantic-release/release-notes-generator", { "preset": "conventionalcommits" }]
  ]
}
```

## Collaboration Templates

Keep review and triage prompts close to the repo instead of relying on maintainers to remember them.

- Pull request templates should ask for the most useful evidence for the kind of change:
  - screenshots or screen recordings for UI, layout, onboarding, animation, or copy changes
  - sanity checks for risky or user-visible flows
  - before and after benchmark numbers for performance-sensitive changes
  - rollout, risk, or follow-up notes when the change touches auth, persistence, release flow, or external integrations
- Issue templates should ask for reproducible signals:
  - steps to reproduce
  - expected versus actual behavior
  - logs, console output, screenshots, or videos when relevant
  - environment details when platform differences matter
- Keep templates short enough that people fill them out honestly. Prefer `N/A` prompts over giant mandatory essays.
- Treat templates as the detailed source of truth for review and triage prompts. `CONTRIBUTING.md` should summarize the expectation without copying the full checklist.
- Release and publishing behavior belongs in `docs/DISTRIBUTION.md`: delivery model, publish target, protected Environment requirements, release bot identity, tag policy, and release-specific smoke checks. `CONTRIBUTING.md` links there as contributor navigation.
