---
name: putio-frontend-test-harness
description: Design typed, agent-friendly test harnesses, testing flows, end-to-end tests, test automation, test coverage, and QA proof loops for put.io frontend-owned web, browser extension, TV, native, emulator, simulator, and device surfaces. Use when shaping auth/session setup, deep links, product flows, platform input, runtime assertions, screenshots, logs, or proof artifacts. Skip repo delivery and release shape.
---

# put.io Frontend Test Harness

Use this skill when designing or reviewing a test harness for a put.io frontend-owned surface. The harness should wrap platform tools, expose a typed command surface, prepare auth/session state, drive real product flows, assert meaningful state, and leave proof artifacts.

## Workflow

1. Read [harness pattern](./references/harness-pattern.md) before shaping the harness architecture.
2. Read [examples](./references/examples.md) when you need concrete patterns from `taizn`, `putio-roku`, or other frontend-owned surfaces.
3. Read [platform notes](./references/platform-notes.md) for surface-specific constraints before picking tools or proof surfaces.
4. Keep the generic harness core focused on the test surface. Put product journeys, fixture names, content IDs, credentials, and expectations in the owning app repo or scenario files.
5. For put.io account auth, always use a testing/development account. The default frontend development account is `devs-fe-auto` / `devs+fe+auto@put.io`. Prefer the globally installed `putio` binary on `PATH`, from Homebrew, the standalone installer, npm global install, or another approved global install path. Harnesses may require global `putio` and a named auth profile, but should not add repo-local CLI installs unless the repo already owns that toolchain contract.
6. When using `putio`, use the `putio-cli` skill first and inspect the live CLI contract with `putio describe --output json` before assuming commands, flags, output shape, or auth behavior.
7. Design auth/session setup to be autonomous; use the guardrails below and [harness pattern](./references/harness-pattern.md) for the 1Password, profile, device approval, seeding, and reset details.
8. Treat browser `put.io/link` completion, repeated human 1Password approval, the human's browser session, and personal put.io accounts as explicit fallback paths, not routine harness behavior.
9. Prefer deterministic commands and typed outputs over prose-only manual steps.
10. Use a mechanical proof stack: make the surface bootable, smokeable, interactable, observable, and isolated enough for agents to debug against real surface proof without repeated human help.
11. Before implementation, check the design covers the layers from [harness pattern](./references/harness-pattern.md): adapter, CLI/API, auth/session, flow driver, assertions, proof artifacts, repo integration, observability, isolation, and boundaries.
12. If any layer is missing, revise the design before writing code; if platform state cannot be queried, require stronger screenshot, log, or transcript proof.

Mini-example command surface:

```txt
harness package --profile <profile-name>
harness install --device <device-alias>
harness launch --app <app-id>
harness open-flow --name playback --fixture <fixture-name>
harness press --key play-pause
harness auth-status --profile <profile-name>
harness auth-prepare --profile <profile-name>
harness auth-render-vars --profile <profile-name> --env-file <ignored-env-file>
harness auth-approve-device --profile <profile-name> --code <device-code>
harness seed-account --profile <profile-name> --scenario <scenario-name>
harness assert-screen --name player --artifact artifacts/live/player.png
```

The exact command names should follow the target repo, but the shape should stay narrow, typed, and proof-producing.

Minimal TypeScript shape:

```ts
type HarnessArtifact = {
  kind: "screenshot" | "log" | "state" | "review-html";
  path: string;
};

type HarnessResult = {
  status: "ok" | "failed";
  device: string;
  artifacts: HarnessArtifact[];
  message?: string;
};

interface PlatformAdapter {
  package(profile: string): Promise<HarnessResult>;
  install(device: string): Promise<HarnessResult>;
  launch(appId: string): Promise<HarnessResult>;
  press(key: string): Promise<HarnessResult>;
  screenshot(path: string): Promise<HarnessResult>;
}
```

## Output Shape

For a harness design or implementation plan, report:

- Platform adapter and wrapped tools
- CLI/API command surface
- Auth/session setup, 1Password materialization, profile selection, and reset path
- Flow driver capabilities
- Assertion model
- Proof artifacts
- Repo integration and verify/smoke entrypoints
- Observability and isolation choices
- Secrets, local state, and app-logic boundaries

## Guardrails

- Keep device IPs, passwords, certs, signing keys, tokens, content IDs, fixture internals, and personal local facts out of git.
- Checked-in examples use placeholders.
- Use global `putio` auth profiles for routine put.io authorization and development session setup. Do not drive the human's browser login, existing Chrome profile, existing browser cookies, or personal account session unless the user explicitly asks for that flow.
- Default to the frontend testing/development account `devs-fe-auto` / `devs+fe+auto@put.io`; do not use a human account for automated harness work.
- When a harness depends on `putio`, follow the `putio-cli` skill as the source of truth for CLI discovery, structured output, auth profiles, paging, dry-runs, and write safety.
- Prefer one explicit 1Password render/injection step such as a repo-owned `secrets-setup`, `op run --env-file=<template> -- <harness command>`, or equivalent typed wrapper. Do not call `op` repeatedly inside a flow, spin on approval prompts, or persist raw rendered secrets in checked-in files.
- Use `putio auth status --profile <profile-name> --output json`, `putio auth profiles list --output json`, `PUTIO_CLI_PROFILE`, and `PUTIO_CLI_CONFIG_PATH` as the stable automation boundary. Keep CLI config paths ignored and isolated when a run needs disposable auth state.
- For device-code or link flows, automate approval with the testing account through `putio`/approved API helpers when available. Browser-based `put.io/link` completion is a fallback only after the autonomous CLI path is missing or broken, and that limitation must be reported explicitly.
- Repo `.env.local` or `.env` files may name a profile or config path, but must not contain raw put.io tokens in checked-in examples.
- Do not bake product business logic into generic platform commands.
- Wait for meaningful runtime conditions instead of arbitrary sleeps.
- If the platform cannot expose state directly, make the limitation explicit and compensate with screenshots, logs, or review artifacts.
