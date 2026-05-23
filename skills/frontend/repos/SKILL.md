---
name: putio-frontend-repos
description: Structure put.io frontend-owned repositories around repo-local verify and delivery contracts. Use when standardizing package repos, app repos, or SDK repos across TypeScript, Swift, Kotlin, or similar ecosystems; defining the verify command CI should call; aligning publish/deploy flows on main after verify passes; or fixing repo shape that blocks repeatable release or deployment work. Skip generic CI/CD design that does not depend on repo structure.
---

# Frontend Repos

Use one delivery rule: every merge to `main` should already be publishable or deployable.

Bundled references: [delivery model](./references/delivery-model.md), [TypeScript](./references/typescript.md), [applications](./references/applications.md), [secrets](./references/secrets.md), and [release security](./references/release-security.md).
This skill owns repo shape and canonical commands, not host-specific deployment architecture or detailed frontend test harness design.

## Workflow

1. Run the inspection commands below and capture the summary before editing.
2. Read [delivery model](./references/delivery-model.md).
3. If the repo is TypeScript, read [TypeScript](./references/typescript.md).
4. If the repo is an application, read [applications](./references/applications.md).
5. If the repo uses local/dev secrets, live-test env files, Infisical, legacy `op`/1Password setup, or secret-bearing build/signing/deploy workflows, read [secrets](./references/secrets.md) and standardize the local env shape.
6. If the repo has secret-bearing release, deploy, signing, publish, beta, backfill, or binary-build workflows, read [release security](./references/release-security.md).
7. If the repo owns live, e2e, QA, emulator, simulator, browser, extension, TV, native, or device test harness commands, keep this skill focused on repo-local entrypoints and sanitized env/profile names; detailed auth/session, flow, assertion, and artifact design belongs with the harness implementation and its local docs.
8. Prefer one repo-local `verify` entrypoint that CI calls directly.
9. Run the repo-local `verify` command locally before changing delivery automation. If it fails, fix that command first and rerun it until it passes.
10. Configure semantic-release plugins and commit identity per the delivery-model reference when release commits are in scope.
11. Verify the publish or deploy path only after the repo-local `verify` command is stable and reproducible.
12. Keep release and publishing docs in `docs/DISTRIBUTION.md`; `CONTRIBUTING.md` links there as contributor navigation.
13. After publish or deploy changes, run the repo-documented artifact or app smoke check. If none exists, record that as a repo gap.

Summary shape:

```markdown
- Repo kind:
- Verify entrypoint:
- Delivery target:
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
  run: pnpm verify

- name: Release
  if: github.ref == 'refs/heads/main'
  run: pnpm release
```

App-shaped example:

```yaml
- name: Verify
  run: make verify

- name: Deploy Beta
  if: github.ref == 'refs/heads/main'
  run: make deploy-beta
```

## Guardrails

- Keep the repo-local `verify` command as the source of truth for guardrails.
- Prefer GitHub Actions for orchestration and repo-local commands as the canonical home for build, test, and deliver logic.
- For frontend test harnesses, expose stable repo-local targets and sanitized `.env.example` profile names here; keep auth/session, deep-link, fixture, platform-input, assertion, and proof-artifact doctrine in the harness implementation and local docs.
- Use release tooling backed by a real repo precedent or team standard.
- Keep manual release paths on trusted refs before they reach secret-bearing jobs.
- Avoid GitHub Actions artifacts as a release/deploy registry. They are temporary CI storage with quota and retention failure modes; prefer same-job deploy handoff for simple static surfaces, or deploy from a GitHub Release asset, package registry, image digest, or provider-native package for versioned releases.
- Put release credential policy, protected Environment setup, and tag rules in `docs/DISTRIBUTION.md`; leave contributor docs as workflow/setup guidance.
- GitHub-facing repos should carry a useful pull request template and issue templates when the review or triage flow benefits from them.
