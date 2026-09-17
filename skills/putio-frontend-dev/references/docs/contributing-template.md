# Frontend `CONTRIBUTING.md` template

Adapt the commands, toolchain, and development notes to the repo. Keep the file focused on contributor setup and validation.

````md
# Contributing

Thanks for contributing to this project.

## Setup

Install the required toolchain and then install dependencies:

```bash
<install-command>
```

## Run locally

Start the project in local development mode:

```bash
<dev-command>
```

## Validation

Run the full project checks before opening or updating a pull request:

```bash
<check-command>
<test-command>
<build-command>
```

Keep only the checks contributors are expected to run.

## Development notes

- Add only repo-specific notes that help contributors.
- Explain required environment variables, local services, or architecture constraints only when they affect day-to-day development.
- Link to deeper docs if the notes get long.

## Pull requests

- Keep changes focused and explicit.
- Add or update tests when behavior changes.
- Keep this section high-level and aligned with `.github/pull_request_template.md` when the repo has one; the template holds the full review checklist.
- Include the most helpful review evidence for the kind of change you made.
  - screenshots or screen recordings for UI, layout, animation, onboarding, or copy changes, uploaded with `gh pr create --attach ./file.png` or `gh pr comment <n> --attach ./file.mp4`, never committed
  - sanity checks for risky or user-visible flows
  - before and after benchmark numbers for performance-sensitive changes
  - rollout, risk, or follow-up notes when touching auth, persistence, release flow, or external integrations
- Prefer small follow-up pull requests over mixing unrelated cleanup into feature work.
````
