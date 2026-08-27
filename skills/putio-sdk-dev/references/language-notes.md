# SDK language notes

Use the section that matches the SDK repo you are changing.

## TypeScript

- Stay Effect-first when the repo already uses Effect.
- Keep `Schema` at boundaries for request, response, config, and error shapes.
- Keep Promise and Effect clients aligned when both are public.
- Prefer discriminated unions, explicit exports, and parameter-aware return types over loose option bags.
- Preserve the typed surface; use unsafe casts or ignored type failures only with explicit approval.

## Swift

- Prefer `async throws` and native Swift value types.
- Keep the package surface open-source-safe and preserve package-manager install paths.
- Verify the example app when auth or integration behavior changes.

## Kotlin

- Prefer coroutine-first APIs, typed public results, and Kotlin-native surfaces.
- Keep models serialization-friendly.
- Prefer explicit error contracts over generic failures.
- Stay close to the TypeScript contract shape without forcing full endpoint parity.
- Preserve forward-compatible backend values when the server can evolve faster than the client.
