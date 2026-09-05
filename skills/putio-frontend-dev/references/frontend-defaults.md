# put.io frontend defaults

Use these defaults when the target repository's guidance and code are silent.
Target-repository precedent always wins.

Implementations vary by runtime. Use Effect Schema where it fits, lightweight
parsers where bundle size matters, and native language types where available.

## Type and schema driven development

The contract lives in a schema. Types are derived from the schema. Code keeps each shape in one canonical place.

- For TypeScript, the put.io default is Effect's `Schema`. Name related schemas
  on a strict hierarchy such as `FileBaseSchema`, `FileBroadSchema`, and
  `FilesListEnvelopeSchema`
- Type extraction follows the schema: `export type FileType = Schema.Schema.Type<typeof FileTypeSchema>`. Keep parallel hand-written `type X = { ... }` declarations out of schema-owned contracts.
- Brand entity IDs so unrelated numeric or string IDs cannot cross. A small helper goes a long way:

  ```ts
  const makeEntityId = <Brand extends string>(brand: Brand) =>
    Schema.String.pipe(Schema.brand(brand));
  export const FileId = makeEntityId("FileId");
  export const TransferId = makeEntityId("TransferId");
  // FileId and TransferId are now incompatible at the type level.
  ```

- Schemas live next to the boundary they describe: API responses next to the API client, form values next to the form, URL params next to the route.
- For multi-consumer repos (server + web, app + SDK, monorepo with shared types), keep schemas in a *no-runtime* package: schema definitions only, no services, no helpers. The boundary between contract and implementation stays clean.
- Where Effect Schema is too heavy for the target runtime, use small typed-narrowing helpers (`getRecord`, `getString`, `getNumber`) plus per-field type guards. The bar is the same: nothing leaves the boundary as `unknown`
- Where native typing exists, use Swift `Codable` or Kotlin serialization and
  still parse at the boundary.

## Parse, don't validate

External input becomes a typed value at the boundary, or it does not enter the program.

- Network responses, URL params, `localStorage`, `postMessage`, file contents, query strings, environment variables: all parsed at the edge.
- A "validated" value still typed as `unknown`, `any`, `Record<string, unknown>`, or "the same shape but with `// trust me`" is **not parsed**. Keep going until the value is fully typed.
- Parse failures are typed errors, not thrown strings. Keep success and HTTP
  failure decoding separate while returning the repository's shared error type.
- Apply the same rule to environment variables, files, storage, and route
  inputs. Keep their business rules in the boundary schema.
- Once parsed, the typed value flows inward unchanged. Inner code does not re-validate, re-coerce, or guard with `if (!data) return null`. Those guards are signals that the boundary leaked.

## Make impossible states impossible

The render tree should not need defensive checks.

- Prefer discriminated unions over flag bags:

  ```ts
  // ERROR branch *requires* error_message; COMPLETED branch *forbids* it.
  const TransferErrorSchema = Schema.extend(
    TransferBaseSchema.pipe(Schema.omit("error_message", "status")),
    Schema.Struct({
      error_message: Schema.String,
      status: Schema.Literal("ERROR"),
    }),
  );
  export const TransferSchema = Schema.Union(
    TransferErrorSchema,
    TransferLiveSchema,
    TransferTorrentSeedingSchema,
    TransferCompletedSchema,
    TransferBaseSchema,
  );
  ```

- Narrow conditional responses from the query input and back the type-level
  guarantee with a runtime guard.
- For non-Effect TypeScript, plain discriminated unions still work. Model variants like `AppPaymentMethod` as `{ type: "cryptocurrency"; currency: Cryptocurrency } | { type: "card" } | { type: "local-option" }`
- For Swift, use enums with associated values for the same job.
- Exhaustive matches at every fork. `Match` from Effect, `switch` with `never` fallthrough, or pattern matches in Swift. Adding a new state should fail the type checker until every site handles it.
- For unions whose server end can extend (status enums, error codes), include an `unknown` fallback variant at the *list-item* parser, not the response parser. A new server status should leave one row in a degraded "unknown" state, not blank out the whole list.

## State machines for bug-sensitive flows

Auth, payment, video conversion, video playback, upload, transfer lifecycle: model them explicitly when transitions actually matter. Bugs in these flows cost trust.

Use `useState` for trivial toggles, single-screen forms, or anywhere "did we forget a state" is not a real failure mode. Add a state machine when forgotten states are a real failure mode.

- The shape varies by repo. The principle does not: enumerate states, name transitions, attach effects to states (not to event handlers).
- **In Effect TypeScript**, model loops with `Effect.gen`, explicit state,
  deadlines, bounded sleeps, and terminal conditions. Avoid implicit retries and
  callback chains.
- **In React TypeScript**, the put.io recommendation is XState. When XState meets an Effect-based service layer, bridge them inside `fromPromise` so the machine stays pure and services stay typed:

  ```ts
  const machine = setup({
    types: { context: {} as Ctx, events: {} as Evt },
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
  }).createMachine({
    states: {
      Updating: {
        invoke: {
          src: "updatePlan",
          input: ({ event }) => event.payload,
          onError: { target: "Idle", actions: assign(...) },
          onDone: { target: "Idle" },
        },
      },
    },
  });
  ```

  Effect owns services, DI, and error propagation. XState owns UX flow. They meet at `RuntimeClient.runPromise` inside `fromPromise`: no service refs in machine context, no closures over the runtime. A repo may pick another lib (Effect's `Machine`, a typed reducer); encode the choice in `.patterns/state-machines.md`

- **In Swift or Kotlin**, use enums with associated values and drive transitions
  through the repository's existing event or delegate boundary.
- The machine is the source of truth for which transitions are allowed. The UI dispatches events; it does not call `setState` to "force" a state.
- Side effects (network, storage, navigation) live as `entry`, `exit`, or invoked services on states: never inline in event handlers.
- Test the machine separately from the UI. Send events, assert state transitions, assert side effects fired.

A specifically valuable shape: **reconnect / retry as explicit state**. For anything that polls or reconnects (transfer status stream, video player segment fetch, websocket session), keep the retry state as a plain struct with a `phase` discriminator and a *computed* `nextRetryAt` ISO timestamp: not a hidden `setTimeout`:

```ts
type ReconnectStatus = {
  phase: "connected" | "connecting" | "disconnected";
  reconnectPhase: "idle" | "waiting" | "attempting" | "exhausted";
  attemptCount: number;
  disconnectedAt: string | null;
  nextRetryAt: string | null;
};

const nextDelayMs = (attempt: number, max = 7) =>
  attempt >= max
    ? null
    : Math.min(1_000 * 2 ** attempt, 64_000);
```

Tests can assert exact retry timing instead of waiting on real timers. UI can render `nextRetryAt` directly without owning the timer.

A related shape: **long-running ops emit `{ current, total, label }` progress events; the UI plugs in.** Keep migration, bulk file move, large upload, conversion-job code headless: it accepts a `progress?: (p: { current: number; total: number; label: string }) => void` callback. The CLI renders a TTY bar, the web app renders a modal, the native app renders a progress sheet. None of those concerns leak into the operation itself, and tests assert progress event sequence instead of UI output.

## Errors

- Errors are typed values with context, not thrown strings. The putio reference is `Data.TaggedError` in TypeScript:

  ```ts
  export class PutioApiError extends Data.TaggedError("PutioApiError")<{
    readonly status: number;
    readonly body: PutioErrorEnvelope;
  }> {}
  ```

- Declare operation-specific errors up front from known status codes and error
  types. Preserve unknown errors in the base union and full context on known
  errors.
- UI surfaces errors through localizers, not raw error switches in components.
  A localizer matches a status, API error type, or predicate and returns
  `{ message, recoverySuggestion }`
- React frontends follow the web app's known-known / known-unknown / unknown-unknown model:
  - **Known known**: a feature localizer recognizes a product or API condition and returns a targeted message plus an instruction or action.
  - **Known unknown**: the value is a recognized API error shape, but no feature-specific localizer exists. Capture a telemetry event such as `UnlocalizedAPIError`, show a generic API error, and keep a support-ready trace id in metadata.
  - **Unknown unknown**: the value is not recognized. Capture the exception, show a generic fallback, and keep the captured error id in metadata.
- The localizer is also the redaction chokepoint: raw `PutioApiError.body`, request URLs with query strings, and stack traces go through it before reaching UI text, telemetry, or third-party SDKs (Sentry, analytics).
- Error boundaries exist at the app, route, lazy-load, or feature-island level, not wrapped around every component. The goal is to keep the shell alive and isolate the broken surface, not to hide programmer errors everywhere.
- Distinguish *expected error the user can act on* (typed, rendered inline) from *unexpected crash* (caught by the boundary, logged, generic fallback).
- Lazy-loaded route failures are recoverable states. Match chunk-load failures and load timeouts, then offer a reload action instead of surfacing an opaque module-loading error.
- Support fallbacks are part of the error model. Route contact-support actions through the repo's support adapter so Intercom, email, or another configured channel can be swapped without changing feature error localizers.
- Redact secrets, bearer tokens, and sensitive query parameters before logs or
  UI. Redaction and output escaping solve different problems; apply both to
  untrusted text in log-like surfaces.
- Error messages for rejected input describe the invalid shape without reflecting raw control-bearing values back to terminal output.

Preferred React shape:

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

Avoid:

```tsx
try {
  await renameFile(input);
} catch (error) {
  Toast.Show(String(error));
  Sentry.captureException(error);
}
```

That leaks raw error text, duplicates telemetry policy in a leaf, and gives the user no recovery path.

## Effect runtime wiring (TypeScript)

Effect is the put.io default runtime for new TypeScript code outside legacy
bundles. Keep its wiring explicit:

- Define services as `Context.Tag`
- Build live implementations with `Layer.effect` or `Layer.succeed`. Compose
  them through `Layer.mergeAll` and explicit `Layer.provide`
- Keep the Effect surface runtime-free. Promise-facing callers own a small
  `ManagedRuntime` adapter and its disposal.
- Tests provide layers with mock boundary services instead of reaching into
  globals.

## Server state

Server state is a cache of someone else's truth. It needs invalidation,
deduplication, retry, refetch-on-focus, abort-on-unmount, and
stale-while-revalidate. Hand-rolling those behaviors with `useEffect`,
`useState`, and `fetch` creates avoidable bugs.

The put.io default for HTTP-shaped server state is **TanStack Query**. New code in put.io web frontends should match this pattern.

```ts
// queries/transfers.ts: keys are structured, namespaced, and typed.
export const transfersKey = (filter: TransferFilter) =>
  ["transfers", filter] as const;

export const useTransfers = (filter: TransferFilter) =>
  useQuery({
    queryKey: transfersKey(filter),
    queryFn: () => RuntimeClient.runPromise(PutioSdk.pipe(Effect.flatMap((sdk) => sdk.transfers.list(filter)))),
  });

export const useCancelTransfer = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: TransferId) =>
      RuntimeClient.runPromise(PutioSdk.pipe(Effect.flatMap((sdk) => sdk.transfers.cancel(id)))),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["transfers"] }),
  });
};
```

Rules:

- **Use `useQuery` for server reads.** It provides loading, error, dedup, abort, retry, and stale-while-revalidate behavior in one place.
- **Query keys are arrays, namespaced per feature**, with the input as a structured payload, not a stringified blob. `["transfers", filter]` not `` `transfers-${JSON.stringify(filter)}` ``. Cache invalidation works on prefix.
- **Mutations invalidate the cache, not local state**. `onSuccess: invalidateQueries({ queryKey: ["transfers"] })`. Optimistic flows use `onMutate` to set + return a snapshot, `onError` to roll it back.
- **TanStack Query for server reads, `useActionEffect` (or `useMutation`) for writes**: pick `useMutation` when there is a cache to invalidate; `useActionEffect` when the action is a one-off RPC with no cached read.
- **Polling lives next to the query key**, not next to the component. `refetchInterval: 5_000` on the query, not `setInterval` in a `useEffect`

## Forms

For form mutations in Effect-React code, the put.io default is a small `useActionEffect` bridge over React 19's `useActionState`. Keep the FormData → Schema → Effect flow as one typed pipeline.

When the form mutates a server read that lives in a TanStack Query cache (rename in a file list, cancel in a transfer list, edit in a settings query), prefer `useMutation` from the *Server State* section above and call its `mutate` from the form's action handler: that way the cache invalidation lives next to the mutation. Reserve `useActionEffect` for one-off RPC actions with no cached read on the other side (login, OTP verification, fire-and-forget settings save).

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

Usage: schema decode happens inside the Effect, parse errors stay typed alongside business errors, and there is no separate validate-then-submit step:

```tsx
const [error, action, pending] = useActionEffect(RuntimeClient, (formData: FormData) =>
  Effect.gen(function* () {
    const sdk = yield* PutioSdk;
    const input = yield* Schema.decodeUnknown(RenameFileInput)({
      fileId: formData.get("fileId"),
      name: formData.get("name"),
    });
    yield* sdk.files.rename(input);
  }),
);

<form action={action}>
  <fieldset disabled={pending}>...</fieldset>
</form>;
```

Read keys explicitly via `formData.get(name)` (or `formData.getAll(name)` for multi-value fields like checkbox groups). This preserves repeated names and keeps attacker-controlled keys out of the schema decoder.

A TanStack Query mutation that invalidates the relevant query keys does not need to update local state: the next read picks up the change. Skip optimistic updates unless the user-perceived latency actually warrants them.

## Component and state placement

- Components are deep modules: small surface (props), meaningful interior. A wrapper that forwards every prop unchanged is not pulling its weight.
- Keep state local until a second consumer needs it.
- Effects (data fetching, subscriptions, storage, telemetry) live at leaves and adapters. Pages compose; leaves do.
- Keep server-state in server-state tools and UI-state in UI-state tools. See *Server State* above.
- Pure render trees: a component that takes typed props and returns JSX with no side effects is the easiest thing to test, animate, and refactor.

Imitate: small composable primitives in your app's UI layer rather than monolithic screen templates.

## Styling

put.io has multiple valid styling stacks depending on constraints:

- Tailwind v4 + design tokens for new general-purpose web work.
- Plain CSS modules + TS theme tokens where bundle size or old-browser support matters.
- Emotion + Theme-UI in legacy bundles: maintain existing code while moving new work to current patterns.

Pick the repo's existing stack. If the repo is silent, default to Tailwind v4 for new web work. Encode the choice in `.patterns/styling.md`

## Testing shape

- Write tests at the level the bug would surface: a parse bug needs a parse test, a state-machine bug needs a machine test, a render bug needs a render test, an interaction bug needs an interaction test.
- Prefer real implementations over mocks at the contract boundary. Mock the
  network when needed, but parse responses through the production path.
- Gate shared-account live tests behind repository-owned secret hydration and
  sequential execution. Keep them non-destructive.
- TypeScript repos use `vite-plus/test` (Vitest). E2E uses Playwright.
- Assert on behavior with controlled clocks and public effects instead of logger output, real timers, or implementation internals.

## Verification before "done"

- Type-check, lint, unit tests pass: necessary, not sufficient for UI work.
- Exercise the feature in a browser or device. Click the golden path. Try one edge case. Watch the network tab and console.
- If the UI cannot be exercised (no dev server, no preview), say so explicitly in the PR and list type checks as partial evidence.
- Use the target repository's affected/dependent checks, retaining mandated
  full gates and separate runtime proof. Reuse valid results until changes,
  failures or a concrete concern invalidate them.
