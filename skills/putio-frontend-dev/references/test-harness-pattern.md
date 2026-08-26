# Frontend test harness pattern

A frontend test harness wraps a put.io frontend surface in typed commands. It
owns platform setup, auth handoff, navigation, and proof artifacts.

Add only the layers needed to boot, drive, observe, and verify the surface.

## 1. Platform adapter

Wrap vendor or community tools instead of replacing them.

Examples:

- Playwright, browser extension tooling, and browser automation APIs
- Tizen CLI and `sdb`
- `roku-deploy` and Roku External Control Protocol
- Android `adb`
- Apple platform tooling for iOS/tvOS builds, install, launch, logs, and screenshots
- Emulator, simulator, or cloud-device provider CLIs

The adapter owns device communication and platform mechanics:

- boot or select the app surface when that is part of the test loop
- discover or select a target device
- install, package, launch, stop, and uninstall
- stream or collect logs
- take screenshots or screen recordings
- send key, button, text, or remote events
- normalize platform errors into typed, contextful failures

Keep the adapter thin. Make the platform predictable without hiding its
constraints.

## 2. Harness CLI/API

Expose a small command surface that works for humans and agents.

Good commands are:

- typed and documented
- deterministic by default
- composable in Make/npm/pnpm scripts
- careful with config and env
- explicit about hardware-backed versus static behavior
- quiet on success and contextful on failure

Prefer structured output for agent-facing commands:

```txt
status=ok
device=<placeholder-device-name>
app=<placeholder-app-id>
artifact=artifacts/live/screenshot.png
```

Use JSON only when downstream tools need it. Human commands may print a short
summary. Proof commands should leave files behind.

Do not put product logic in generic platform commands. Keep platform verbs such
as `install`, `launch`, `keypress`, `screenshot`, `logs`, and `state` separate
from scenario verbs such as `play-video`, `open-transfer`, and `open-settings`.

## 3. Auth and session setup

Use a repository-configured test account and profile. Never reuse a developer's
browser cookies, personal account, or ambient CLI authentication.

The credential boundary is strict:

- Only an official put.io web app may accept a username, password, or
  one-time-password secret.
- CLI, mobile, TV, extension, harness, and other client code must use the web
  app's OAuth or device-link flow. Those clients handle codes and tokens only.
- Authorized browser automation may enter credentials only into the official
  web login page. Keep the values process-scoped and out of logs, artifacts,
  command arguments, and checked-in files.
- Do not add direct credential exchange, local one-time-password generation,
  or credential refresh to a client or harness.

When a harness uses the `putio` CLI:

1. Find the globally installed `putio` binary on `PATH`.
2. Read its live contract with `putio describe --output json`.
3. Check the repository-configured profile before touching the target surface.
4. If the profile is missing or expired, run browser/device login for that
   profile and complete authorization in the configured web app.
5. Use the authenticated profile to approve device codes or seed reversible
   test state.

The separate `putio-cli` skill is useful when installed, but the harness must
remain usable without it. Keep required CLI capabilities and setup errors in the
owning repository. Do not copy volatile CLI commands into this shared skill.

Keep profile state global so it survives app reinstalls, simulator wipes, and
sideload cycles. Use a repo-local config path only when a test needs isolated
state. Keep profile names neutral in public examples, such as `<test-profile>`.

For TV, native, extension, and other device-link surfaces, capture the code and
approve it with the configured test profile. If the surface has no supported
approval path, report the exact harness gap and keep the manual web fallback
explicit.

## 4. Flow driver

The flow driver operates the app through the platform.

Core capabilities:

- launch the app
- open deeplinks or launch parameters
- seed or reset session state through approved development hooks
- send remote, button, key, touch, pointer, text, or media events
- query UI/runtime state when the platform supports it
- collect logs and screenshots around important transitions
- wait for meaningful conditions

Prefer waits tied to observable state:

- app is foregrounded
- screen or route is active
- player state is `playing`
- focus moved to an expected element
- screenshot changed after navigation
- expected log event appeared

Avoid arbitrary sleeps. Use them only as platform backoff behind a named helper
that explains the constraint.

## 5. Assertion layer

Assertions should describe user-visible or runtime-meaningful behavior.

Useful assertions:

- active app or package
- active screen, route, or scene
- focused element
- visible or hidden UI
- playback state, media-key behavior, and navigation behavior
- runtime state exposed by debug endpoints, platform APIs, accessibility trees, or app test hooks
- layout or geometry only when the values are stable and meaningful

Keep assertion failures compact but useful:

- what was expected
- what was observed
- which command gathered the observation
- where the artifact is stored

Do not couple assertions to unstable text, coordinates, animation timing,
network timing, or device chrome unless that is the behavior under test.

## 6. Proof artifacts

The harness should leave reviewable evidence.

Common artifacts:

- screenshots
- screen recordings
- logs
- runtime state dumps
- review HTML
- command transcripts
- compact verification summaries

Use the repo's ignored working directory for generated artifacts, such as
`.harness/`, `.taizn/`, `.roku-live/`, or `artifacts/live/`.

Name artifacts by scenario, device, and timestamp only when that helps review.
Keep paths deterministic when smoke checks compare or upload known filenames.

## 7. Repo integration

Make the harness easy to run from the repo that owns it.

Expected repo shape:

- Make/npm/pnpm targets for common flows
- deterministic `verify`, `smoke`, or `live-test` entrypoints
- sanitized `.env.example`
- one-shot SOPS materialization or process injection for auth-bearing live checks
- ignored local working directory
- docs that distinguish hardware-backed checks from static checks
- CI or manual workflow notes that explain which checks require a real device

Prefer one command that a future agent can run after setup:

```bash
make live-smoke
```

or:

```bash
pnpm harness:smoke
```

When a command requires real hardware, fail early with the missing
configuration. Do not silently skip proof.

## 8. Observability and isolation

Use these mechanical proof expectations:

- Boot: a single command starts or selects the surface
- Smoke: a fast check proves the surface is alive
- Interact: the agent can drive real input, navigation, and state changes
- E2e: key product flows can be exercised with stable fixtures
- Enforce: repo-local checks or CI catch broken harness contracts where practical
- Observe: logs, state dumps, screenshots, traces, or health probes explain failures
- Isolate: worktrees, config paths, simulators, devices, or profiles do not collide across runs

Each layer should work on its own. Stop when the target flow is verifiable. A
small smoke check and useful artifacts often answer the risk.

## 9. Boundary rules

Keep local and secret values out of checked-in files:

- device IPs and serials
- passwords and developer-mode secrets
- certs, profiles, signing keys, keystores, and provisioning data
- tokens and account identifiers
- personal local paths
- private content IDs or account-specific media references

Checked-in examples use placeholders.

Generic harness code owns platform primitives, auth setup, and proof mechanics.
Product flows belong in the app repo or its scenario files.
