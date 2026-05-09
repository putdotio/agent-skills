# Frontend Repo Docs Guideline

Use this when shaping top-level docs for a put.io frontend repo. Copy the structure, not the wording.
Documentation is part of the interface; optimize for scanability, rhythm, and visual clarity, not just correctness.

## Core Split

- `README.md` is user-facing.
- `CONTRIBUTING.md` is developer-facing.
- `LICENSE` states the license.
- `SECURITY.md` explains private-first vulnerability disclosure and points reporters to `devs@put.io`.

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
- For app repos, show the user-facing way to access or use the app; contributor setup belongs in `CONTRIBUTING.md`.
- Add a compact `Docs` section. When deeper docs exist, use it to link to them; otherwise use it for lightweight project navigation.
- Use human-facing labels in the README, not raw filenames or paths. Prefer labels such as `Contributing`, `Distribution`, `Architecture`, or `Agent guide` over `CONTRIBUTING.md` or `docs/DISTRIBUTION.md`.
- Add a short `Contributing` section that points to `CONTRIBUTING.md`.
- Add a short `License` section that points to `LICENSE`.
- Link to `SECURITY.md` from the README when it materially helps navigation, while keeping the main user flow clear.
- Link to deeper docs before the README turns into a handbook.

## Hero And Badges

- Use a brand block only when the repo has a real recognizable asset.
- Keep the hero compact: name, one-sentence purpose, optional positioning sentence.
- Good badges: CI status, version, downloads when relevant, license.
- Use badges only when they help trust, adoption, or navigation.
- For put.io repos that use shields badges, follow the `putio-sdk-typescript` pattern: `style=flat`, `colorA=000000`, `colorB=000000`, and `style="text-decoration:none;"` on each badge link.
- Keep badge styling consistent within the hero block.

## Docs Section

- Use this section to link to deeper docs without dumping their contents into the README.
- Keep the section even when the repo only has a small set of links.
- Common links include About, Guides, Architecture, Deployment, and Security when those docs exist.
- Order the links by reader importance, not by filesystem path or filename.
- Use the `Docs` section for reader-facing documentation links. Keep `Contributing` and `License` in their own sections unless the repo has a strong reason to group them.
- If a repo needs to expose agent-only, generated, or otherwise internal navigation such as `AGENTS.md` or `fastlane/README.md`, put those links last or move them into a separate section such as `Repo Internals`.
- Keep one canonical navigation area and let other docs link to it sparingly.
- Keep it skimmable: a short list is usually enough.
- Prefer one canonical location per workflow detail instead of mirroring the same checklist across `README.md`, `CONTRIBUTING.md`, and GitHub templates.
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
- Start from `references/contributing-template.md` when the repo needs a new contributor guide.
- Keep commands copy-pastable and verified against the repo.
- Document repo-specific development constraints only when they materially help contributors.
- If the repo uses `.github/pull_request_template.md` or `.github/ISSUE_TEMPLATE/*`, treat them as part of the contributor doc surface and keep the high-level expectations aligned.

## SECURITY.md

- Keep it short and private-first.
- Tell reporters not to file public issues for vulnerabilities.
- Use `devs@put.io` as the contact email.
- Start from `references/security-template.md` when the repo needs a new security policy.
- Link to the security policy from `README.md` when helpful.

## LICENSE

- Ensure the repo has one.
- Reference it from `README.md`.

## Checklist

- `README.md` answers what the project is, how to install it, and how to use it.
- `README.md` includes a compact `Docs` section.
- `README.md` uses human-facing doc labels instead of raw filenames or paths.
- `README.md` includes short `Contributing` and `License` sections that point to the canonical files.
- `CONTRIBUTING.md` explains how to set up an environment to contribute and how to validate changes.
- Pull request and issue templates exist when they materially improve review or triage quality.
- `SECURITY.md` uses private-first disclosure and points to `devs@put.io`.
- `LICENSE` exists and is linked where appropriate.
- User-facing docs stay focused on users.
- Contributor docs explain end-user usage only when it helps local development.
- Repeated doc references live in one canonical place instead of being copied across multiple files.
- Every command, doc path, badge target, and contact address is verified against the repo.
