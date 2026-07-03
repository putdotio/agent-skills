# Env Setup

Use this reference when a put.io frontend-owned repo has local/dev secrets,
live-test env files, Infisical, or secret-bearing build, signing, release, or
deploy workflows. Defines the repo-side mechanics — detect, scaffold, verify —
and is self-contained: external contributors and future agents can apply it
without access to internal operator docs.

**Out of scope**: repos with native non-task-runner build systems (e.g. Xcode +
Fastlane), repos that *hold* signing material consumed by tools like `match`,
and repos whose `.env`/`.env.example` carry plain device or runtime credentials
rather than shared secret references. Those follow their repo-local setup.

## Detect

```bash
rg -n 'infisical|INFISICAL|op (run|inject|read|item|whoami|signin)|OP_SERVICE_ACCOUNT_TOKEN|op://|load-secrets-action' \
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md docs .github Makefile package.json build.gradle.kts Package.swift .env.example scripts tooling apps Tests src 2>/dev/null

test -f .env.example && cat .env.example
```

Repos with no real Infisical, CI secret-manager, or `.env.example` hits need
none of the below — leave them alone.

If `.env.example` already exists with bare-key placeholders for non-secret or
device-local values, preserve those entries. Do not replace safe placeholders
with secret-manager references.

## Standard Shape

A local-dev secrets repo carries four artifacts. The `secrets-setup` target runs
once per worktree to materialize `.env.local` from a specific Infisical path.
Frameworks (Vite, Next.js) auto-read `.env.local`; shell-script flows should
read `.env.local` too. Reserve `infisical run` for no-disk-persist one-shots.
Development secrets should not keep a 1Password fallback. If a dev/live-test
value still depends on `op`, migrate a limited dev/test version into Infisical
and delete the old local-dev 1Password copy after verification.

Infisical paths are for development and testing only. They must never contain
admin accounts, production-wide credentials, personal accounts, signing keys,
recovery keys, or CI/CD deploy/publish secrets.

### Tracked `.env.example`

```
PUTIO_API_KEY=
PUTIO_TEST_USER=
```

Keep `.env.example` as the public variable-name contract with safe placeholders.
Do not put `op://` references or real secret-manager object names in public
templates unless the repo explicitly owns that exposure.

### `secrets-setup` / `secrets-clean` targets

The target exports from one approved Infisical path, writes `.env.local`, and
sets mode `0600`. After setup, repo commands read `.env.local` and do not keep
calling the secret manager. `secrets-clean` removes the materialized
`.env.local` before `git worktree remove`.

Naming convention follows the runner: hyphen for Make / just / shell, colon for npm-style. Behaviour is identical.

```makefile
# Makefile
.PHONY: secrets-setup secrets-clean
secrets-setup:
	infisical export --domain https://eu.infisical.com/api --projectId <project-id> --env dev --path /<repo-or-flow> --format dotenv --output-file .env.local
	chmod 600 .env.local
secrets-clean:
	rm -f .env.local .env.local.* .env.local.swp
```

```json
// package.json
{ "scripts": {
  "secrets:setup": "infisical export --domain https://eu.infisical.com/api --projectId <project-id> --env dev --path /<repo-or-flow> --format dotenv --output-file .env.local && chmod 600 .env.local",
  "secrets:clean": "rm -f .env.local .env.local.* .env.local.swp"
} }
```

```just
# justfile
secrets-setup:
    infisical export --domain https://eu.infisical.com/api --projectId <project-id> --env dev --path /<repo-or-flow> --format dotenv --output-file .env.local
    chmod 600 .env.local
secrets-clean:
    rm -f .env.local .env.local.* .env.local.swp
```

In a monorepo with per-app/package `.env.example` files, declare the target on each package (e.g. `apps/<app>/package.json`'s `secrets:setup`) so an agent can run `pnpm --filter @org/<app> secrets:setup` and materialise that one app's `.env.local`.

### `.gitignore`

```
.env
.env.*
!.env.example
```

The `!.env.example` exception is **required** — without it, the blanket `.env.*` rule silently un-tracks the template. Verify with `git check-ignore -v .env.example` (it must report no match).

## Targets That Need Secrets

Default verify (`build`, `test`, `lint`, `typecheck`) runs without secrets. Targets that need them declare `secrets-setup` as a task dependency:

```makefile
live-test: secrets-setup
	pnpm test:live
```

For no-disk-persist local/dev flows, wrap the command in `infisical run` instead:

```bash
infisical run --domain https://eu.infisical.com/api --projectId <project-id> --env dev --path /<repo-or-flow> -- pnpm test:live
```

Keep `secrets-setup` out of `prepare`, `postinstall`, and `prebuild` hooks —
those run on install and would route every contributor through secret bootstrap.

## Infisical Auth

Keep Infisical auth outside implementation repos:

- **Workspace onboarding**: grant access to the Infisical `frontend` project and Development environment during setup
- **Human local dev**: run `infisical login` once. The CLI stores its own local auth
- **Local laptop agents**: use the user's approved Infisical CLI session only for dev-approved paths, or use a narrow machine identity when unattended access is required
- **Shared devboxes / Cloud agents**: use a narrow Infisical machine identity scoped to local/dev paths

Repos never commit, generate, or read Infisical machine-identity bootstrap
credentials. They only export approved paths into ignored `.env.local` files.
Infisical contents must be limited dev/test accounts, tokens, and fixtures that
are safe for local agents to use.

If login succeeds but a repo path cannot be exported, treat it as missing
onboarding or path permission. Ask a workspace maintainer to grant the needed
Infisical access instead of adding a 1Password fallback.

## Verify

```bash
git check-ignore -v .env.local
git check-ignore -v .env.example && echo "WRONG: .env.example must be tracked" || true

<repo's secrets-setup target>
test -f .env.local
mode=$(stat -f '%Mp%Lp' .env.local 2>/dev/null || stat -c '%a' .env.local)
test "$mode" = "600" && echo mode ok || echo "WRONG: mode=$mode"
grep -q 'op://' .env.local && echo "WRONG: unresolved op:// in .env.local" || echo refs ok

<repo's secrets-clean target>
test ! -f .env.local && echo cleanup ok
```

## Public Repo Notes

- Build, test, lint, typecheck must pass without `.env.local`. If any depend on secrets, move the secret-dependent flow to a separate target (`live-test`, `deploy`, `release`) that documents its requirement
- `secrets-setup` is a committer-only target in public repos; routine contributors ignore it
- Keep secret-manager object names out of public docs when they reveal internal workflow details; document variable names and the repo-local command instead

## CI/CD

Mandatory shape against PR-driven exfiltration and supply-chain attacks.

### Trigger discipline

- **PR verify on `pull_request`** runs without sensitive secrets. `pull_request` from internal branches DOES receive `secrets.*` when referenced; the gate is "workflow author leaves it unwired"
- **Continuous release on `push: main`** references Environment-scoped secrets without reviewer gates. `workflow_dispatch` is only allowed when the Environment's deployment-branch policy restricts the runnable ref to `main` or protected release branches, and the job does not separately check out an arbitrary input ref
- **Secret-bearing manual flows** validate any requested tag/ref in a secretless job first, then check it out with `actions/checkout` `with.ref` only after validation. Environment branch/tag policy protects the workflow run ref, not a later `inputs.ref` checkout
- **Use `pull_request` for code-running steps** such as checkout PR head, label automation with checkout, or composite actions running PR-supplied scripts
- **Use direct trusted triggers for secret-bearing follow-ups** rather than `workflow_run` triggered by a `pull_request` workflow that reads PR data
- Pin reusable workflows to SHA and use owner-gated review only when the repo intentionally carries that process

### Where secrets live

- Important CI/CD source values live in 1Password CI or restricted owner vaults for human administration and rotation
- Workflow runtime values live as GitHub Environment secrets, npm/GitHub trusted-publishing configuration, or OIDC-backed provider configuration
- CI must not call `op`, `1Password/load-secrets-action`, or use `OP_SERVICE_ACCOUNT_TOKEN` to fetch secrets at runtime
- Continuous release Environment approval is none; approval-gated production deploy, signing, promotion, or store-submission environments document reviewers explicitly
- Package/library/CLI/skill publish jobs use the Environment as a secret boundary with `deployment: false`; app deploy, signing, promotion, and store-submission jobs keep deployment records when those records are useful

### Workflow defaults

- Top-level `permissions: {}` (deny by default); each job opts into the minimum it needs
- Third-party actions pinned to SHA
- Secret-bearing jobs read GitHub Environment secrets directly or assume provider roles through OIDC
- `workflow_dispatch` inputs pass through `env`, are validated and bounded before shell use, then flow through sanitized step outputs

### Repo configuration

Load-bearing:

- **Deployment Environment for every workflow mapping a sensitive secret** — continuous release environments scope secrets without approval gates; production deploy, signing, promotion, or store-submission environments may add reviewers when a human gate is intended
- **Dependabot** for the `github-actions` ecosystem so pinned action SHAs with same-line version comments get reviewable bumps. Verify each pinned SHA resolves to the comment's tag before committing it; stale upstream SHAs break Dependabot's updater
- Branch/tag trust and trusted-team direct push mechanics live in [release security](./release-security.md)

Additional hygiene:

- Optional owner-gated review on `.github/workflows/**`, `.github/actions/**`, `.env.example`, the `secrets-setup`/`secrets-clean` target body, and lockfiles when maintainers want that process
- Signed commits where repo contributors can tolerate the friction

### Setup recipe

One-time per repo:

```bash
# Create the Deployment Environment (idempotent)
gh api -X PUT repos/<owner>/<repo>/environments/release

# Add runtime values copied from the 1Password CI/restricted source item
gh secret set SENTRY_AUTH_TOKEN --env release --repo <owner>/<repo>
gh variable set PUTIO_RELEASE_BOT_CLIENT_ID --env release --repo <owner>/<repo>
gh secret set PUTIO_RELEASE_BOT_PRIVATE_KEY --env release --repo <owner>/<repo>

# Configure deployment-branch policy; add reviewers only for intentionally approval-gated environments
# in Settings → Environments → release (UI; gh api supports it but the body shape is awkward)
```

Workflow YAML for a deploy / release / live-test job:

```yaml
jobs:
  deploy:
    environment:
      name: release
      deployment: false
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<sha>
      - run: pnpm deploy
        env:
          SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
      - id: release-bot
        uses: actions/create-github-app-token@<sha>
        with:
          client-id: ${{ vars.PUTIO_RELEASE_BOT_CLIENT_ID }}
          private-key: ${{ secrets.PUTIO_RELEASE_BOT_PRIVATE_KEY }}
          permission-contents: write
      - run: pnpm release:write
        env:
          GH_TOKEN: ${{ steps.release-bot.outputs.token }}
```

Keep `PUTIO_RELEASE_BOT_PRIVATE_KEY` out of broad repo-owned commands such as
install, build, test, and deploy preparation. Pass it only to the token-minting
action, then pass the resulting short-lived token to the narrow final write step.

Use `deployment: false` for package/library/CLI/skill release jobs whose Environment exists only to scope secrets. Keep deployment records for app deploys, signing, promotion, store submission, and any Environment with custom deployment protection rules.

Migrating an existing CI/CD secret workflow: copy the exact runtime values from
the CI/restricted 1Password item into the GitHub Environment first, switch the
workflow's job to declare `environment:`, remove `op`/1Password runtime loading,
then delete any repo-level or service-account secret.

### Cache scoping

Cache keys include `${{ github.event_name }}` so PR (no-secrets) jobs cannot poison caches consumed by `push: main` (with-secrets) jobs.

Generated dependency trees such as full CocoaPods `Pods` directories are not restored into signed or release jobs across trust boundaries. Cache download artifacts instead, or namespace generated-tree caches by workflow/trust level and regenerate or verify before signing.

## Agent Contexts

The same Infisical path and the same `secrets-setup` target work across local
and hosted agent contexts.

| Context | Credential source | Setup |
|---|---|---|
| **Human local dev** | `infisical login` browser-backed CLI auth | Run the repo's `secrets-setup` target when a task needs `.env.local` |
| **Local laptop agent** | Approved local Infisical CLI auth, or a narrow machine identity when unattended access is required | Export only the repo path needed for the task |
| **Shared devbox / Cloud agent** | Narrow Infisical machine identity scoped to local/dev paths | One-time setup per workspace or devbox |

### Per-worktree onboarding

```bash
git worktree add ../<repo>.<topic> <branch>
cd ../<repo>.<topic>
<runner> secrets-setup          # when the task chain needs .env.local (or `<runner> secrets:setup` for npm-style)
<runner> secrets-clean          # before `git worktree remove` (or `<runner> secrets:clean`)
```

`.env.local` is materialised per-worktree; worktrees never share state.

### Harness ergonomics

- Humans run `infisical login` once instead of approving repeated secret reads
- Unattended runs use a devbox or Cloud agent with a narrow machine identity

### Untrusted code

The line is **"anything you did not author personally"**, not "anything from a fork." Compromised internal accounts and malicious dependencies are real vectors. Mitigations per context:

- **Local laptop**: Infisical project/path scope for dev secrets; 1Password stays for personal passwords and SSH/signing material
- **Devbox / Cloud**: machine identity or rendered `.env.local` material can be exfiltrated. Run untrusted code (including internal-PR code from someone you don't personally trust) in a separate sandbox
