# Env Setup

Use this reference when a put.io frontend-owned repo has 1Password-backed local, live-test, build, signing, or deploy workflows. Defines the repo-side mechanics — detect, scaffold, verify — and is self-contained: external contributors and future agents can apply it without access to internal operator docs.

**Out of scope**: repos with native non-task-runner build systems (e.g. Xcode + Fastlane), repos that *hold* signing material consumed by tools like `match`, and repos whose `.env`/`.env.example` carry plain device or runtime credentials rather than 1Password references. Those follow their repo-local setup.

## Detect

```bash
rg -n 'op (run|inject|read|item|whoami|signin)|OP_SERVICE_ACCOUNT_TOKEN|op://|load-secrets-action' \
  AGENTS.md README.md CONTRIBUTING.md SECURITY.md docs .github Makefile package.json build.gradle.kts Package.swift .env.example scripts tooling apps Tests src 2>/dev/null

test -f .env.example && cat .env.example
```

Repos with no real 1Password hits and no `.env.example` need none of the below — leave them alone.

If `.env.example` already exists with bare-key placeholders for non-1Password values (e.g. local device creds), preserve those entries when migrating to `op://` references; the operator owns mixed-content templates and must approve replacement.

## Standard Shape

A secrets-using repo carries four artefacts. The `secrets-setup` target runs once per worktree to materialize `.env.local` from the operator's 1Password session — that is the only `op` invocation in the routine flow. Frameworks (Vite, Next.js) auto-read `.env.local`; shell-script flows that need secrets in-process wrap in `op run --env-file=.env.example -- <cmd>`.

### Tracked `.env.example` (literal `op://` references)

```
PUTIO_API_KEY=op://<vault>/<item>/<field>
PUTIO_TEST_USER=op://<vault>/<item>/<field>
```

Vault and item names go literally into the file. They are operational metadata, not secrets — the access control is the 1Password vault itself, not the names. The same template works for both `op inject` and `op run --env-file`.

### `secrets-setup` / `secrets-clean` targets

Body is identical across runners. `OP_ACCOUNT` is pinned **inside** the target so the recipe is hermetic across personal `op`, devbox SA token, and CI. `op whoami` pre-flight fails fast if 1Password is locked; `op inject -f` overwrites without prompting; output is mode 0600. `secrets-clean` removes the materialised `.env.local` before `git worktree remove`.

Naming convention follows the runner: hyphen for Make / just / shell, colon for npm-style. Behaviour is identical.

```makefile
# Makefile
.PHONY: secrets-setup secrets-clean
secrets-setup:
	OP_ACCOUNT=<account>.1password.com op whoami >/dev/null
	OP_ACCOUNT=<account>.1password.com op inject -f -i .env.example -o .env.local
secrets-clean:
	rm -f .env.local .env.local.* .env.local.swp
```

```json
// package.json
{ "scripts": {
  "secrets:setup": "OP_ACCOUNT=<account>.1password.com op whoami >/dev/null && OP_ACCOUNT=<account>.1password.com op inject -f -i .env.example -o .env.local",
  "secrets:clean": "rm -f .env.local .env.local.* .env.local.swp"
} }
```

```just
# justfile
secrets-setup:
    OP_ACCOUNT=<account>.1password.com op whoami >/dev/null
    OP_ACCOUNT=<account>.1password.com op inject -f -i .env.example -o .env.local
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

For no-disk-persist flows (CI live-test, heightened-security one-shots), wrap in `op run` instead:

```bash
op run --env-file=.env.example -- pnpm test:live
```

Keep `secrets-setup` out of `prepare`, `postinstall`, and `prebuild` hooks — those run on `pnpm install` and would route every contributor through the 1Password bootstrap.

## Verify

```bash
git check-ignore -v .env.local
git check-ignore -v .env.example && echo "WRONG: .env.example must be tracked" || true

op whoami --account=<account>.1password.com >/dev/null

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
- If an item title would reveal something better kept internal, rename it in 1Password rather than obscuring the `op://` reference

## CI/CD

Mandatory shape against PR-driven exfiltration and supply-chain attacks.

### Trigger discipline

- **PR verify on `pull_request`** MUST NOT map `OP_SERVICE_ACCOUNT_TOKEN` (or any sensitive secret) into any job. `pull_request` from internal branches DOES receive `secrets.*` when referenced; the gate is "workflow author never wires it in"
- **Continuous release on `push: main`** references Environment-scoped secrets without reviewer gates. `workflow_dispatch` is only allowed when the Environment's deployment-branch policy restricts the runnable ref to `main` or protected release branches, and the job does not separately check out an arbitrary input ref
- **Secret-bearing manual flows** validate any requested tag/ref in a secretless job first, then check it out with `actions/checkout` `with.ref` only after validation. Environment branch/tag policy protects the workflow run ref, not a later `inputs.ref` checkout
- **Never `pull_request_target` for code-running steps** (checkout PR head, label automation with checkout, composite actions running PR-supplied scripts)
- **Never `workflow_run` triggered by a `pull_request` workflow that reads PR data** — classic exfiltration vector
- Pin reusable workflows to SHA and CODEOWNER-gate

### Where secrets live

- The 1Password service-account token lives ONLY in a GitHub Deployment Environment — never as a repo Actions secret
- Continuous release Environment approval is none; approval-gated production deploy, signing, promotion, or store-submission environments document reviewers explicitly

### Workflow defaults

- Top-level `permissions: {}` (deny by default); each job opts into the minimum it needs
- Third-party actions pinned to SHA
- 1Password-backed loading uses `1Password/load-secrets-action@<sha>` reading `OP_ENV_FILE=.env.example`
- `workflow_dispatch` inputs pass through `env`, are validated and bounded before shell use, and are never interpolated directly inside `run:` scripts

### Repo configuration

Load-bearing:

- **Deployment Environment for every workflow mapping a sensitive secret** — continuous release environments scope secrets without approval gates; production deploy, signing, promotion, or store-submission environments may add reviewers when a human gate is intended
- **Dependabot** for the `github-actions` ecosystem so pinned SHAs get reviewable bumps
- Branch/tag trust and trusted-team direct push mechanics live in [release-security.md](release-security.md)

Additional hygiene:

- CODEOWNERS on `.github/workflows/**`, `.github/actions/**`, `.env.example`, the `secrets-setup`/`secrets-clean` target body, and lockfiles
- Signed commits where repo contributors can tolerate the friction

### Setup recipe

One-time per repo:

```bash
# Create the Deployment Environment (idempotent)
gh api -X PUT repos/<owner>/<repo>/environments/release

# Add the SA token as an Environment secret
gh secret set OP_SERVICE_ACCOUNT_TOKEN --env release --repo <owner>/<repo>

# Configure deployment-branch policy; add reviewers only for intentionally approval-gated environments
# in Settings → Environments → release (UI; gh api supports it but the body shape is awkward)
```

Workflow YAML for a deploy / release / live-test job:

```yaml
jobs:
  deploy:
    environment: release
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@<sha>
      - uses: 1Password/load-secrets-action@<sha>
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          OP_ENV_FILE: .env.example
      - run: pnpm deploy
```

Migrating an existing repo Actions secret to the Environment: add the secret to the Environment first, switch the workflow's job to declare `environment:`, then delete the repo-level secret.

### Cache scoping

Cache keys include `${{ github.event_name }}` so PR (no-secrets) jobs cannot poison caches consumed by `push: main` (with-secrets) jobs.

Generated dependency trees such as full CocoaPods `Pods` directories are not restored into signed or release jobs across trust boundaries. Cache download artifacts instead, or namespace generated-tree caches by workflow/trust level and regenerate or verify before signing.

## Agent Contexts

The same `op` calls and the same `secrets-setup` target work in all three contexts.

| Context | Credential source | Setup |
|---|---|---|
| **Local laptop** | Unlocked 1Password CLI session via desktop integration | Desktop integration on, biometric unlock, finite auto-lock, app unlocked at session start |
| **Shared devbox** | `OP_SERVICE_ACCOUNT_TOKEN` exported into the shared user's shell. Practical path: `/etc/<org>/op.env` (mode `0600`, sourced from `/etc/profile.d/<org>-op.sh` or `~/.zshenv`) | Operator pre-installs. Verify with `ssh user@host 'env \| grep OP_SERVICE_ACCOUNT_TOKEN'` |
| **Cloud agent** (Codex Cloud, Claude Code Cloud) | `OP_SERVICE_ACCOUNT_TOKEN` configured as a workspace secret | One-time setup per workspace |

### Per-worktree onboarding

```bash
git worktree add ../<repo>.<topic> <branch>
cd ../<repo>.<topic>
<runner> secrets-setup          # when the task chain needs .env.local (or `<runner> secrets:setup` for npm-style)
<runner> secrets-clean          # before `git worktree remove` (or `<runner> secrets:clean`)
```

`.env.local` is materialised per-worktree; worktrees never share state.

### Harness ergonomics

- 1Password launches on login with biometric unlock so the CLI session is alive at session start
- Unattended runs (overnight, scheduled) use a devbox or Cloud agent so the SA token is always present

### Untrusted code

The line is **"anything you did not author personally"**, not "anything from a fork." Compromised internal accounts and malicious dependencies are real vectors. Mitigations per context:

- **Local laptop**: vault-scope discipline + per-item auth on sensitive items + auto-lock window
- **Devbox / Cloud**: SA token sits in env; malicious code can exfiltrate it. Run untrusted code (including internal-PR code from someone you don't personally trust) in a separate sandbox
