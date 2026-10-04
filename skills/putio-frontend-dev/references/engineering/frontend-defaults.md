# put.io frontend defaults

Use these when the target repository's guidance and code are silent.

## Schemas and parsing

- TypeScript contracts use Effect `Schema`; derive types with
  `Schema.Schema.Type<typeof XSchema>` instead of parallel hand-written types.
  Name related schemas on a strict hierarchy such as `FileBaseSchema`,
  `FileBroadSchema`, and `FilesListEnvelopeSchema`.
- Brand entity IDs (`FileId`, `TransferId`) with `Schema.brand` so unrelated IDs
  cannot cross.
- Keep schemas beside their boundary: API responses by the client, form values
  by the form, URL params by the route. Multi-consumer repos keep shared
  schemas in a no-runtime package: definitions only, no services or helpers.
- Where Effect is too heavy for the runtime, use small narrowing helpers
  (`getRecord`, `getString`, `getNumber`) plus per-field guards; Swift and
  Kotlin use `Codable` or kotlinx serialization. Nothing leaves the boundary as
  `unknown` or `Record<string, unknown>`.
- Keep success and HTTP-failure decoding separate while returning the
  repository's shared error type. Business rules for an input live in its
  boundary schema; inner `if (!data) return null` guards mean the boundary
  leaked.

## States

- Model API variants as schema unions whose branches require or forbid fields
  (an `ERROR` transfer requires `error_message`; a completed one forbids it),
  and narrow query-dependent responses from the query input with a runtime
  guard behind the type.
- Match exhaustively (Effect `Match`, `switch` with a `never` fallthrough, Swift
  enums) so a new state fails the type checker at every fork.
- For server-extensible unions (statuses, error codes), put the `unknown`
  fallback variant on the list-item parser, not the response parser: a new
  status degrades one row instead of blanking the list.

## State machines

Model auth, payment, video conversion, playback, upload, and transfer lifecycle
as explicit machines when a forgotten state is a real failure mode.

- React TypeScript uses XState. Effect owns services, DI, and error
  propagation; XState owns UX flow. They meet inside `fromPromise`, with no
  service refs in machine context and no closures over the runtime:

  ```ts
  actors: {
    updatePlan: fromPromise(({ input }: { input: UpdatePlanInput }) =>
      RuntimeClient.runPromise(
        Effect.gen(function* () {
          const api = yield* PutioSdk;
          yield* api.transfers.update(input);
        }).pipe(Effect.tapErrorCause(Effect.logError)),
      ),
    ),
  },
  ```

  A repo that picks another machine library records it in its `AGENTS.md`.

- Effect code models loops with `Effect.gen`, explicit state, deadlines,
  bounded sleeps, and terminal conditions. Swift and Kotlin drive enum states
  through the repository's existing event or delegate boundary.
- Effects attach to states (`entry`, `exit`, invoked actors), not event
  handlers. Test machines apart from UI by sending events and asserting
  transitions.
- Polling and reconnect (transfer stream, player segments, websocket) are an
  explicit struct, not a hidden `setTimeout`: `phase`, `reconnectPhase`
  (`idle | waiting | attempting | exhausted`), `attemptCount`,
  `disconnectedAt`, and a computed ISO `nextRetryAt` from capped exponential
  backoff. Tests assert timing; UI renders `nextRetryAt` without owning a timer.
- Long operations (migration, bulk move, large upload, conversion) stay
  headless and accept `progress?: (p: { current: number; total: number; label: string }) => void`.
  Each client renders its own bar, modal, or sheet; tests assert the event
  sequence.

## Errors

- Errors are `Data.TaggedError` values with context, for example
  `PutioApiError` carrying `status` and the `PutioErrorEnvelope` body. Declare
  operation-specific errors from known status codes and error types; keep
  unknown errors in the base union.
- Let SDK errors propagate unchanged through browser adapters; app-local wrapper
  classes discard operation context. Localize at the route or feature boundary.
- Never render `error.message`. Components surface errors through localizers
  that match a status, API error type, or predicate and return
  `{ message, recoverySuggestion }`:

  ```tsx
  export const localizeRenameFileError = (error: unknown) =>
    localizeError(error, [
      {
        error_type: "NAME_ALREADY_EXIST",
        kind: "api_error_type",
        localize: () => ({
          message: "Target folder already contains a file with this name",
          recoverySuggestion: {
            description: "Rename one of the files and try again",
            type: "instruction",
          },
        }),
      },
    ]);
  ```

- React frontends follow the web app's three-tier model:
  - **Known known**: a feature localizer returns a targeted message plus an
    instruction or action.
  - **Known unknown**: a recognized API error shape with no feature localizer.
    Capture `UnlocalizedAPIError`, show a generic API error, and keep a
    support-ready trace id in metadata.
  - **Unknown unknown**: capture the exception, show a generic fallback, and
    keep the captured error id in metadata.
- The localizer is the redaction chokepoint: raw error bodies, request URLs
  with query strings, bearer tokens, and stack traces pass through it before UI
  text, telemetry, Sentry, or analytics. Redaction and output escaping solve
  different problems; apply both to untrusted text in log-like surfaces, and
  describe rejected input by shape instead of echoing control-bearing values.
- Avoid `catch (error) { Toast.Show(String(error)); Sentry.captureException(error); }`
  in leaves: it leaks raw text, duplicates telemetry policy, and offers no
  recovery.
- Place error boundaries at app, route, lazy-load, or feature-island level.
  Treat chunk-load failures and load timeouts as recoverable states with a
  reload action.
- Route contact-support actions through the repo's support adapter so the
  channel (Intercom, email) can change without touching localizers.

## Effect runtime

Effect is the default runtime for new TypeScript outside legacy bundles. Keep
the Effect surface runtime-free: Promise-facing callers own a small
`ManagedRuntime` adapter and its disposal. Tests provide layers with mock
boundary services instead of reaching into globals.

## Server state and forms

- TanStack Query owns HTTP-shaped server state. Query functions call the SDK
  through the runtime adapter:
  `queryFn: () => RuntimeClient.runPromise(PutioSdk.pipe(Effect.flatMap((sdk) => sdk.transfers.list(filter))))`.
- Keys are namespaced arrays with structured input (`["transfers", filter]`) so
  prefix invalidation works. Mutations invalidate queries instead of patching
  local state; polling is `refetchInterval` on the query.
- Forms that mutate a cached read call that `useMutation` from the form action.
  One-off RPC actions with no cached read (login, OTP verification,
  fire-and-forget settings save) in Effect-React code use `useActionEffect`, a
  bridge over React 19 `useActionState`:

  ```ts
  export const useActionEffect = <Payload, A, E, R>(
    runtime: ManagedRuntime.ManagedRuntime<R, never>,
    effect: (payload: Payload) => Effect.Effect<A, E, R>,
  ) =>
    useActionState<E | null, Payload>(
      (_, payload) =>
        runtime.runPromise(
          effect(payload).pipe(
            Effect.match({ onFailure: Function.identity, onSuccess: Function.constNull }),
          ),
        ),
      null,
    );
  ```

  Decode inside the Effect with `Schema.decodeUnknown` so parse and business
  errors share one typed channel. Bind `action` to `<form action>`, disable the
  fieldset while `pending`, and read keys explicitly with `formData.get` or
  `formData.getAll` so attacker-controlled keys never reach the decoder. Skip
  optimistic updates unless latency warrants them. TanStack Form repos keep
  form rules in their `AGENTS.md`.

## React effects

Components do not call `useEffect` directly. Derive during render, act in
handlers, submits, and mutations, read external systems through
`useSyncExternalStore`, and attach to systems React does not own through one
reviewed wrapper hook with cleanup.

## Styling

Follow the repo's stack and record it in `AGENTS.md`: Tailwind v4 with design
tokens for new web work, CSS modules with TypeScript theme tokens where bundle
size or old browsers matter, Emotion with Theme-UI only to maintain legacy
bundles.

## Tests

- Mock the network when needed, but parse responses through the production
  path.
- Gate shared-account live tests behind repository-owned secret hydration and
  sequential execution. Keep them non-destructive.
