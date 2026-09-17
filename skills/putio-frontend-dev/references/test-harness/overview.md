# Test harness

Use this reference when `putio-frontend-dev` work touches proof loops for put.io
frontend-owned web, browser extension, TV, native, emulator, simulator, or
device surfaces.

A harness wraps platform tools, exposes a typed command surface, prepares auth/session state, drives real product flows, asserts meaningful state, and leaves proof artifacts.

## Workflow

1. Read [harness pattern](./pattern.md) before shaping architecture, [platform notes](./platform-notes.md) before picking tools, and [examples](./examples.md) when you need precedent.
2. Inspect the target surface, wrapped platform tools, existing repo commands, local docs, and auth/session entrypoints before designing anything new.
3. Design the harness layers explicitly: adapter, CLI/API, auth/session, flow driver, assertions, proof artifacts, repo integration, observability, isolation, and boundaries.
4. Keep the generic harness core focused on the test surface. Put product journeys, fixture names, content IDs, profile names, and expectations in the owning app repo or scenario files. Account credentials stay in the authorized secret provider.
5. For auth/session, follow the credential boundary and profile rules in [harness pattern](./pattern.md#3-auth-and-session-setup).
6. Prefer deterministic commands and typed outputs over prose-only manual steps. Use narrow commands that are bootable, smokeable, interactable, observable, and isolated enough for agents to debug without repeated human help.
7. Before implementation, check every harness layer from step 3 is covered. If a layer is missing, revise the design before writing code.
8. After implementation, run the smoke or live-test entrypoint, inspect proof artifacts and logs, fix the root cause of failures, and rerun. If the platform cannot expose state directly, require stronger screenshots, logs, recordings, or review artifacts.

Mini-example command surface:

```txt
harness package --profile <profile-name>
harness install --device <device-alias>
harness launch --app <app-id>
harness open-flow --name playback --fixture <fixture-name>
harness press --key play-pause
harness auth-status --profile <profile-name>
harness auth-prepare --profile <profile-name>
harness auth-approve-device --profile <profile-name> --code <device-code>
harness seed-account --profile <profile-name> --scenario <scenario-name>
harness assert-screen --name player --artifact artifacts/live/player.png
```

Command names follow the target repo; the shape stays narrow, typed, and proof-producing.

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

## Output shape

For a harness design or implementation plan, report the adapter, command surface, auth/session path, flow driver, assertions, proof artifacts, repo integration, observability, isolation, and remaining boundaries.

## Guardrails

- Secret and local values stay out of git per [boundary rules](./pattern.md#9-boundary-rules); checked-in examples use placeholders.
- Harness secret payloads may contain reversible dev/test fixtures, never account credentials, admin access, signing keys, recovery identities, or deploy and publish secrets. See [harness ergonomics](../delivery/secrets.md#harness-ergonomics).
- Repo `.env.local` or `.env` examples may name a profile or config path, but must not contain raw put.io tokens.
