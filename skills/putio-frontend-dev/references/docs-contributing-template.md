# Frontend `CONTRIBUTING.md` Template

Use this as a starting point for frontend repos. Adapt the commands, toolchain, and development notes to the repo, but keep the file focused on contributor setup and validation.

````md
# Contributing

Thanks for contributing to this project.

## Setup

Install the required toolchain and then install dependencies:

```bash
<install-command>
```

## Run Locally

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

Add or remove commands based on the repo. Keep only the checks contributors are actually expected to run.

## Development Notes

- Add only repo-specific notes that materially help contributors.
- Explain required environment variables, local services, or architecture constraints only when they affect day-to-day development.
- Link to deeper docs if the notes start getting long.

## Pull Requests

- Keep changes focused and explicit.
- Add or update tests when behavior changes.
- Keep this section high-level. Put the full review checklist in `.github/pull_request_template.md` when the repo has one.
- Include the most helpful review evidence for the kind of change you made.
  - screenshots or screen recordings for UI, layout, animation, onboarding, or copy changes
  - sanity checks for risky or user-visible flows
  - before and after benchmark numbers for performance-sensitive changes
  - rollout, risk, or follow-up notes when touching auth, persistence, release flow, or external integrations
- Prefer small follow-up pull requests over mixing unrelated cleanup into feature work.
- Keep this section aligned with `.github/pull_request_template.md` when the repo has one.
````
