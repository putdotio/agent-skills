# Platform notes

Use these notes as starting points. Verify current platform tooling in the target repo before implementing.

## Web and browser extensions

Likely tools:

- Playwright or repo-local browser automation
- extension pack/load tooling
- dev server or preview server commands
- browser logs, screenshots, traces, and network captures

Common harness concerns:

- dev server boot readiness
- authenticated session setup without using the human's browser profile
- route, deeplink, and extension entrypoint coverage
- extension permissions, service worker lifecycle, and content-script injection state
- reliable screenshots and traces for visual or startup failures

Good proof:

- surface boots through a single command
- smoke check proves the app or extension is alive
- route or extension entrypoint opens the expected product flow
- screenshot, trace, console log, or runtime state dump is saved with the summary

## iOS / Android native

Likely tools:

- Xcode command-line tooling, `simctl`, XCTest, or UI test runners
- Gradle, Android `adb`, UI Automator, accessibility dumps, logcat, and screencap
- emulator, simulator, hardware, or cloud-device provider CLIs

Common harness concerns:

- simulator or emulator boot readiness
- install, launch, deeplink, intent, and launch-argument support
- app reinstall wiping local session state
- auth/session seeding through approved development hooks
- logs, screenshots, and accessibility state that explain failures

Good proof:

- app installs or launches on the selected target
- auth/session readiness is checked before the product flow starts
- deeplink or launch argument opens the expected route
- UI/accessibility state supports assertions
- screenshot and log excerpt are saved with the summary

## Tizen

Likely tools:

- Tizen CLI
- `sdb`
- certificate/profile tooling

Common harness concerns:

- signing profiles and certificate passwords
- device discovery and developer mode
- packaging paths and app identifiers
- install and launch commands that fail with terse vendor output
- logs through `sdb`
- screenshots when the device/toolchain supports them

Good proof:

- package artifact exists
- install command succeeds on the selected device
- app launches foregrounded
- logs show startup or an expected marker
- screenshot or runtime signal confirms the app is visible

## Roku

Likely tools:

- `roku-deploy`
- Roku External Control Protocol
- SceneGraph or app debug query surfaces when available

Common harness concerns:

- device IP and developer password stay local
- sideload packaging and install state
- launch parameters and deeplinks
- keypress timing
- focus and playback state
- screenshots and review HTML for visual proof

Good proof:

- app launches through ECP
- route or screen assertion passes
- keypress sequence reaches expected focus
- playback responds to media keys
- screenshot and logs are attached to the run summary

## Android TV

Likely tools:

- Android `adb`
- Gradle or repo-local build commands
- emulator manager or cloud-device provider CLI
- UI Automator, accessibility dumps, logcat, and screencap

Common harness concerns:

- emulator boot readiness
- device selection when multiple targets are attached
- package install and activity launch
- deeplinks and intents
- focus navigation with DPAD keys
- logcat noise filtering
- screenshot and screenrecord artifacts

Good proof:

- package installs on a selected target
- activity launches foregrounded
- deeplink opens the expected route
- UI dump or accessibility state supports assertions
- screenshot/logcat excerpt is saved with the summary

## Apple TV / tvOS

Likely tools:

- Xcode command-line tooling
- `simctl` for simulators
- XCTest or UI test runners
- repo-local build scripts for signing and provisioning

Common harness concerns:

- simulator versus hardware support
- provisioning, signing, and team IDs
- app install and launch
- remote/button events through XCTest or simulator tooling
- screenshots and logs
- video/playback assertions that may need app test hooks

Good proof:

- build target succeeds for simulator or hardware
- app installs and launches
- focused route or screen assertion passes
- screenshot is saved
- logs or XCTest output explain failures

Keep signing identities, provisioning profiles, device identifiers, and account facts outside git.

## Future weird platforms

For webOS, game consoles, set-top boxes, browser-kiosk environments, or vendor clouds, start from the same architecture:

- platform adapter wraps the vendor control surface
- CLI/API exposes narrow typed commands
- runtime driver performs launch, input, state, and artifact collection
- assertions target stable user-visible behavior
- proof artifacts make the run reviewable
- repo integration makes setup and smoke checks repeatable

If the platform cannot expose runtime state, say so plainly and design around stronger visual, log, or transcript evidence.
