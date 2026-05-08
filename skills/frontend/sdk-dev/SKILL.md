---
name: putio-sdk-dev
description: Develop or review put.io SDK repositories, API clients, and client libraries across TypeScript, Swift, Kotlin, and similar packages. Use when adding or changing namespaces, tightening request or error types, aligning SDK behavior with backend and app usage, updating SDK verification flows, or checking how an SDK repo should be documented and released.
---

# put.io SDK Dev

Use this skill when working in a put.io SDK repository rather than an end-user app.

Bundled references: `sdk-vision.md`, `patterns.md`, and `language-notes.md`.

## Quick Rules

- Treat each SDK as a public package, not an internal compatibility layer.
- Treat TypeScript as the canonical full put.io API client, not just the richest reference.
- Keep every public surface domain-first, strongly typed, and native to its host language.
- Update request, response, and typed error contracts together.
- Prove behavior with deterministic tests plus safe live tests when real API behavior matters.
- Keep Swift and Kotlin scope narrower than TypeScript only when product usage justifies it.

## Source Of Truth Order

When docs, runtime behavior, and consumers disagree, trust sources in this order: local backend and tests, current first-party app usage, actively maintained SDKs, archived clients, then published Swagger or public API docs.

Do not widen an SDK surface just because another SDK already has it. Match real app use and verified backend behavior.

## Start Here

Read only what you need:

- the repo-local `AGENTS.md`
- the canonical verify and live-test commands from `README.md`, `AGENTS.md`, or `docs/*`
- [references/sdk-vision.md](references/sdk-vision.md) for scope, parity, and endpoint-family decisions
- [references/patterns.md](references/patterns.md) for typed boundaries, error mapping, pagination, and live-test layering
- [references/language-notes.md](references/language-notes.md) for TypeScript, Swift, or Kotlin-specific guidance

If the repo has a canonical verify command, use that as the source of truth before editing delivery automation.
If SDK release, publish, signing, or binary-build automation is in scope, also use `putio-frontend-repos` and its release-supply-chain guidance.

## Main Workflow

1. Inspect the target namespace and the shared transport or client runtime.
2. Check backend behavior, backend tests, and current app usage before widening or changing a contract.
3. Update typed request input, response parsing, and operation-specific error mapping together.
4. Add or update deterministic coverage for request shaping, parsing, errors, and public client contracts.
5. Add or refresh safe live verification when production behavior matters and the surface is reversible.
6. Keep multiple public clients aligned when the repo exposes more than one interface style.
7. Run the repo's canonical verify command and fix failures before continuing.
8. Update package-facing docs and release notes when the public surface changes.

## Endpoint Change Recipe

For a new or changed endpoint, make the work traceable:

```bash
rg -n "route_name|endpoint_path|field_name" ../putio-backend test src docs
rg -n "route_name|endpoint_path|field_name" ../putio-web ../putio-ios ../putio-cli
rg -n "route_name|endpoint_path|field_name" src test docs
```

Then update the SDK in this order:

1. request input type or query model
2. response parser or native decode model
3. operation-specific error mapping
4. public client method or namespace export
5. unit tests for request, response, and error behavior
6. safe live test when the endpoint behavior cannot be proven locally
7. README, API docs, or release notes when the public surface changed

## Verification

Run the checks that match the repo instead of inventing ad hoc commands.
Healthy SDK repos in this workspace should expose both:

- a default deterministic unit-test path that is safe for CI and local iteration
- a separate documented live-test path for real API verification

If one of those layers is missing, treat it as a repo gap to document or fix rather than silently accepting a weaker verification story.

Minimal shape:

```bash
rg -n "verify|liveTest|test:live|example" README.md AGENTS.md docs .github
vp run verify && vp run test:live
./gradlew verify && ./gradlew liveTest
```

Common examples in this workspace:

```bash
vp run verify
./gradlew verify
make verify
```

For runtime verification, prefer the repo's documented live-test entrypoints and follow the shared-account safety rules in that repo's testing docs.

## Guardrails

- Do not guess backend contracts from old SDKs alone.
- Do not claim an SDK change is fully verified if only unit tests or only live probes were exercised when both layers matter.
- Do not add live destructive coverage against shared accounts.
- Do not weaken naming, parity, or type-safety without a documented reason.
- Do not change SDK release, publish, signing, or binary-build workflows without applying the shared frontend repo release-supply-chain checklist.
- Do not copy repo-specific implementation guidance into this shared skill when it belongs in that repo's `AGENTS.md` or `docs/*`.
