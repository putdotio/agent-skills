---
name: putio-frontend-patterns
description: Apply put.io frontend code patterns and seed repo-local `.patterns/` conventions. Use when writing or reviewing UI/frontend code in a put.io frontend repo, picking the default approach for types, data parsing, state machines, error handling, components, or testing, or seeding/extending the repo's `.patterns/` folder. Skip for delivery and CI shape (use `putio-frontend-repos`), top-level docs (use `putio-frontend-docs`), or SDK packages (use `putio-sdk-dev`).
---

# put.io Frontend Patterns

Use this skill when writing or reviewing UI/frontend code in a put.io frontend repository, or when seeding the repo's `.patterns/` folder.

Bundled references: [frontend defaults](./references/frontend-defaults.md) and [pattern template](./references/pattern-template.md).

Use this skill for put.io-wide code defaults and `.patterns/` for repo-specific choices such as schema, state-machine, styling, and testing libraries.

## Quick Rules

- **Type/schema-driven**: schemas at the boundary are the source of truth. Types follow from schemas, not the other way around.
- **Parse at the boundary**: turn unknown input into typed values at the boundary. Pass typed values inward so raw `unknown`, untyped JSON, and "validated but still loosely typed" data stay out of the render tree.
- **Make impossible states impossible**: discriminated unions, sealed shapes, exhaustive matches. No sentinel `null`s or `isLoading + data + error` boolean salads.
- **State machines for bug-sensitive flows**: auth, payment, video conversion, video playback, upload, transfer lifecycle — model them as explicit state machines, not ad-hoc `useState` cascades.
- **Localize expected errors, bound unexpected errors**: feature code maps known failures to actionable localized messages; route or feature boundaries catch unknown crashes without blanking the whole app.
- **Effects at leaves**: data fetching, navigation, storage, telemetry happen in adapters and leaves. Render trees stay pure and easy to test.
- **No type escape hatches**: no `as`, no non-null `!`, no `@ts-expect-error` without a written reason. If you need one, the model is wrong — fix the model.
- **Repo overrides skill**: `.patterns/<topic>.md` in the repo wins over this skill's defaults. The skill is the fallback when the repo is silent.

## Workflow

1. Inspect the repo: framework, build tool, styling system, state and data libraries, test runner, and whether `.patterns/` (or `docs/patterns/`) already exists.
2. Read `AGENTS.md`, `README.md`, and any existing `.patterns/*.md` files relevant to your task before writing code.
3. If `.patterns/` is silent on the area you are touching, read [frontend defaults](./references/frontend-defaults.md) and apply the put.io default unless the repo signals otherwise. Always read the *Errors* section before adding catch blocks, error boundaries, toast/empty-state errors, Sentry capture, or support-contact fallbacks.
4. Match existing patterns in the code. If you must diverge, capture the new pattern as a draft `.patterns/<topic>.md` entry alongside the change, following [pattern template](./references/pattern-template.md).
5. Run the repo's `verify` command. If UI is in scope, exercise the path in a browser or device — type checks and unit tests prove correctness, not feature behavior.
6. Audit `.patterns/` for drift: a renamed library, removed approach, or stale example needs to be updated or removed in the same PR.

## Setting up `.patterns/`

Use `.patterns/` at the repo root.

- One file per topic, kebab-case. Typical seeds: `state-machines.md`, `data-fetching.md`, `forms.md`, `styling.md`, `testing.md`, `error-handling.md`, `routing.md`.
- Each file follows [pattern template](./references/pattern-template.md): Recommendation, Why, Relevant files, Rules, Anti-patterns.
- Keep each file under ~300 lines so it loads on demand without dominating context.
- Link `.patterns/` from the repo's `AGENTS.md` so future contributors and agents discover it automatically.

Keep `.patterns/` at the repo root so user/contributor docs and code-convention docs stay separated.

## When to add a pattern entry

Add `.patterns/<topic>.md` when a code-level choice is non-obvious, two reasonable approaches exist and the repo has picked one, or a bug-sensitive flow is modeled as a state machine. Skip it if the behavior is obvious from the code, belongs in `README.md` / a WHY comment, or is a one-off workaround.

## Concrete shape

Parse-at-boundary, schema as source of truth (TypeScript with Effect Schema):

```ts
const FileSchema = Schema.Struct({
  id: Schema.Number.pipe(Schema.int()),
  name: Schema.String,
  size: Schema.Number.pipe(Schema.nonNegative()),
});
type PutioFile = Schema.Schema.Type<typeof FileSchema>;

const parseFile = (input: unknown): Effect.Effect<PutioFile, ParseError> =>
  Schema.decodeUnknown(FileSchema)(input);
```

Impossible states made impossible — required fields appear only on the branch that actually has them:

```tsx
type TransferStatus =
  | { status: "LIVE"; progress: number }
  | { status: "COMPLETED"; completed_at: string }
  | { status: "ERROR"; error_message: string };

const render = (t: TransferStatus) =>
  Match.value(t).pipe(
    Match.when({ status: "ERROR" }, (t) => <ErrorRow message={t.error_message} />),
    Match.when({ status: "COMPLETED" }, (t) => <Done at={t.completed_at} />),
    Match.when({ status: "LIVE" }, (t) => <Live progress={t.progress} />),
    Match.exhaustive,
  );
```

For non-Effect TypeScript and for native (Swift, Kotlin), the principle holds — the implementation tracks the repo's stack. See [frontend defaults](./references/frontend-defaults.md).

## Canonical Code References

When deciding how to structure a new boundary, parser, state machine, or error type, read sibling repos in this workspace before inventing something fresh. Concrete pointers live in [frontend defaults](./references/frontend-defaults.md).

## Boundaries

- `putio-frontend-repos` — repo CI and delivery shape (verify, publish, deploy).
- `putio-frontend-docs` — README, CONTRIBUTING, SECURITY structure.
- `putio-sdk-dev` — SDK package patterns (namespaces, typed contracts, multi-language parity).
