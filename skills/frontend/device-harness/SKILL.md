---
name: putio-device-harness
description: Design small, typed, agent-friendly harnesses for hard-to-automate device and TV platforms. Use when shaping tools for Tizen, Roku, Android TV, Apple TV/tvOS, emulator wrappers, screenshot collectors, remote-control drivers, runtime assertion tools, or similar proof loops. Skip app-specific feature logic; this skill defines the reusable harness pattern language, not one platform's harness.
---

# put.io Device Harness

Use this skill when designing or reviewing a device/platform harness for put.io work.

A good harness turns platform ceremony into repeatable commands and proof artifacts. It wraps vendor/community tools, exposes a small typed surface, drives runtime behavior, and leaves enough evidence for another agent or reviewer to trust the result.

## Workflow

1. Read [references/harness-pattern.md](references/harness-pattern.md) before shaping the harness architecture.
2. Read [references/examples.md](references/examples.md) when you need concrete patterns from `taizn` or `putio-roku`.
3. Read [references/platform-notes.md](references/platform-notes.md) for platform-specific constraints before picking tools or proof surfaces.
4. Keep the generic harness core platform-focused. Put app-specific journeys, content IDs, credentials, and expectations in the app repo or scenario files.
5. Prefer deterministic commands and typed outputs over prose-only manual steps.
6. Design verification around hardware-backed or emulator-backed proof when static checks cannot prove behavior.
7. Before implementation, check the design covers all seven layers from `harness-pattern.md`: adapter, CLI/API, runtime driver, assertions, proof artifacts, repo integration, and boundaries.

Mini-example command surface:

```txt
harness package --profile <profile-name>
harness install --device <device-alias>
harness launch --app <app-id>
harness press --key play-pause
harness assert-screen --name player --artifact artifacts/live/player.png
```

The exact command names should follow the target repo, but the shape should stay narrow, typed, and proof-producing.

## Output Shape

For a harness design or implementation plan, report:

- Platform adapter and wrapped tools
- CLI/API command surface
- Runtime driver capabilities
- Assertion model
- Proof artifacts
- Repo integration and verify/smoke entrypoints
- Secrets, local state, and app-logic boundaries

## Guardrails

- Keep device IPs, passwords, certs, signing keys, tokens, content IDs, and personal local facts out of git.
- Checked-in examples use placeholders.
- Do not bake app business logic into generic platform commands.
- Wait for meaningful runtime conditions instead of arbitrary sleeps.
- If the platform cannot expose state directly, make the limitation explicit and compensate with screenshots, logs, or review artifacts.
