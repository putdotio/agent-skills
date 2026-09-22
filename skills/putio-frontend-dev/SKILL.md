---
name: putio-frontend-dev
description: "Develop or review put.io end-user apps and shared frontend packages: UI, state, tests, docs, test harnesses, and delivery. Use in a put.io frontend repository or for put.io frontend conventions. Not for unrelated frontend work, browser-only put.io inspection, SDK or API client work, or putio CLI consumer operations; frontend test-harness auth setup stays in scope."
---

# put.io frontend development

Apply shared put.io frontend engineering defaults after the target repository's
own guidance and code precedent.

## Start

1. Read every filesystem `AGENTS.md` that applies from the target repo root to
   the files being changed, including untracked files. Then inventory tracked
   auxiliary guidance with `git ls-files '*AGENTS.md' '*SKILL.md'`.
2. Discover tracked project-local `SKILL.md` files under `.agents/skills/`,
   `.claude/skills/`, or `skills/`. Read the frontmatter and apply only the
   task-matching skills; ignore dependency and vendored trees.
3. Read the `README.md` sections and docs that cover the area being changed.
   Target-repo guidance and skills override this shared skill.
4. Identify the repo kind, stack, verify entrypoint, delivery target, and
   runtime proof surface.
5. Select only the references required for the task.

## Reference map

- Feature code, parsing, state, errors, components, and testing:
  [frontend defaults](./references/engineering/frontend-defaults.md)
- README, CONTRIBUTING, SECURITY, and agent-facing docs:
  [top-level docs](./references/docs/style.md)
- CI, verify, publishing, deployment, and release shape for packages and apps:
  [delivery model](./references/delivery/model.md)
- TypeScript package and app setup:
  [TypeScript defaults](./references/engineering/typescript.md)
- Machine tools, peer clones, agent worktrees, readiness check:
  [environment setup](./references/environment-setup.md)
- Local development secrets and CI credential boundaries:
  [secrets](./references/delivery/secrets.md)
- Secret-bearing release, signing, publishing, and deployment:
  [release security](./references/delivery/release-security.md)
- Browser, native, TV, emulator, simulator, and device proof:
  [test harness](./references/test-harness/overview.md)
- Shared test-account browser authorization:
  [test harness pattern](./references/test-harness/pattern.md)
- CLI-backed harness discovery, auth, reads, and writes:
  [CLI harness contract](./references/test-harness/cli.md)

Markdown links navigate this skill bundle. Other paths shown in the references,
such as `.github/pull_request_template.md`, name files to create or inspect in
the target repository.

## Repositories

- [repos.json](./repos.json) lists put.io repositories; frontend-owned entries
  list `frontend` in `owns`.
- Fields: `name` is the local folder, `repo` the GitHub remote, `path` the
  canonical checkout, `owns` the responsible teams, `visibility` the
  documentation boundary, `topics` the GitHub topic set (optional), `mode`
  whether the team's workspace tooling manages the checkout.
- An entry with several teams in `owns` is shared. In `putdotio/.github`,
  frontend work stays in the `frontend-*` workflows and the `frontend/`
  folder; in `putdotio/agent-skills`, in the `putio-*` skills.
- Peers sit under one folder, default `~/projects/putdotio/`. Missing path:
  `gh repo clone <repo> <path>`, or the clone loop in
  [environment setup](./references/environment-setup.md).
- Check `visibility` before quoting anything across repos; private content
  stays out of public ones.
- For tasks that span all frontend repos: iterate the entries whose `owns`
  includes `frontend`, enter each root, read its `AGENTS.md`, run its own
  verify.

## Knowledge base

- Lives in the put.io Notion workspace, Frontend hub; read it through the
  Notion MCP.
- Holds Products, Specs, Design, Engineering (Delivery model, Release
  security, Secrets management, Third-party services inventory),
  Architecture decisions, and Guides.
- Read it before product, spec, release, or secrets decisions.

## Shared defaults

- Parse external input at the boundary and derive types from the validated
  contract.
- Model bug-sensitive flows with explicit states and exhaustive transitions.
- Keep expected errors typed and actionable; bound unexpected failures without
  blanking unrelated UI.
- Keep effects at adapters and leaves so render trees remain pure.
- Avoid type escape hatches that weaken the contract.
- Accept usernames, passwords, and current one-time-password codes only on an
  official put.io website. Keep the long-lived TOTP seed inside the authorized
  secret provider that generates the current code. CLI, mobile, TV, extension,
  harness, and other clients must delegate account authorization to the website
  through OAuth or device-link flows and handle only the resulting codes or
  tokens.
- Let repo-local guidance and established code override shared defaults.
- Keep verification logic in repo-owned commands that CI calls. Preserve an
  established task graph; use one `verify` entrypoint when creating a new lane.
- Deliver from trusted `main` or validated release refs only after verification.
- Finish in-scope edits, checks, and fixes without pausing for approval; ask
  before anything destructive, paid, public, or outside the task, such as
  deploys, publishes, secret or provider changes, external writes, and
  force-pushes.
- Exercise user-visible behavior in the real browser, app, simulator, emulator,
  or device surface when one exists.
- Before a proof command launches a runtime, install cleanup and record whether
  it started that exact target. On every exit, stop only targets it started and
  confirm their absence; preserve pre-existing targets.

## Workflow

1. Inspect the current implementation, docs, scripts, workflows, and proof
   surface before proposing a shape.
2. Apply the smallest relevant shared defaults and preserve working repo
   conventions unless evidence shows they are wrong.
3. Record non-obvious code conventions in the nearest `AGENTS.md`; keep user,
   contributor, distribution, and security documentation in their canonical
   homes.
4. Keep workflow orchestration thin and put repeatable build, verify, deploy,
   and smoke logic behind repo-owned commands.
5. Select the owner's documented checks for the affected behavior and its
   dependents. Run the full canonical gate when owner policy requires it,
   shared inputs changed, or focused coverage is uncertain. Preserve separate
   installed-package, downstream-consumer, browser, and device proof where
   those boundaries matter. Command discovery does not authorize live actions.
   Fix failures and refresh affected proof. Reuse passing proof while its
   source, inputs, and environment remain valid; a new turn or handoff alone
   does not require another run. Name unavailable proof and its exact blocker.
6. Report changed behavior, verification, proof artifacts, risks, and remaining
   gaps.

## Boundaries

- SDK repositories belong to the dedicated SDK development workflow, including
  their docs, verification, release, and delivery shape.
- Operating the `putio` CLI as a files, downloads, transfers, auth, or storage
  consumer belongs to the CLI's consumer guidance. Frontend harnesses use the
  installed CLI through the
  [CLI harness contract](./references/test-harness/cli.md).
- Repository policy, generic GitHub Actions hardening, build-tool migrations,
  bootability repair, and independent code review are outside this skill; it
  supplies put.io frontend domain guidance to whichever workflow does that work.
- Keep machine-specific facts, credentials, account details, and private
  support context out of this public skill; the repository registry carries
  names, remotes, canonical paths, owners, visibility, topics, and mode only.
