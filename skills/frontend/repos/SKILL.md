---
name: putio-frontend-repos
description: "Set up put.io frontend repos: README/CONTRIBUTING/SECURITY, CI, package scripts, verify commands, release workflows, deploy pipelines, test harnesses, and publish/deploy flows. Use for repo setup, repo cleanup, project setup, configuring CI or deployment, or making a package/app/SDK repo documented, verifiable, and deliverable. Skip feature code, SDK API work, Vite+ migrations, and self-verification."
---

# Frontend Repos

Use one repo rule: every merge to `main` should already be documented, verifiable, and publishable or deployable when the repo has a delivery target.

Bundled references: [docs](./references/docs.md), [delivery model](./references/delivery-model.md), [TypeScript](./references/typescript.md), [applications](./references/applications.md), [secrets](./references/secrets.md), [release security](./references/release-security.md), and [test harness](./references/test-harness.md).
This skill owns repo shape, top-level docs, canonical commands, and proof-loop entrypoints, not feature implementation or SDK API design.

## Scope

- In scope: top-level docs, repo-local scripts, verify entrypoints, package/app/SDK release shape, publish/deploy handoff contracts, and frontend proof-loop design.
- Out of scope: feature code, SDK API surface work, repository policy, Actions hardening, bootability gaps, Vite+ migrations, and builder self-verification.
- After changing a repo, run its verification path; this skill defines the contract, but verification proves the result.

## Workflow

1. Run the inspection commands below and capture the summary before editing.
2. If top-level docs are in scope, read [docs](./references/docs.md).
3. If CI, release, publish, deploy, or repo-local commands are in scope, read [delivery model](./references/delivery-model.md), then only matching references: [TypeScript](./references/typescript.md), [applications](./references/applications.md), [secrets](./references/secrets.md), or [release security](./references/release-security.md).
4. If live, e2e, QA, emulator, simulator, browser, extension, TV, native, or device proof loops are in scope, read [test harness](./references/test-harness.md).
5. Prefer one repo-local `verify` entrypoint that CI calls directly.
6. Run the repo-local `verify` command locally before changing delivery automation. If it fails, fix that command first and rerun it until it passes.
7. Configure semantic-release plugins and commit identity per the delivery-model reference when release commits are in scope.
8. Verify the publish, deploy, or harness smoke path only after the repo-local `verify` command is stable and reproducible.
9. Keep release and publishing docs in `docs/DISTRIBUTION.md`; `CONTRIBUTING.md` links there as contributor navigation.
10. After publish, deploy, or harness changes, run the repo-documented artifact/app/proof smoke check. If none exists, record that as a repo gap.

Summary shape:

```markdown
- Repo kind:
- Verify entrypoint:
- Top-level docs:
- Delivery target:
- Proof harness:
- Versioning/release:
- Secret/env needs:
- Template gaps:
```

Useful inspection commands:

```bash
rg -n '"verify"|"release"|"build"|semantic-release|deploy|publish|OP_SERVICE_ACCOUNT_TOKEN|PUTIO_1PASSWORD|op://|infisical|INFISICAL' \
  package.json Makefile .github README.md CONTRIBUTING.md SECURITY.md docs .env.example scripts tooling apps 2>/dev/null

test -f package.json && jq '.scripts // {}' package.json
test -f Makefile && rg -n '^[a-zA-Z0-9_.:-]+:' Makefile
test -d .github && find .github -maxdepth 3 -type f | sort
```

Concrete example:

```json
{
  "scripts": {
    "verify": "pnpm lint && pnpm test && pnpm build"
  }
}
```

```yaml
- name: Verify
  run: pnpm verify # or make verify for app-shaped repos

- name: Release
  if: github.ref == 'refs/heads/main'
  run: pnpm release # or make deploy-beta for app-shaped repos
```

## Guardrails

- Keep the repo-local `verify` command as the source of truth for guardrails.
- Prefer GitHub Actions for orchestration and repo-local commands as the canonical home for build, test, and deliver logic.
- Use docs, release, deploy, and harness tooling backed by real repo precedent or team standard.
- Keep manual release paths on trusted refs before they reach secret-bearing jobs.
- Do not use GitHub Actions artifacts as a release/deploy registry; prefer same-job deploy handoff, GitHub Release assets, package registries, image digests, or provider-native packages.
- Put release credential policy, protected Environment setup, and tag rules in `docs/DISTRIBUTION.md`; leave contributor docs as workflow/setup guidance.
- GitHub-facing repos should carry a useful pull request template and issue templates when the review or triage flow benefits from them.
