# Platform Notes

Use these notes as starting points. Verify current platform tooling in the target repo before implementing.

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

## Future Weird Platforms

For webOS, game consoles, set-top boxes, browser-kiosk environments, or vendor clouds, start from the same architecture:

- platform adapter wraps the vendor control surface
- CLI/API exposes narrow typed commands
- runtime driver performs launch, input, state, and artifact collection
- assertions target stable user-visible behavior
- proof artifacts make the run reviewable
- repo integration makes setup and smoke checks repeatable

If the platform cannot expose runtime state, say so plainly and design around stronger visual, log, or transcript evidence.
