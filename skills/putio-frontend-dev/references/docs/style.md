# Top-level docs

Use this reference when `putio-frontend-dev` work touches README, CONTRIBUTING,
SECURITY, agent guidance, or other top-level repo docs.

Split put.io frontend repo docs into user-facing and contributor-facing files.
Structure, labels, and ordering are part of the interface.

## Scope

- In scope: put.io top-level doc shape, house style, public/private boundaries,
  target-repository README alignment, and doc drift cleanup.
- Out of scope: broad specs, plans, decisions, runbooks, repository policy, Actions hardening, and runtime proof.

## Workflow

1. Inspect the repository before drafting.
2. Identify the project type, user install and usage flow, contributor setup flow, GitHub collaboration templates already in use, and the best existing docs to link.
3. Read the [README guideline](./readme-guideline.md) before picking a final shape. It owns the file split, section order, hero and badge rules, link labels, and the `devs@put.io` security contact.
4. Start from the [contributing template](./contributing-template.md) when creating or reshaping `CONTRIBUTING.md` and the [security template](./security-template.md) for `SECURITY.md`
5. Ensure the repo has `CONTRIBUTING.md`, `LICENSE`, and `SECURITY.md`
6. Push deep implementation detail into linked docs when it starts to bloat top-level docs.
7. When a repo uses `AGENTS.md`, keep `CLAUDE.md` beside it as a symlink to `AGENTS.md` instead of a second authored guidance file.
8. In checked-in docs, use repo-relative Markdown links for local files. Reserve absolute filesystem paths such as `/Users/...`, `file://...`, or `vscode://...` for chat/UI file references, not versioned docs.
9. Verify every claimed command, path, email address, doc link, badge target, and GitHub template path. Fix broken ones and re-verify before stopping.

Checks:

```bash
rg --hidden -n "README|CONTRIBUTING|SECURITY|AGENTS|CLAUDE|docs/|pull_request_template|ISSUE_TEMPLATE" . \
  --glob 'README.md' \
  --glob 'CONTRIBUTING.md' \
  --glob 'SECURITY.md' \
  --glob 'AGENTS.md' \
  --glob 'CLAUDE.md' \
  --glob 'docs/**' \
  --glob '.github/**' || true
test -e README.md && test -e CONTRIBUTING.md
test ! -e AGENTS.md || { test -L CLAUDE.md && test "$(readlink CLAUDE.md)" = "AGENTS.md"; }
```

## Guardrails

- Do not freestyle put.io README branding. Preserve the target repo's public
  hero, logo, and badge contract unless the user asks for a different treatment.
  Do not copy shared brand assets into package repos; reuse a public hosted
  asset the target repo already owns, or keep the README text-only.
- One canonical location per fact. Point to docs or templates instead of copying long checklists between them.
- When documenting release or deploy workflows, name the durable handoff: same-job tested output, GitHub Release asset, registry package, image digest, or provider-native package. Do not document GitHub Actions artifacts as a release or deploy registry.
- Keep volatile metrics such as test counts or coverage numbers out of durable docs. Add sections only when they say something specific about the repo.
- Cite or link external repos only when they are relevant to the generated docs or explicitly requested.
- Use only docs helpers that exist in the repo.
- Mask user PII with generic placeholders and refer to third-party applications collectively as "ecosystem apps".
