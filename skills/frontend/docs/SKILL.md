---
name: putio-frontend-docs
description: Structure and rewrite docs for frontend repositories, especially README.md, CONTRIBUTING.md, SECURITY.md, and other top-level docs. Use when creating or reorganizing frontend repo docs, clarifying user vs contributor guidance, reducing doc sprawl, or fixing stale commands, paths, and links in top-level docs.
---

# Frontend Docs

Shape frontend repo docs around a clear split between user-facing docs and contributor-facing docs.
Treat structure, labels, and ordering as part of the interface, not just as neutral file plumbing.

## Workflow

1. Inspect the repository before drafting.
2. Identify the project type, user install and usage flow, contributor setup flow, any GitHub collaboration templates already in use, and the best existing docs to link.
3. Read [references/readme-guideline.md](references/readme-guideline.md) before picking a final shape.
4. For README hero, logo, or badge work, inspect 2-3 sibling put.io repo READMEs first and reuse the concrete house style instead of inventing a new shape.
5. Start from [references/contributing-template.md](references/contributing-template.md) when creating or reshaping `CONTRIBUTING.md`.
6. Start from [references/security-template.md](references/security-template.md) when creating or reshaping `SECURITY.md`.
7. Put each concern in its canonical home: user flow in `README.md`, contributor workflow in `CONTRIBUTING.md`, security reporting in `SECURITY.md`, and detailed review prompts in GitHub templates.
8. Ensure the repo has `CONTRIBUTING.md`, `LICENSE`, and `SECURITY.md`; keep `SECURITY.md` private-first and use `devs@put.io` for security contact.
9. Push deep implementation detail into linked docs when it starts to bloat the top-level docs.
10. When a repo uses `AGENTS.md`, keep `CLAUDE.md` beside it as a symlink to `AGENTS.md` instead of maintaining a second authored guidance file.
11. In README `Docs`, `Key Docs`, `Start Here`, and similar routing lists, use document titles or reader-facing purposes as link labels, not raw filenames or paths. Prefer `Contributing`, `Distribution`, `Architecture`, or `Agent guide` over `CONTRIBUTING.md`, `docs/DISTRIBUTION.md`, or `AGENTS.md`.
12. In checked-in docs, use repo-relative Markdown links for local files. Reserve absolute filesystem paths for chat/UI file references, not versioned docs.
13. Verify that every claimed command, path, email address, doc link, badge target, and GitHub template path exists.
14. If any command, path, link, badge target, or template reference is broken, fix the doc and re-verify before stopping.

Concrete checks:

```bash
rg -n "README|CONTRIBUTING|SECURITY|AGENTS|CLAUDE|docs/|pull_request_template|ISSUE_TEMPLATE" README.md CONTRIBUTING.md SECURITY.md AGENTS.md CLAUDE.md docs/ .github/
test -e README.md && test -e CONTRIBUTING.md
test ! -e AGENTS.md || { test -L CLAUDE.md && test "$(readlink CLAUDE.md)" = "AGENTS.md"; }
```

## Guardrails

- Verify commands, environment variables, and deployment behavior against the repo.
- Do not freestyle put.io README branding. If a repo is put.io-branded, follow the sibling-repo hero/logo/badge pattern unless the user explicitly asks for a different brand treatment.
- Do not copy shared brand assets into package repos. Use the canonical hosted asset URL used by sibling repos unless the target repo is itself the static asset source.
- Prefer one canonical location per fact. Point to docs or templates instead of copying long checklists between them.
- Keep volatile metrics such as test counts or coverage numbers out of durable docs.
- Add sections only when they say something specific about the repo.
- Cite or link external repos only when they are relevant to the generated docs or explicitly requested.
- Make routing docs read like reader navigation. Link targets may be paths, but visible labels should usually be document titles or reader-facing purposes.
- Keep chat-only absolute filesystem links such as `/Users/...`, `file://...`, or `vscode://...` out of checked-in docs.
- Use only repo-specific docs helpers that actually exist.
- Mask or normalize user PII (names, emails, usernames, IPs, etc.) to generic placeholders such as `user@example.com` or `your-username`.
- Refer to third-party applications collectively as "ecosystem apps".
