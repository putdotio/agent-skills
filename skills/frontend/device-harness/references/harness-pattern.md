# Harness Pattern

A device harness is a small, typed, agent-friendly wrapper around a hard-to-automate platform. Its job is to turn platform ceremony into repeatable commands and proof artifacts.

Use these layers when designing a harness.

## 1. Platform Adapter

Wrap vendor or community tools instead of replacing them.

Examples:

- Tizen CLI and `sdb`
- `roku-deploy` and Roku External Control Protocol
- Android `adb`
- Apple platform tooling for tvOS builds, install, launch, logs, and screenshots
- Emulator, simulator, or cloud-device provider CLIs

The adapter owns device communication and platform mechanics:

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

Do not put app-specific business logic in generic platform commands. Keep platform verbs like `install`, `launch`, `keypress`, `screenshot`, `logs`, and `state` separate from scenario verbs like `play-video` or `open-transfer`.

## 3. Runtime Driver

The runtime driver operates the app through the platform.

Core capabilities:

- launch the app
- open deeplinks or launch parameters
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

## 4. Assertion Layer

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

## 5. Proof Artifacts

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

## 6. Repo Integration

Make the harness easy to run from the repo that owns it.

Expected repo shape:

- Make/npm/pnpm targets for common flows
- deterministic `verify`, `smoke`, or `live-test` entrypoints
- sanitized `.env.example`
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

## 7. Boundary Rules

Keep local and secret values out of checked-in files:

- device IPs and serials
- passwords and developer-mode secrets
- certs, profiles, signing keys, keystores, and provisioning data
- tokens and account identifiers
- personal local paths
- private content IDs or account-specific media references

Checked-in examples use placeholders.

Generic harness code should know about platform primitives. App-specific flows live in the app repo or scenario files, where product behavior belongs.
