---
name: putio-frontend-test-harness
description: Design typed, agent-friendly test harnesses, testing flows, end-to-end tests, test automation, test coverage, and QA proof loops for put.io frontend-owned web, browser extension, TV, native, emulator, simulator, and device surfaces. Use when shaping auth/session setup, deep links, product flows, platform input, runtime assertions, screenshots, logs, or proof artifacts. Skip repo delivery and release shape.
---

# put.io Frontend Test Harness

Use this skill when designing or reviewing a test harness for a put.io frontend-owned surface. The harness should wrap platform tools, expose a typed command surface, prepare auth/session state, drive real product flows, assert meaningful state, and leave proof artifacts.

## Workflow

1. Read [harness pattern](./references/harness-pattern.md) before shaping architecture, [platform notes](./references/platform-notes.md) before picking tools, and [examples](./references/examples.md) when you need concrete precedent.
2. Inspect the target surface, wrapped platform tools, existing repo commands, local docs, and auth/session entrypoints before designing anything new.
3. Design the harness layers explicitly: adapter, CLI/API, auth/session, flow driver, assertions, proof artifacts, repo integration, observability, isolation, and boundaries.
4. Keep the generic harness core focused on the test surface. Put product journeys, fixture names, content IDs, credentials, and expectations in the owning app repo or scenario files.
5. For put.io auth, use the testing/development account `devs-fe-auto` / `devs+fe+auto@put.io` through global `putio` profiles, not a human account. Use the `putio-cli` skill first and inspect `putio describe --output json` before assuming commands, flags, output shape, or auth behavior.
6. Make auth/session autonomous: one bounded 1Password render/injection step, then typed `putio` profile checks, device approval, authorization, seeding, and reset commands. Browser `put.io/link` completion, repeated human 1Password approvals, human browser sessions, and personal accounts are explicit fallback paths.
7. Prefer deterministic commands and typed outputs over prose-only manual steps. Use narrow commands that are bootable, smokeable, interactable, observable, and isolated enough for agents to debug without repeated human help.
8. Before implementation, check every harness layer from step 3 is covered. If a layer is missing, revise the design before writing code.
9. After implementation, run the smoke or live-test entrypoint, inspect proof artifacts and logs, fix the root cause of failures, and rerun. If the platform cannot expose state directly, require stronger screenshots, logs, recordings, or review artifacts.

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
- For `putio` auth, use `putio auth status --profile <profile-name> --output json`, `putio auth profiles list --output json`, `PUTIO_CLI_PROFILE`, and `PUTIO_CLI_CONFIG_PATH` as the stable automation boundary. Keep CLI config paths ignored and isolated when a run needs disposable auth state.
- Prefer a repo-owned `secrets-setup`, `op run --env-file=<template> -- <harness command>`, or equivalent typed wrapper for the one-shot 1Password step. Do not spin on `op` approval prompts or persist raw rendered secrets in checked-in files.
- For device-code or link flows, automate approval with the testing account through `putio`/approved API helpers when available. Browser-based `put.io/link` completion is a fallback only after the autonomous CLI path is missing or broken, and that limitation must be reported explicitly.
- Repo `.env.local` or `.env` files may name a profile or config path, but must not contain raw put.io tokens in checked-in examples.
- Do not bake product business logic into generic platform commands.
- Wait for meaningful runtime conditions instead of arbitrary sleeps.
