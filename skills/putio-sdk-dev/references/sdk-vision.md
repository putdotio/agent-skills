# SDK vision

Engineering doctrine for put.io SDKs across TypeScript, Swift, and Kotlin.
Product direction, including why each SDK exists and the capability roadmap,
lives in the Frontend hub in the put.io Notion workspace (page: Products).

## Scope rules

- `putio-sdk-typescript` is the canonical full put.io API client and mirrors the backend surface one to one
- The Swift and Kotlin SDKs stay focused on consumer, streaming, and core account-management flows, including account and security capabilities; they do not need feature-for-feature parity with TypeScript
- Swift and Kotlin still meet the same quality bar: native APIs, typed boundaries, typed errors, safe live verification, and public-package discipline
- No SDK exposes a weakly typed surface because its scope is smaller
- Differences in scope must be deliberate and documented, not accidental drift

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

Scope parity is not the goal for every SDK. Quality parity is. Expand Swift or
Kotlin coverage only when backend behavior is verified and first-party usage
justifies it.

Before adding a namespace to Swift or Kotlin, check:

1. current first-party app usage
2. backend behavior and backend tests
3. whether the feature belongs in a consumer or playback-oriented native app
4. whether the extra surface would be maintained to the same quality bar

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
