# Frontend repo docs guideline

Use this when shaping top-level docs for a put.io frontend repo. Copy the structure, not the wording.
Documentation is part of the interface; optimize for scanability, rhythm, and visual clarity, not just correctness.

## Core split

- `README.md` is user-facing.
- `CONTRIBUTING.md` is developer-facing.
- `LICENSE` states the license; reference it from `README.md`
- `SECURITY.md` explains private-first vulnerability disclosure and points reporters to `devs@put.io`

This separation keeps “how do I use this?” out of contributor docs and keeps “how do I set up my environment?” out of the README.

## README.md

Use this order unless the repo gives a strong reason not to:

1. Hero
2. Install
3. Quick usage or first successful flow
4. Optional examples, variants, or integration notes
5. Docs
6. Contributing
7. License

- Answer these questions on the first screen: what is this project, how do I install it, and how do I use it.
- For package repos, show install commands and one short usage example.
- For app repos, show the user-facing way to access or use the app; contributor setup belongs in `CONTRIBUTING.md`
- Use human-facing labels, not raw filenames or paths: `Contributing`, `Distribution`, `Architecture`, or `Agent guide` over `CONTRIBUTING.md` or `docs/DISTRIBUTION.md`
- Add short `Contributing` and `License` sections that point to `CONTRIBUTING.md` and `LICENSE`
- Link to `SECURITY.md` when it materially helps navigation, while keeping the main user flow clear.
- Link to deeper docs before the README turns into a handbook.

## Hero and badges

- Use a brand block only when the repo has a real recognizable asset.
- Match an existing hero or badge pattern in the target repository. If none
  exists, keep the README text-first.
- Link an asset already owned or referenced by the target repository. Do not
  copy shared brand files into it.
- Keep the hero compact: name, one-sentence purpose, optional positioning sentence.
- Good badges: CI status, version, downloads when relevant, license.
- Use badges only when they help trust, adoption, or navigation.
- When the target repository already uses shields badges, preserve its style.
- Keep badge styling consistent within the hero block.

## Docs section

- Keep a compact `Docs` section even when the repo only has a small set of links. Link to deeper docs without dumping their contents into the README; otherwise use it for lightweight project navigation.
- Common links include About, Guides, Architecture, Deployment, and Security when those docs exist.
- Order the links by reader importance, not by filesystem path or filename.
- Keep `Contributing` and `License` in their own sections unless the repo has a strong reason to group them.
- If a repo needs to expose agent-only, generated, or otherwise internal navigation such as `AGENTS.md` or `fastlane/README.md`, put those links last or move them into a separate section such as `Repo Internals`
- Keep one canonical navigation area and let other docs link to it sparingly. Keep one canonical location per workflow detail instead of mirroring the same checklist across `README.md`, `CONTRIBUTING.md`, and GitHub templates.
- Agent-facing verification commands use non-PII checks or field-filtered structured output such as an auth-source proof.

## CONTRIBUTING.md

Use this order unless the repo gives a strong reason not to:

1. Setup
2. Run locally
3. Validation
4. Development notes
5. Pull request expectations
6. Release notes only if contributors genuinely need them

- Put environment bootstrap first.
- Include only contributor-facing commands here: install toolchain, install dependencies, run locally, run checks.
- Start from [contributing template](./docs-contributing-template.md) when the repo needs a new contributor guide.
- Keep commands copy-pastable and verified against the repo.
- Document repo-specific development constraints only when they materially help contributors.
- If the repo uses `.github/pull_request_template.md` or `.github/ISSUE_TEMPLATE/*`, treat them as part of the contributor doc surface and keep the high-level expectations aligned.

## SECURITY.md

- Keep it short and private-first.
- Tell reporters not to file public issues for vulnerabilities.
- Use `devs@put.io` as the contact email.
- Start from [security template](./docs-security-template.md) when the repo needs a new security policy.
