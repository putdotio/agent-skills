# `.patterns/<topic>.md` Template

A `.patterns/` entry is a short, opinionated record of how this repository handles one topic. It is not a tutorial and not a design doc — it is the answer a future contributor or agent would otherwise reverse-engineer from the codebase.

Keep each file under ~300 lines. If it grows past that, split it.

## Required sections

```markdown
# <Topic> Pattern

## Recommendation

The one-or-two-paragraph answer. Lead with what this repo does, in numbered steps when there is a sequence:

1. ...
2. ...
3. ...

What you get from this pattern (3-5 bullets).

## Why This Pattern

3-6 bullets. The reasoning a future reader needs to evaluate whether the pattern still fits when conditions change. Reference real constraints: framework choice, library upstream design, team convention, prior incident.

## Relevant Files

A bulleted list of files in this repo that establish or follow the pattern. Repo-relative paths.

- `src/...`
- `test/...`

## Rules

Numbered, concrete rules with code examples. Each rule has a name, a "Preferred" snippet, and an "Avoid" or "Use this instead of" snippet when an alternative is plausible.

### 1. <Rule name>

Preferred:

```ts
// ...
```

Avoid:

```ts
// ...
```

### 2. <Rule name>

...

## Anti-Patterns

Short list of approaches that look reasonable but do not fit this repo. Each one with a one-sentence reason.

- Approach X — reason it does not fit here.
- Approach Y — reason it does not fit here.
```

## Worked example

Below is a fully-shaped entry for a hypothetical `.patterns/transfer-state.md` in a put.io frontend app. It is modeled on the real discriminated-union pattern in `putio-sdk-typescript/src/domains/transfers.ts`. Use it as a calibration target — your entry should feel about this concrete and this opinionated.

```markdown
# Transfer State Pattern

## Recommendation

For this repo, the transfer status surface follows the SDK's discriminated union exactly:

1. Consume `Transfer` from `@putdotio/sdk` and never widen it. The SDK already encodes the LIVE / TORRENT_SEEDING / COMPLETED / ERROR branches as a `Schema.Union`.
2. Render in components by exhaustively matching on `transfer.status`. Use Effect's `Match` (or a `switch` with a `never` fallthrough) so adding a new branch fails the type-checker at every call site.
3. UI affordances (retry button, seeding indicator, error message) live on the branch that actually carries the data — no `transfer.error_message ?? ""` defaults, no `if (status === "ERROR" && error_message)` guards.
4. List subscriptions go through TanStack Query. Optimistic transitions on user action (cancel, retry) use `onMutate`/`onError` rollback; do not store a copy in Redux or local state.

What you get:

- The `error_message` field is reachable only on the ERROR branch, by construction.
- A new transfer status added upstream surfaces as a build error in every component that renders transfers.
- Loading/empty/error UI lives next to the query, not duplicated across screens.

## Why This Pattern

- The SDK already pays the modeling cost (`putio-sdk-typescript/src/domains/transfers.ts`). Re-narrowing in app code is duplicate work that drifts.
- Exhaustive matching has caught two real bugs in this repo where a new status was added and one screen forgot to render it (PR #482, PR #517).
- TanStack Query's mutation rollback is enough for the optimistic flows we have. Adding Redux for transfers is the kind of premature abstraction we keep removing elsewhere.
- We considered a feature-local `useTransferState` hook that returned a flat `{ status, error, progress }` bag — it loses the discriminated-union shape and reintroduces the guards we are trying to delete.

## Relevant Files

- `src/features/transfers/TransferRow.tsx`
- `src/features/transfers/queries.ts`
- `src/features/transfers/hooks/useCancelTransfer.ts`
- `test/features/transfers/TransferRow.spec.tsx`

## Rules

### 1. Match exhaustively, never guard with optional chaining

Preferred:

```tsx
import { Match } from "effect";

export const TransferRow = ({ transfer }: { transfer: Transfer }) =>
  Match.value(transfer).pipe(
    Match.when({ status: "ERROR" }, (t) => <ErrorRow message={t.error_message} />),
    Match.when({ status: "COMPLETED" }, (t) => <CompletedRow transfer={t} />),
    Match.when({ status: "TORRENT_SEEDING" }, (t) => <SeedingRow transfer={t} />),
    Match.when({ status: "LIVE" }, (t) => <LiveRow transfer={t} />),
    Match.exhaustive,
  );
```

Avoid:

```tsx
// Defeats the discriminated union; passes type checks even when status is "ERROR" without a message.
export const TransferRow = ({ transfer }: { transfer: Transfer }) => (
  <div>
    <span>{transfer.name}</span>
    {transfer.error_message ? <span className="error">{transfer.error_message}</span> : null}
  </div>
);
```

### 2. Optimistic mutations roll back on the query, not on local state

Preferred:

```ts
useMutation({
  mutationFn: cancelTransfer,
  onMutate: async (id) => {
    await queryClient.cancelQueries({ queryKey: ["transfers"] });
    const previous = queryClient.getQueryData<Transfer[]>(["transfers"]);
    queryClient.setQueryData<Transfer[]>(["transfers"], (old) =>
      old?.filter((t) => t.id !== id),
    );
    return { previous };
  },
  onError: (_err, _id, ctx) => {
    if (ctx?.previous) queryClient.setQueryData(["transfers"], ctx.previous);
  },
});
```

Avoid:

```ts
// Local "pending" state drifts from the query and from the server.
const [cancellingIds, setCancellingIds] = useState<number[]>([]);
```

### 3. Test the match table, not the rendered DOM

Preferred:

```ts
test.each([
  ["ERROR", <ErrorRow message="..." />],
  ["COMPLETED", <CompletedRow transfer={...} />],
  ["TORRENT_SEEDING", <SeedingRow transfer={...} />],
  ["LIVE", <LiveRow transfer={...} />],
] as const)("renders %s branch", (status, expected) => {
  // assert which sub-component rendered, not which div classes appeared
});
```

## Anti-Patterns

- Re-declaring `type TransferStatus = "ERROR" | "COMPLETED" | ...` in app code — the SDK is the source of truth; redefining it lets the two drift.
- Storing transfers in Redux to "react to changes everywhere" — TanStack Query already does this, with cache invalidation, retries, and rollback.
- A `useTransferState` hook that returns a flat bag (`{ status, errorMessage, isSeeding }`) — it discards the discriminated union and reintroduces optional-chaining guards in every consumer.
- Polling transfers from a `useEffect` with `setInterval` — use the query's `refetchInterval`. The interval lives next to the query key, not next to the component.
```

## Calibration tips

- If a section is empty or feels like filler, delete the section. Better to ship a short entry than a padded one.
- Use `Preferred` and `Avoid` snippets, not prose-only descriptions. Snippets read faster and rot slower.
- Cite real files and real incidents. Generic advice belongs in this skill, not in `.patterns/`.
- Update the entry in the same PR that changes the underlying pattern. A `.patterns/` file that lies is worse than no file.
- Link out to canonical references in the put.io ecosystem (e.g., `putio-sdk-typescript`, `putio-cli`, or the relevant in-repo module) when the pattern is borrowed wholesale rather than re-derived.
