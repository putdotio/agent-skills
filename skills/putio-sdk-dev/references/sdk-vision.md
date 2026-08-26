# SDK Vision

## Purpose

Define the shared product and engineering doctrine for put.io SDKs across TypeScript, Swift, and Kotlin.

This document exists so the SDK repos do not drift into three different philosophies. It is not a promise that every SDK exposes every endpoint or every abstraction in the same way. It is the contract for how we want put.io SDKs to feel, evolve, and prove correctness.

## Core Position

- `putio-sdk-typescript` is the canonical full put.io API client in the workspace and should mirror the backend surface one to one
- `putio-sdk-swift` and `putio-sdk-kotlin` do not need feature-for-feature parity with TypeScript
- Swift and Kotlin still need the same quality bar: native APIs, typed boundaries, typed errors, safe live verification, and public-package discipline
- The SDKs are public products, not thin internal shims

## Product Intent

The SDK family should make put.io feel trustworthy, native, and pleasant to build on.

That means:

- the TypeScript SDK should grow into a fully fledged put.io API client that mirrors backend capability one to one
- the Swift and Kotlin SDKs can stay more focused on consumer, streaming, and core account-management flows for now
- no SDK should expose a sloppy or weakly typed surface just because its scope is smaller
- differences in scope must be deliberate and documented, not accidental drift

## First-Party Consumers

Scope decisions should be grounded in real first-party consumers, not symmetry for its own sake.

Today the strongest signals are:

- `putio-web`, which drives the broadest product and management surface
- `putio-cli`, which is also an OAuth and automation client with real command families for auth, account, files, events, transfers, and download links
- `putio-ios` and `putio-sdk-swift`, which currently bias toward consumer, playback, and account-management native flows
- `putio-sdk-kotlin`, which currently biases toward the same native-consumer lane rather than broad management coverage

This means TypeScript should remain the canonical full-surface contract reference not only because of the web app, but also because the CLI needs a typed automation-friendly surface. It does not mean Swift and Kotlin can stop at a tiny playback wrapper. The native baseline still needs a real consumer product surface with core account and security capabilities.

## Shared Principles

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

## Language Doctrine

### TypeScript

`putio-sdk-typescript` is the canonical full put.io API client for the family.

- Stay Effect-first
- Keep `Schema` at boundaries for request, response, config, and error shapes
- Keep Promise and Effect client surfaces aligned when both are public
- Prefer discriminated unions, explicit exports, and parameter-aware return types over loose optional bags
- Preserve the contract with typed boundaries, structured parsing, and explicit runtime assumptions
- Mirror backend capability one to one unless an endpoint is intentionally excluded for a documented reason such as safety, transport mismatch, or an unfinished backend contract
- If a backend surface is still unstable, under-specified, or not safely verifiable, document the temporary gap plainly
- Use conditional and parameter-aware return types where query parameters, pagination options, or field selections materially change the response shape
- Expose helper utilities around typed errors when they improve client ergonomics without hiding the underlying error taxonomy

TypeScript should usually lead on:

- richer endpoint coverage
- capability modeling
- difficult contract interpretation
- reusable error-taxonomy ideas
- full API surface completeness

### Swift

`putio-sdk-swift` should be unapologetically native.

- Prefer `async throws`
- Prefer `URLSession`
- Use `Decodable` and `Encodable` at the boundary
- Use typed value wrappers and enums where they help model backend state
- Use `LocalizedError` for user-facing recovery semantics
- Keep the package and CocoaPods surfaces healthy
- Verify integration behavior through the example app or formal live harness
- Use typed request inputs, explicit pagination structs, and overloads or generic wrappers where query parameters materially affect result shape
- Provide small helper APIs around typed errors when they improve app integration, such as recovery suggestions or user-facing messaging adapters

Swift should not regress into:

- callback-first public APIs
- raw JSON public results
- JavaScript-style compatibility layers
- cross-language abstraction leakage

### Kotlin

`putio-sdk-kotlin` should be coroutine-first and Android-friendly without becoming Android-only.

- Prefer `suspend` APIs
- Prefer `OkHttp` plus `kotlinx.serialization`
- Keep models serializer-friendly
- Use sealed hierarchies, value classes, and typed exceptions where they clarify the contract
- Keep localized or recovery-oriented error guidance separate from transport plumbing
- Preserve forward-compatible backend values when the server can evolve faster than the client
- Use typed request models, explicit pagination models, and generic or sealed result shapes when query parameters materially affect the response contract
- Provide helper utilities around typed exceptions when they improve ergonomics, such as classification helpers or user-facing recovery hints

Kotlin should not drift into:

- stringly typed error handling
- raw response bags
- synchronous wrapper APIs as the main public surface

## Scope Policy

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

## Capability Matrix

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

The current bias is:

- TypeScript should mirror the backend as the fully fledged put.io API client
- Swift and Kotlin should stay excellent at the native consumer lane first: auth, account basics, settings, two-factor and related security flows, files, transfers, search, history, trash, subtitles, and other playback-adjacent helpers
- Native SDKs may grow beyond that, but endpoint breadth must be earned by product need, not by parity pressure

## Verification Policy

Healthy put.io SDK repos should provide:

- one canonical deterministic verify path
- one documented live-test path for real API verification

The current workspace direction is:

- TypeScript: repo-native verify and live-test flows
- Swift: `make verify` plus a safe live-test entrypoint
- Kotlin: `./gradlew verify` plus `./gradlew liveTest`

Coverage is a guardrail, not the product. Still, SDK repos should carry a meaningful minimum line-coverage floor so public contracts cannot quietly rot.

## Non-goals

- forced feature parity across all SDKs other than the TypeScript full-client mission
- one shared runtime or codegen output used by every language
- generic generated clients that mirror the API without product judgment
- raw JSON compatibility layers as a long-term surface
- adding endpoints with weak typing just to increase apparent coverage

## What Good Looks Like

A healthy put.io SDK family looks like this:

- TypeScript is the canonical full backend-mirroring client
- Swift is async-first, typed, and Apple-native
- Kotlin is suspend-first, typed, and Android-native
- all three parse at the boundary
- all three treat errors as public contracts
- all three have deterministic verification plus safe live validation
- scope differences are intentional and documented
