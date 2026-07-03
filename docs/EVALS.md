# Evals

Each published put.io Tessl plugin carries eval scenarios under its package
directory:

```text
skills/frontend/<plugin>/evals/<scenario>/
├── task.md
└── criteria.json
```

`task.md` is the user-facing task. `criteria.json` is a weighted checklist that
scores whether using the skill changes the agent's behavior in the intended
direction.

## Local Commands

Run the normal repo gate before changing evals:

```bash
make verify
```

Run one eval set manually when iterating on a plugin:

```bash
./scripts/tessl.sh eval run skills/frontend/patterns
./scripts/tessl.sh eval view <eval-run-id>
```

Publishing also uploads the scenarios and starts a registry eval run:

```bash
./scripts/tessl.sh plugin publish --dry-run --bump patch skills/frontend/patterns
```

## Interpreting Registry Scores

Registry Quality comes from Tessl's review of the skill bundle. Registry Impact
comes from the published eval scenarios. A plugin can have a strong local review
score but a lower registry aggregate when an eval scenario misses one rubric
point.

When Impact drops:

1. Open the eval run for the published plugin version.
2. Compare baseline and usage-spec scores per scenario.
3. If the usage-spec answer missed a real instruction, tighten the skill or its
   references.
4. If the rubric is too narrow or ambiguous, tighten the eval criteria instead.
5. Rerun `make verify`, then publish a patch version.

Keep evals focused on durable behavior: trigger routing, boundary choices,
verification stance, and artifacts future agents should produce.
