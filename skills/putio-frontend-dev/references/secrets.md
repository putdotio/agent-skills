# Env setup

Use this reference when a put.io frontend-owned repo has local/dev secrets,
live-test env files, SOPS ciphertext inputs, or secret-bearing build, signing,
release, or deploy workflows. It defines the public repo-side mechanics without
requiring access to private operator docs.

**Out of scope**: repos with native non-task-runner build systems (e.g. Xcode +
Fastlane), repos that *hold* signing material consumed by tools like `match`,
and repos whose `.env`/`.env.example` carry plain device or runtime credentials
rather than shared secret references. Those follow their repo-local setup.

## Detect

```bash
rg -n 'sops|SOPS|op (run|inject|read|item|whoami|signin)|OP_SERVICE_ACCOUNT_TOKEN|op://|load-secrets-action' \
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md docs .github Makefile package.json build.gradle.kts Package.swift .env.example scripts tooling apps Tests src 2>/dev/null

test -f .env.example && cat .env.example
```

Repos with no SOPS input, CI secret boundary, or `.env.example` contract need
none of the below. Leave them alone.

If `.env.example` already exists with bare-key placeholders for non-secret or
device-local values, preserve those entries. Do not replace safe placeholders
with secret-manager references.

## Standard shape

A local-dev secret consumer carries four artifacts:

1. a generic repo-specific input such as `PUTIO_WEB_SOPS_FILE`
2. a repo-owned `secrets-setup` wrapper with exact payload validation
3. a gitignored `0600` output such as `.env.local`
4. a matching `secrets-clean` command

The maintainer supplies ciphertext outside the public repository. The wrapper
decrypts only that file, validates the exact consumer contract, and writes the
ignored output atomically. Frameworks may auto-read `.env.local`; shell flows
must load it explicitly. To avoid a materialized plaintext output, use
`sops exec-env --same-process <ciphertext> '<command>'` or a repo-owned process
wrapper that validates before launch.

Development secrets must not keep a broad password-manager fallback. Keep
personal credentials, signing material, recovery identities, and CI/CD source
copies outside the development payload.

### Tracked `.env.example`

```
PUTIO_API_KEY=
PUTIO_TEST_FIXTURE_ID=
# PUTIO_WEB_SOPS_FILE=/path/to/web.sops.env
```

Keep `.env.example` as the public variable-name contract with safe placeholders.
Do not put `op://` references or real secret-manager object names in public
templates unless the repo explicitly owns that exposure.

### `secrets-setup` / `secrets-clean` targets

The target delegates to a repo-owned wrapper. Do not embed private repository
paths, recipients, recovery locations, or provider coordinates in a public
command. After setup, normal repo commands read `.env.local` and do not decrypt
again. `secrets-clean` removes the materialized file before worktree removal.

Naming convention follows the runner: hyphen for Make / just / shell, colon for npm-style. Behaviour is identical.

```makefile
# Makefile
.PHONY: secrets-setup secrets-clean
secrets-setup:
	./scripts/secrets-setup.sh
secrets-clean:
	rm -f .env.local .env.local.* .env.local.swp
```

```json
// package.json
{ "scripts": {
  "secrets:setup": "bash ./scripts/secrets-setup.sh",
  "secrets:clean": "rm -f .env.local .env.local.* .env.local.swp"
} }
```

```just
# justfile
secrets-setup:
    ./scripts/secrets-setup.sh
secrets-clean:
    rm -f .env.local .env.local.* .env.local.swp
```

In a monorepo with per-app/package inputs, declare the target on each package so
an agent can materialize only that app's ignored output.

The wrapper must fail closed when the ciphertext is missing, unencrypted,
ambiguous, or undecryptable; when the exact key inventory or value formats are
wrong; or when the fixed output is tracked, unsafe, or not a regular file. Do
not expose a configurable output-path API or add a permanent unit-test suite for
bootstrap plumbing. When setup behavior changes, prove it with real ciphertext,
the actual consumer, mode `0600`, and cleanup; keep that evidence in the pull
request rather than the default verification gate.

### `.gitignore`

```
.env
.env.*
!.env.example
```

The `!.env.example` exception is **required**: without it, the blanket `.env.*` rule silently un-tracks the template. Verify with `git check-ignore -v .env.example` (it must report no match).

## Targets that need secrets

Default verify (`build`, `test`, `lint`, `typecheck`) runs without secrets.
Secret-bearing targets consume an already materialized file and fail with a
direct instruction to run `secrets-setup` when it is absent. Do not make normal
repository commands decrypt credentials implicitly.

For no-disk-persist flows, use a repo-owned process wrapper that validates the
payload before launch:

```bash
PUTIO_WEB_SOPS_FILE=/path/to/web.sops.env \
  ./scripts/secrets-run.sh pnpm test:live
```

Keep `secrets-setup` out of `prepare`, `postinstall`, and `prebuild` hooks.
Those run on install and would route every contributor through secret bootstrap.

## SOPS access

Each person and unattended machine uses its own age identity. The private
identity lives in owner-only machine storage with a private backup; only its
public recipient is shared with a vault operator. Never commit a private age
identity or distribute one identity across people or machines.

Public implementation repos accept a generic ciphertext file path. They do not
name the private vault, payload topology, recipients, or recovery system. If
decryption fails, report the required input or missing access instead of adding
a password-manager fallback or opening an interactive login flow.

## Verify

Use this as change-acceptance evidence for the setup boundary, not as a
permanent consumer-side unit-test suite:

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

## Public repo notes

- Build, test, lint, typecheck must pass without `.env.local`. If any depend on secrets, move the secret-dependent flow to a separate target (`live-test`, `deploy`, `release`) that documents its requirement
- `secrets-setup` is a committer-only target in public repos; routine contributors ignore it
- Document only the generic SOPS input, repo-local command, ignored output, and cleanup command
- Keep vault names, payload paths, recipients, recovery locations, and account identifiers out of public docs

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

- **Deployment Environment for every workflow mapping a sensitive secret**: continuous release environments scope secrets without approval gates; production deploy, signing, promotion, or store-submission environments may add reviewers when a human gate is intended
- **Dependabot** for the `github-actions` ecosystem so pinned action SHAs with same-line version comments get reviewable bumps. Verify each pinned SHA resolves to the comment's tag before committing it; stale upstream SHAs break Dependabot's updater
- Branch/tag trust and trusted-team direct push mechanics live in [release security](./release-security.md)

Additional hygiene:

- Optional owner-gated review on `.github/workflows/**`, `.github/actions/**`, `.env.example`, the `secrets-setup`/`secrets-clean` target body, and lockfiles when maintainers want that process
- Signed commits where repo contributors can tolerate the friction

### Setup recipe

One-time per repo:

```bash
# Create the deployment environment (idempotent)
gh api -X PUT repos/<owner>/<repo>/environments/release

# Add runtime values copied from the 1Password CI/restricted source item
gh secret set SENTRY_AUTH_TOKEN --env release --repo <owner>/<repo>
gh variable set PUTIO_RELEASE_BOT_CLIENT_ID --env release --repo <owner>/<repo>
gh secret set PUTIO_RELEASE_BOT_PRIVATE_KEY --env release --repo <owner>/<repo>

# Configure deployment-branch policy; add reviewers only for intentionally approval-gated environments
# in settings → environments → release (UI; gh api supports it but the body shape is awkward)
```

Workflow YAML for a deploy / release / live-test job:

```yaml
jobs:
  deploy:
    environment:
      name: release
      deployment: false
    runs-on: blacksmith-2vcpu-ubuntu-2404-arm
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

## Agent contexts

The same generic ciphertext input and repo-owned setup target work across local
and hosted contexts. Identity provisioning remains outside the implementation
repo.

| Context | Credential source | Setup |
|---|---|---|
| **Human local dev** | Individual age identity | Run the repo's setup target only when the task needs secrets |
| **Local laptop agent** | The machine owner's authorized age identity | Decrypt only the supplied consumer payload |
| **Shared devbox / Cloud agent** | Dedicated machine age identity | Grant only the required payload capability |

### Per-worktree onboarding

```bash
git worktree add ../<repo>.<topic> <branch>
cd ../<repo>.<topic>
<runner> secrets-setup          # when the task chain needs .env.local (or `<runner> secrets:setup` for npm-style)
<runner> secrets-clean          # before `git worktree remove` (or `<runner> secrets:clean`)
```

`.env.local` is materialised per-worktree; worktrees never share state.

### Harness ergonomics

- Render or inject only non-account test fixtures into the harness. Account
  credentials stay in the authorized secret provider and may be entered only by
  process-scoped browser automation on the official put.io login page.
- Reuse the resulting named OAuth profile or ignored local session state for
  the bounded test flow. The harness and CLI receive codes or tokens, never the
  username, password, or TOTP seed.
- Unattended runs use dedicated machine identities with only the fixture and
  browser-login capabilities they need.

### Untrusted code

The line is **"anything you did not author personally"**, not "anything from a fork." Compromised internal accounts and malicious dependencies are real vectors. Mitigations per context:

- **Local laptop**: an authorized age identity may decrypt every payload granted to that recipient; personal passwords and SSH/signing material remain separate
- **Devbox / Cloud**: an age identity or rendered `.env.local` can be exfiltrated. Run untrusted code, including internal PR code you did not author, in a separate sandbox without those capabilities
