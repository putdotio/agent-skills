---
name: putio-frontend-dev
description: "Develop or review end-user applications and shared frontend packages owned by put.io, including UI, state, tests, docs, test harnesses, and delivery. Use only for work in a put.io frontend repository or explicit requests for put.io frontend conventions. Do not use for unrelated frontend work, browser-only put.io inspection, SDK or API client work, or standalone putio CLI consumer operations; frontend test-harness auth setup remains in scope."
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
3. When tracked, read `README.md`, relevant docs, and `.patterns/` entries
   before editing. Target-repo guidance and skills override this shared skill.
4. Identify the repo kind, stack, verify entrypoint, delivery target, and
   runtime proof surface.
5. Select only the references required for the task.

## Reference map

- Feature code, parsing, state, errors, components, and testing:
  [frontend defaults](./references/frontend-defaults.md)
- Capturing a non-obvious repo convention:
  [pattern template](./references/pattern-template.md)
- README, CONTRIBUTING, SECURITY, and agent-facing docs:
  [top-level docs](./references/docs.md)
- CI, verify, publishing, deployment, and release shape:
  [delivery model](./references/delivery-model.md)
- Application-specific delivery:
  [application defaults](./references/applications.md)
- TypeScript package and app setup:
  [TypeScript defaults](./references/typescript.md)
- Local development secrets and CI credential boundaries:
  [environment setup](./references/secrets.md)
- Secret-bearing release, signing, publishing, and deployment:
  [release security](./references/release-security.md)
- Browser, native, TV, emulator, simulator, and device proof:
  [test harness](./references/test-harness.md)
- Shared test-account browser authorization:
  [test harness pattern](./references/test-harness-pattern.md)
- CLI-backed harness discovery, auth, reads, and writes:
  [CLI harness contract](./references/test-harness-cli.md)

Markdown links navigate this skill bundle. Other paths shown in the references,
such as `.patterns/state-machines.md` or `.github/pull_request_template.md`,
name files to create or inspect in the target repository.

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
- Let repo-local `.patterns/` and established code override shared defaults.
- Expose one repo-local `verify` entrypoint and make CI call it directly.
- Deliver from trusted `main` or validated release refs only after verification.
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
3. Record non-obvious code conventions in `.patterns/<topic>.md`; keep user,
   contributor, distribution, and security documentation in their canonical
   homes.
4. Keep workflow orchestration thin and put repeatable build, verify, deploy,
   and smoke logic behind repo-owned commands.
5. Run the repo's canonical verify entrypoint, for example exactly one of:

   ```bash
   make verify
   mise run verify
   vp run verify
   ```

   If it fails, fix the root cause and rerun the same command until it passes.
   Then run the relevant runtime, delivery, or harness smoke path; fix and
   rerun that proof if it fails.
6. Report changed behavior, verification, proof artifacts, risks, and remaining
   gaps.

## Boundaries

- SDK repositories belong to the dedicated SDK development workflow, including
  their docs, verification, release, and delivery shape.
- Operating the `putio` CLI as a files, downloads, transfers, auth, or storage
  consumer belongs to the CLI's consumer guidance. Frontend harnesses use the
  installed CLI through the
  [CLI harness contract](./references/test-harness-cli.md).
- Repository policy, generic GitHub Actions hardening, Vite+ migrations, and
  bootability repair remain separate workflows. Independent review uses its own
  review workflow while this skill supplies the put.io frontend domain guidance.
- Keep private workspace inventory, machine-specific facts, credentials, and
  private support context out of this public skill.
