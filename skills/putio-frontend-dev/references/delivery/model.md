# Repo delivery model

The org model lives in the put.io Notion workspace:
[Delivery model](https://app.notion.com/p/3ded546ba2f58103ae8ce55b0f7a7f9d)
under Frontend / Delivery owns targets per repo kind, the default shape, delivery
guardrails, release identities, and trusted refs. Each repo's distribution doc
owns its own targets, triggers, and gates. This file covers the repo mechanics
agents write.

Preserve an established multi-app task graph and its owner-defined verification
lanes. The single-entrypoint shape is a starting point for new setups, not a
reason to replace scoped checks or fold separate package or device proof into
every default run.

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
- npm release and repository scanning call the shared frontend workflows in [putdotio/.github](https://github.com/putdotio/.github), pinned to a tagged commit; that README owns the calling contract.
- Secret-bearing release, deploy, signing, publish, beta, backfill, and binary-build jobs follow [release security](./release-security.md), including the `putio-ci` identity for release writes.
- Verification checkouts keep the default depth. Full history belongs to release jobs and history scans only; a verify job that needs the merge base for affected-package detection fetches a blobless tree and deepens to the base instead.
- Change detection on pull requests reads the pull request API with `pull-requests: read` and needs no checkout.
- A job whose work is shorter than the measured runner start, checkout, and install on its runner shape is a candidate to merge into a sibling job on the same runner and trust level, with the tasks run concurrently. Measure that overhead per runner shape; GitHub does not publish it. Concurrent tasks share one runner's cores and memory, so compare the batched job with the parallel jobs before keeping it, and say whether latency or runner minutes is the target. Keep separate jobs for different runners, trust boundaries, or multi-minute work.
- Measure caches before keeping them. Record hit or miss, restore, install, and save seconds in the step summary; a dependency cache stays only when its expected cost from those numbers beats always installing cold. Try the package-manager store cache first, and in a monorepo measure a filtered install of the affected packages against restoring everything.
- Non-gating work such as coverage upload, cache markers, and summaries runs after the required check, never inside it.
- Shard tests only after measuring per-shard setup; doubling shards doubles setup, so shards pay off only when setup is a small fraction of test time.
- macOS and other platform-bound jobs run only for their platform's code paths, gated by a job-level condition or restricted to pull requests plus manual dispatch. Gate at job level behind an always-running `verify` aggregator, not with workflow-level `paths` filters, which leave a required check pending. A native repo that needs macOS on every pull request runs the primary platform there and the full platform matrix on `main`.
- For Swift, Kotlin, and other ecosystems, keep this model and choose the smallest repo-native toolchain that CI can call unchanged.

## Collaboration templates

GitHub-hosted repos include `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/*` when they improve review or triage.

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
