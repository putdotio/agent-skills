# Frontend repo docs guideline

Use this when shaping top-level docs for a put.io frontend repo. Copy the structure, not the wording.

## Core split

- `README.md` is user-facing: what the project is, how to install it, how to use it.
- `CONTRIBUTING.md` is developer-facing: environment setup, local run, checks.
- `LICENSE` states the license; reference it from `README.md`.
- Security reporting follows the [org-wide security policy](https://github.com/putdotio/.github/blob/main/SECURITY.md). Add a repo `SECURITY.md` only when its policy genuinely differs.

## README.md

Use this order unless the repo gives a strong reason not to:

1. Hero
2. Install
3. Quick usage or first successful flow
4. Optional examples, variants, or integration notes
5. Docs
6. Contributing
7. Security
8. License

- Answer on the first screen: what is this project, how do I install it, and how do I use it.
- For package repos, show install commands and one short usage example.
- For app repos, show the user-facing way to access or use the app; contributor setup belongs in `CONTRIBUTING.md`.
- Use human-facing labels, not raw filenames or paths: `Contributing`, `Distribution`, `Architecture`, or `Agent guide` over `CONTRIBUTING.md` or `docs/DISTRIBUTION.md`.
- Add short `Contributing` and `License` sections that point to `CONTRIBUTING.md` and `LICENSE`.
- Add a short `Security` section that links the [org-wide security policy](https://github.com/putdotio/.github/blob/main/SECURITY.md), or the repo `SECURITY.md` when one exists.

## Hero and badges

- Use a brand block only when the repo has a recognizable asset.
- Match an existing hero or badge pattern in the target repository. If none
  exists, keep the README text-first.
- Link an asset the target repository already owns or references. Do not
  copy shared brand files into it.
- Keep the hero compact: name, one-sentence purpose, optional positioning sentence.
- Good badges: CI status, version, downloads when relevant, license. Use them only when they help trust, adoption, or navigation.
- When the target repository already uses shields badges, preserve its style, consistently within the hero block.

## Docs section

- Keep a compact `Docs` section even when the repo has few links. Link deeper docs instead of copying their contents into the README.
- Common links: About, Guides, Architecture, Deployment, and Security when those docs exist.
- Order links by reader importance, not by filesystem path or filename.
- Keep `Contributing` and `License` in their own sections unless the repo has a strong reason to group them.
- Put agent-only, generated, or internal navigation such as `AGENTS.md` or `fastlane/README.md` last, or in a separate section such as `Repo Internals`.
- Keep one canonical navigation area; other docs link to it sparingly. Keep one canonical location per workflow detail instead of mirroring the same checklist across `README.md`, `CONTRIBUTING.md`, and GitHub templates.
- Agent-facing verification commands use non-PII checks or field-filtered structured output such as an auth-source proof.

## CONTRIBUTING.md

Use this order unless the repo gives a strong reason not to:

1. Setup
2. Run locally
3. Validation
4. Development notes
5. Pull request expectations
6. Release notes only when contributors need them

- Include only contributor-facing commands: install toolchain, install dependencies, run locally, run checks.
- Keep commands copy-pastable and verified against the repo.
- Document repo-specific development constraints only when they help contributors.
- If the repo uses `.github/pull_request_template.md` or `.github/ISSUE_TEMPLATE/*`, treat them as part of the contributor doc surface and keep the high-level expectations aligned.
