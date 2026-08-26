# Examples

These examples are training references for the harness pattern. They are not the product this skill creates.

## `taizn`

`taizn` demonstrates the packaging, install, and signing side of a frontend surface harness.

Pattern signals:

- tiny TypeScript CLI companion for Tizen work
- wraps Tizen CLI and `sdb`
- exposes focused commands such as `profile`, `package`, and `install`
- uses a repo config file for stable inputs
- uses an ignored working directory for local output and generated state
- reads sensitive values from env or local config instead of git
- turns multi-step Tizen ceremony into repeatable commands

Use this pattern when a platform needs reliable build/package/install setup before flow testing can start.

Good boundaries:

- keep signing material, cert passwords, device identities, and local SDK paths out of checked-in examples
- keep app-specific navigation and playback checks out of the generic Tizen wrapper
- make packaging and install failures typed enough that an agent can fix the root cause

## `putio-roku`

`putio-roku` demonstrates a hardware-backed product-flow proof loop.

Pattern signals:

- Make targets wrap common live-device workflows
- TypeScript scripts drive live Roku checks
- Roku ECP handles launch, deeplinks, keypresses, and screenshots
- SceneGraph/runtime queries support assertions when available
- screenshots, logs, review HTML, and compact summaries make behavior reviewable
- live checks cover auth state, deeplink navigation, playback, focus, media-key behavior, and visual artifacts

Use this pattern when platform behavior can only be trusted after running on a real device or emulator.

Good boundaries:

- keep Roku IPs, developer passwords, channel IDs, account data, and content IDs out of git
- keep generic remote-control and screenshot primitives separate from app journeys
- keep scenario expectations in named scripts or scenario files so the platform driver remains reusable

## Frontend-owned Web And Native Apps

Use the same shape for web, browser extension, iOS, Android, and tvOS surfaces.
The wrapped tools change, but the harness contract stays stable.

Pattern signals:

- one command boots or selects the target surface
- one command checks auth/profile readiness through global `putio`
- one bounded setup step renders SOPS-backed testing-account variables, then
  the rest of the flow uses `putio` profiles and ignored local config paths
- scenario commands open common product flows through deeplinks, routes, launch arguments, or debug hooks
- device-code and link approval flows are completed by typed CLI/API helpers
  with the testing account instead of by opening the human's browser
- assertions read UI state, accessibility state, app logs, network-visible state, or screenshots
- artifacts explain failures without relying on a human watching the run

Good boundaries:

- keep fixture IDs and account-specific state behind local config, scenario files, or approved dev-account helpers
- keep platform control separate from product scenarios
- make missing simulator, emulator, browser, device, or auth profile errors fail early with exact setup needs

## What To Copy

Copy the shape, not the exact implementation:

- a small typed CLI or script API
- repo-local commands for common flows
- clean local config and env boundaries
- platform communication wrapped behind narrow functions
- auth/session setup through global `putio` profile checks
- one-shot SOPS materialization plus autonomous `putio` profile/device-link
  flows for auth-bearing scenarios
- meaningful waits and assertions
- proof artifacts written to predictable paths
- concise failure messages that point to the failing platform step

## What Not To Copy

Do not make a new harness depend on another platform's quirks:

- Tizen signing flow does not belong in a Roku or Android harness
- Roku ECP assumptions do not belong in a Tizen harness
- app-specific playback journeys do not belong in a generic platform adapter
- personal device setup does not belong in checked-in docs
