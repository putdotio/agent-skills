# Environment setup

One machine layout for put.io frontend work on macOS or Linux. Runtimes come
from [mise](https://mise.jdx.dev), installed and activated in the shell first.
Repositories that need Node, pnpm, or platform toolchains pin them in their own
mise config or version files, so nothing here installs them.

## Tools

```bash
mise use -g gh jq age sops actionlint github:putdotio/putio-cli
```

- `gh`: signed in with the put.io GitHub account; PR media uploads use the
  same login
- `age` and `sops`: decrypt the local secrets vault, see
  [secrets](./delivery/secrets.md)
- `actionlint`: workflow checks in the verify gates
- `putio`: the put.io CLI used by test harnesses, see
  [CLI harness contract](./test-harness/cli.md)
- Apple targets need Xcode on macOS; Android targets need Android Studio

## Repositories

Point `registry` at this skill's installed `repos.json`, then clone every
registered repository into its canonical path:

```bash
registry=<skill-dir>/repos.json
jq -r '.[][] | "\(.repo) \(.path)"' "$registry" \
  | while read -r repo checkout; do
      target="${checkout/#\~/$HOME}"
      [ -d "$target/.git" ] || gh repo clone "$repo" "$target"
    done
```

Private entries clone only for members of the GitHub organization.

## Clones and worktrees

Agent worktrees live in the coding harness's own worktree folder, outside the
canonical checkouts. Run `mise trust` inside every new clone or worktree that
carries a mise config before running its commands.

## Check

```bash
registry=<skill-dir>/repos.json
mise doctor
for tool in gh jq age sops actionlint putio; do command -v "$tool" >/dev/null || echo "missing: $tool"; done
gh auth status
jq -r '.[][] | .path' "$registry" \
  | while read -r checkout; do [ -d "${checkout/#\~/$HOME}/.git" ] || echo "missing checkout: $checkout"; done
```

The machine is ready when the check prints no `missing` lines and
`gh auth status` shows the put.io account logged in. Secrets are verified
separately in the vault repository.
