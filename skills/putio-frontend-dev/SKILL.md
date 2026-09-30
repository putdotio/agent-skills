---
name: putio-frontend-dev
description: "Develop or review put.io end-user apps and shared frontend packages: UI, state, tests, docs, test harnesses, delivery, and frontend machine setup. Use in a put.io frontend repository or for put.io frontend conventions. Not for unrelated frontend work, browser-only put.io inspection, SDK or API client work, or putio CLI consumer operations; frontend test-harness auth setup stays in scope."
---

# put.io frontend development

Apply shared put.io frontend engineering defaults after the target repository's
own guidance and code precedent.

## Start

1. Inventory nested guidance with `git ls-files '*AGENTS.md' '*SKILL.md'` and
   read the `README.md` and docs for the area being changed. Target-repo
   guidance, project-local skills, and code precedent override this skill.
2. Identify the repo kind, stack, verify entrypoint, delivery target, and
   runtime proof surface.
3. Select only the references required for the task.

## Reference map

- Feature code, parsing, state, errors, forms, styling, and testing:
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
  frontend work stays in the `frontend-*` workflows; in
  `putdotio/agent-skills`, in the `putio-*` skills.
- Peers sit under one folder, default `~/projects/putdotio/`. Missing path:
  `gh repo clone <repo> <path>`, or the clone loop in
  [environment setup](./references/environment-setup.md).
- Check `visibility` before quoting anything across repos; private content
  stays out of public ones.
- For tasks that span all frontend repos: iterate the entries whose `owns`
  includes `frontend`, skipping the `sdks` group unless the task covers SDKs;
  enter each root, read its `AGENTS.md`, run its own verify.

## Knowledge base

- Lives in the put.io Notion workspace,
  [Frontend hub](https://app.notion.com/p/dd26f70efbfb4eb0ba4dce43e3e12d01);
  read it through the Notion MCP.
- Holds Products, Specs, Design, Services, Delivery
  ([Delivery model](https://app.notion.com/p/3ded546ba2f58103ae8ce55b0f7a7f9d),
  [Release security](https://app.notion.com/p/3ded546ba2f581a39ec9e28f38e6d3fc),
  [Secrets management](https://app.notion.com/p/3ded546ba2f581e19b74c6d119adb228)),
  Decisions, Analytics, and Guides.
- Read it before product, spec, release, or secrets decisions.
- Edit only Frontend pages. Leave other teams' pages, including ops guides in
  shared databases, untouched unless the task asks for them.

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
- Keep build, verify, deploy, and smoke logic in repo-owned commands that CI
  calls, with thin workflow YAML. Preserve an established task graph; use one
  `verify` entrypoint when creating a new lane.
- Deliver from trusted `main` or validated release refs only after verification.
- Ask before deploys, publishes, secret or provider changes, external writes,
  and force-pushes.
- Record non-obvious code conventions in the nearest `AGENTS.md`; keep user,
  contributor, distribution, and security documentation in their canonical
  homes.

## Proof

- Select the owner's documented checks for the affected behavior and its
  dependents. Run the full canonical gate when owner policy requires it,
  shared inputs changed, or focused coverage is uncertain. Keep separate
  installed-package, downstream-consumer, browser, and device proof where those
  boundaries matter.
- Exercise user-visible behavior in the real browser, app, simulator, emulator,
  or device surface when one exists.
- Before calling UI work done, exercise first load, loading, error, and empty
  states, small screens, and interaction state such as selection, focus,
  hydration, and races. Inspect the result yourself instead of asking the user
  what looks wrong.
- Reuse passing proof while its source, inputs, and environment remain valid; a
  new turn or handoff alone does not require another run. Name unavailable
  proof and its exact blocker. Command discovery does not authorize live
  actions.
- Before a proof command launches a runtime, install cleanup and record whether
  it started that exact target. On every exit, stop only targets it started and
  confirm their absence; preserve pre-existing targets.

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
