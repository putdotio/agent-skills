# Frontend Test Harness Pattern

A frontend test harness is a small, typed, agent-friendly wrapper around a put.io frontend-owned surface. Its job is to turn platform ceremony, auth setup, product navigation, and proof collection into repeatable commands and reviewable artifacts.

Use these layers when designing a harness. A useful harness provides mechanical proof: it makes the surface bootable, smokeable, interactable, observable, and isolated enough that agents can debug without repeated human help.

## 1. Platform Adapter

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

Keep the adapter thin. It should make the platform predictable without hiding important platform constraints.

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

Use JSON only when downstream tools need it. Human commands may print concise summaries, but proof commands should leave files behind.

Do not put product business logic in generic platform commands. Keep platform verbs like `install`, `launch`, `keypress`, `screenshot`, `logs`, and `state` separate from scenario verbs like `play-video`, `open-transfer`, or `open-settings`.

## 3. Auth And Session Setup

The harness should make authenticated development loops repeatable without using the human's browser session or personal put.io account.

Always use a testing/development account for harness auth. The default frontend
development account is `devs-fe-auto` / `devs+fe+auto@put.io`. Use that account
through an approved `putio` auth profile, token injection, or device-code helper;
do not use a human account for automated harness work.

For put.io account access, standardize on the globally installed `putio` binary
as the development auth broker. It may come from Homebrew, the standalone
installer, npm global install, or another approved global install path. Repo
harnesses should find `putio` on `PATH`, check for the required named profile
before touching a surface, and fail with a concise setup message when it is
missing. Do not add repo-local CLI installs just to make auth work unless the
repo already owns that toolchain contract and explicitly chooses to pin the CLI
as part of it.

Before designing or running `putio`-backed harness commands, load the `putio-cli`
skill and inspect the current contract with `putio describe --output json`.
Treat that skill as the source of truth for CLI discovery, structured output,
auth profiles, paging, dry-runs, and write safety.

Design for one bounded secret-materialization step followed by autonomous CLI
flows. A good harness can render approved Infisical-backed values once
at startup, then run the rest of auth, device approval, authorization, and
seeding through the testing account and `putio` profile state. Use the repo's
standard secret path, such as a `secrets-setup` target, `infisical run`, or a
typed wrapper around those mechanics. Do not make agents approve secret prompts
repeatedly inside a scenario.

Keep auth state durable across native app reinstalls, simulator wipes, and
sideload cycles by defaulting to global `putio` profile state. Use repo-local
config paths only for tests that intentionally need isolated auth state.

Good auth commands are explicit and non-leaky:

```txt
harness auth-render-vars --profile <profile-name> --env-file <ignored-env-file>
harness auth-status --profile <profile-name>
harness auth-prepare --profile <profile-name>
harness auth-approve-device --profile <profile-name> --code <device-code>
harness auth-reset --surface <target-name>
```

Browser-driven human login is a last resort for routine harness work. Never try
to reuse an existing Chrome profile, browser cookies, or logged-in user browser
session unless the user explicitly asks for that flow. Prefer `putio` profile
checks, token injection into child harness commands, or device-code approval
helpers. If the approved profile is missing, stop with the exact setup need
instead of opening a browser or signing into a personal account.

Use these `putio` boundaries when the CLI is available:

- `putio auth status --profile <profile-name> --output json` proves readiness
  without exposing token material
- `putio auth profiles list --output json` lets the harness explain profile
  state without reading secret values
- `PUTIO_CLI_PROFILE=<profile-name>` selects the testing profile for child
  commands
- `PUTIO_CLI_CONFIG_PATH=<ignored-path>` isolates disposable harness auth state
  when global profile state is not appropriate
- `PUTIO_CLI_TOKEN` may be injected for headless setup, but it overrides
  persisted profile selection and must not leak into checked-in examples or
  proof artifacts

For TV, native, browser-extension, and other device-code/link surfaces, prefer a
typed command that completes the approval with the testing account through
`putio` or approved put.io API helpers. The target behavior is: the app displays
or emits a code, the harness captures it, the CLI/API approves it with the
`devs-fe-auto` profile, and the app reaches an authenticated state without the
human opening `put.io/link`. If no autonomous approval path exists for the
surface yet, call that out as a harness-readiness gap and keep the manual
fallback explicit.

## 4. Flow Driver

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

Avoid arbitrary sleeps except as a platform backoff with a comment or named helper that explains the platform constraint.

## 5. Assertion Layer

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

Do not overfit assertions to unstable text, coordinates, animation timing, network timing, or device-specific chrome unless that is the behavior under test.

## 6. Proof Artifacts

The harness should leave reviewable evidence.

Common artifacts:

- screenshots
- screen recordings
- logs
- runtime state dumps
- review HTML
- command transcripts
- compact verification summaries

Use a local ignored working directory for generated artifacts, such as `.harness/`, `.taizn/`, `.roku-live/`, or `artifacts/live/`, depending on the repo's convention.

Name artifacts by scenario, device, and timestamp only when that helps review. Keep paths deterministic for smoke checks that compare or upload known filenames.

## 7. Repo Integration

Make the harness easy to run from the repo that owns it.

Expected repo shape:

- Make/npm/pnpm targets for common flows
- deterministic `verify`, `smoke`, or `live-test` entrypoints
- sanitized `.env.example`
- one-shot secret materialization or `infisical run` wrappers for auth-bearing live
  checks
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

When a command requires real hardware, fail early with a clear missing-config message rather than silently skipping proof.

## 8. Observability And Isolation

Use these mechanical proof expectations:

- Boot: a single command starts or selects the surface
- Smoke: a fast check proves the surface is alive
- Interact: the agent can drive real input, navigation, and state changes
- E2e: key product flows can be exercised with stable fixtures
- Enforce: repo-local checks or CI catch broken harness contracts where practical
- Observe: logs, state dumps, screenshots, traces, or health probes explain failures
- Isolate: worktrees, config paths, simulators, devices, or profiles do not collide across runs

Each added layer should be independently useful. Stop when the harness makes the target flow honestly verifiable; do not build a full lab when a small smoke plus good artifacts answers the risk.

## 9. Boundary Rules

Keep local and secret values out of checked-in files:

- device IPs and serials
- passwords and developer-mode secrets
- certs, profiles, signing keys, keystores, and provisioning data
- tokens and account identifiers
- personal local paths
- private content IDs or account-specific media references

Checked-in examples use placeholders.

Generic harness code should know about platform primitives, auth/session setup, and proof mechanics. Product-specific flows live in the app repo or scenario files, where product behavior belongs.
