# AGENTS.md

Contributor guidance for this public put.io skill catalog.

- Keep top-level docs short. Put task-specific depth in
  `skills/<name>/references/` only when it changes agent decisions.
- Skill frontmatter has `name` and `description` only. Descriptions must name
  the put.io target, the requests that activate the skill, and the nearest
  work that does not belong to it.
- Keep each skill package standalone. Do not require or sequence against a
  sibling package. State prerequisites and boundaries as capabilities.
- Keep public skills free of private repository content, workspace inventory,
  credentials, account details, support cases, and machine-local paths.
- Keep current commands and volatile implementation details with the repository
  that owns them. Link public upstream sources when a stable pointer is useful.
- Keep `agents/openai.yaml` picker metadata aligned with `SKILL.md`.
- Keep eval scenarios under `skills/<name>/evals/<scenario>/` as `task.md`
  plus `criteria.json`.
- Run `pnpm run verify` before handoff. CI runs the same keyless workflow and
  skill lint gate.
- Verify every finding. Fix valid findings, reply with the proving commit or
  evidence, and resolve their threads before merging.
- Use repo-relative links in checked-in Markdown.
