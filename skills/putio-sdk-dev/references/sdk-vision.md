# SDK vision

## Purpose

Define the shared product and engineering doctrine for put.io SDKs across TypeScript, Swift, and Kotlin.

This document exists so the SDK repos do not drift into three different philosophies. It is not a promise that every SDK exposes every endpoint or every abstraction in the same way. It is the contract for how we want put.io SDKs to feel, evolve, and prove correctness.

## Core position

- `putio-sdk-typescript` is the canonical full put.io API client and should mirror the backend surface one to one
- The Swift and Kotlin SDKs do not need feature-for-feature parity with TypeScript; they stay focused on consumer, streaming, and core account-management flows for now
- Swift and Kotlin still need the same quality bar: native APIs, typed boundaries, typed errors, safe live verification, and public-package discipline
- The SDKs are public products, not thin internal shims; no SDK exposes a weakly typed surface because its scope is smaller
- Differences in scope must be deliberate and documented, not accidental drift

## First-party consumers

Scope decisions should be grounded in real first-party consumers, not symmetry for its own sake.

Use capability categories instead of a private repository inventory:

- broad TypeScript clients that cover product and management surfaces
- typed command-line automation across auth, account, files, events, transfers,
  and downloads
- Swift and Kotlin consumer apps that cover playback and account management

TypeScript remains the full-surface contract because web management and typed
automation both need it. Swift and Kotlin remain narrower, but their baseline
still includes core account and security capabilities.

## Shared principles

### Public-package mindset

- Treat every SDK as something an external developer could adopt without internal tribal knowledge
- Keep install, verify, release, and live-test flows documented and repeatable
- Keep package surfaces open-source-safe

### Native first

- TypeScript should feel like modern Effect-first TypeScript
- Swift should feel like modern Apple-platform Swift, not a port of JavaScript ideas
- Kotlin should feel like coroutine-first Kotlin, not a transliteration of Swift or TypeScript

### Parse at the boundary

- Parse external data once at the transport or domain boundary
- Operate on typed models internally
- Expose typed values through public APIs
- Preserve unknown backend enum or string values when forward compatibility matters

### Typed query and pagination contracts

- Treat query parameters as part of the public type contract, not as loose string bags
- Model pagination explicitly, including cursor-based flows and continue endpoints when the backend exposes them
- Prefer query-shape-aware return types when the language can express them without making the API unnatural
- When a query parameter changes the response shape, reflect that in types, overloads, generics, or other idiomatic host-language tools instead of returning an over-broad bag
- If one SDK cannot represent the same contract precision as another, still keep the shape as explicit and typed as the host language reasonably allows

### Errors are part of the API

- Error contracts are first-class public behavior
- Classify transport, API, auth, decoding, and validation failures explicitly
- Help recovery when the client can recover
- Keep richer diagnostics for operators without leaking secrets or raw internals
- Provide error-handling helpers when they materially improve consumer ergonomics, such as classification helpers, recovery helpers, localized or user-facing summaries, and retry-safety hints
- Native SDKs should expose localized or recovery-oriented error messaging where that improves end-user apps

### Tests prove behavior, not implementation trivia

- Keep deterministic tests for request shaping, parsing, error mapping, and public contract behavior
- Keep safe live tests for real API behavior that unit tests cannot prove
- Treat mock-heavy self-verification as a starting point; add the real contract checks the change needs
- If a repo cannot prove its real behavior safely, document that as a gap

## Language doctrine

Per-language rules live in [language notes](./language-notes.md).

## Scope policy

Scope parity is not the goal for every SDK. Quality parity is.

Use this bias:

- TypeScript should be the fully fledged one-to-one backend client because the web app, CLI, and external users need it
- Swift and Kotlin should prioritize the surfaces first-party native apps actually need
- Expand Swift or Kotlin coverage when backend behavior is verified and first-party usage or clear product intent justifies it
- Add namespaces when backend behavior and real consumer use justify them

When deciding whether a namespace belongs in Swift or Kotlin, check:

1. current first-party app usage
2. backend behavior and backend tests
3. whether the feature belongs in a consumer or playback-oriented native app
4. whether the extra surface would be maintained to the same quality bar

## Capability matrix

Use this as the default scope bias for native SDKs and as a completeness reminder for TypeScript. It is a product-direction tool, not a hard ban on future expansion.

| Capability family | First-party drivers today | TypeScript expectation | Swift/Kotlin expectation |
| --- | --- | --- | --- |
| Auth and OAuth device flows | web, cli, native apps | required | required |
| Account basics, profile, settings, and security flows such as two-factor auth | web, cli, native apps | required | required |
| Files browse and detail | web, cli, native apps | required | required |
| Search | web, cli, native apps | required | required |
| Transfers | web, cli, native apps | required | required |
| Playback-adjacent links, stream selection, subtitles, and media helpers | web, native apps, cli for link workflows | required | required |
| History and events | web, cli, native apps | required | required |
| Trash | web, native apps | required | required |
| Download links and export-style link workflows | web, cli | required | optional until native product need is clear |
| Sharing, friends, friend invites, family | web | required in the full client | optional |
| Payments, supporting, subscriptions | web | required in the full client | optional |
| RSS, zips, tunnel, deeper utility or admin-style flows | web, cli where justified | required in the full client | defer unless first-party native usage appears |
| IFTTT, grants, routes, other legacy or niche surfaces | historical or narrow use | include when the backend still meaningfully exposes them | justify explicitly |

### Reading the matrix

- `required` means a healthy SDK in that lane should actively support the family
- `required in the full client` means the TypeScript SDK should cover it as part of the one-to-one backend client mission
- `optional` means add it when real consumer need appears
- `defer` means wait for first-party usage or an explicit product decision
- `justify explicitly` means add only with clear evidence and a maintenance plan
- `include when the backend still meaningfully exposes them` means the TypeScript SDK should not erase backend capability just because the surface is niche or old

## Verification policy

Healthy put.io SDK repos should provide:

- one canonical deterministic verify path
- one documented live-test path for real API verification

The current workspace direction is:

- TypeScript: repo-native verify and live-test flows such as `vp run verify` and `vp run test:live`
- Swift: `make verify` plus a safe live-test entrypoint
- Kotlin: `./gradlew verify` plus `./gradlew liveTest`

If a repo only has one layer today, document the gap and prefer adding the missing layer over widening claims about verification quality.

Coverage is a guardrail, not the product. Still, SDK repos should carry a meaningful minimum line-coverage floor so public contracts cannot quietly rot.

## Non-goals

- forced feature parity across all SDKs other than the TypeScript full-client mission
- one shared runtime or codegen output used by every language
- generic generated clients that mirror the API without product judgment
- raw JSON compatibility layers as a long-term surface
- adding endpoints with weak typing just to increase apparent coverage
