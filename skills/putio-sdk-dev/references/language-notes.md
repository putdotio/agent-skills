# SDK language notes

Use the section that matches the SDK repo you are changing.

## TypeScript

`putio-sdk-typescript` is the canonical full put.io API client for the family.

- Stay Effect-first when the repo already uses Effect.
- Keep `Schema` at boundaries for request, response, config, and error shapes.
- Keep Promise and Effect clients aligned when both are public.
- Prefer discriminated unions, explicit exports, and parameter-aware return types over loose option bags. Use conditional return types where query parameters, pagination options, or field selections materially change the response shape.
- Preserve the typed surface; use unsafe casts or ignored type failures only with explicit approval.
- Mirror backend capability one to one unless an endpoint is intentionally excluded for a documented reason such as safety, transport mismatch, or an unfinished backend contract. Document unstable or unverifiable backend surfaces as temporary gaps.
- Expose helper utilities around typed errors when they improve client ergonomics without hiding the underlying error taxonomy.

TypeScript usually leads on endpoint coverage, capability modeling, difficult contract interpretation, and reusable error-taxonomy ideas.

## Swift

The Swift SDK is unapologetically native.

- Prefer `async throws`, `URLSession`, and native Swift value types.
- Use `Decodable` and `Encodable` at the boundary; use typed value wrappers and enums where they help model backend state.
- Use `LocalizedError` for user-facing recovery semantics, and provide small helper APIs around typed errors when they improve app integration.
- Use typed request inputs, explicit pagination structs, and overloads or generic wrappers where query parameters materially affect result shape.
- Keep the package and CocoaPods surfaces open-source-safe and preserve package-manager install paths.
- Verify the example app or formal live harness when auth or integration behavior changes.

Swift must not regress into callback-first public APIs, raw JSON public results, JavaScript-style compatibility layers, or cross-language abstraction leakage.

## Kotlin

The Kotlin SDK is coroutine-first and Android-friendly without becoming Android-only.

- Prefer `suspend` APIs, `OkHttp` plus `kotlinx.serialization`, and serializer-friendly models.
- Use sealed hierarchies, value classes, and typed exceptions where they clarify the contract; prefer explicit error contracts over generic failures.
- Keep localized or recovery-oriented error guidance separate from transport plumbing, and provide helpers around typed exceptions such as classification or user-facing recovery hints.
- Use typed request models, explicit pagination models, and generic or sealed result shapes when query parameters materially affect the response contract.
- Stay close to the TypeScript contract shape without forcing full endpoint parity.
- Preserve forward-compatible backend values when the server can evolve faster than the client.

Kotlin must not drift into stringly typed error handling, raw response bags, or synchronous wrapper APIs as the main public surface.
