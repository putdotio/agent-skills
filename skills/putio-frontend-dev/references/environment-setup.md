# Environment setup

One machine layout for put.io frontend work on macOS or Linux. Runtimes come
from [mise](https://mise.jdx.dev); each repository pins its own Node, pnpm,
and platform toolchains in its mise config, so nothing here installs them.

## Tools

```bash
mise use -g gh jq age sops actionlint 'ubi:putdotio/putio-cli[exe=putio]'
```

- `gh`: signed in with the put.io GitHub account; PR media uploads use the
  same login
- `age` and `sops`: decrypt the local secrets vault, see
  [secrets](./delivery/secrets.md)
- `actionlint`: workflow checks in the verify gates
- `putio`: the put.io CLI used by test harnesses, see
  [CLI harness contract](../test-harness/cli.md)
- Apple targets need Xcode on macOS; Android targets need Android Studio

## Repositories

Clone every registered repository into its canonical path:

```bash
jq -r '.[][] | "\(.repo) \(.path)"' ~/.agents/skills/putio-frontend-dev/repos.json \
  | while read -r repo path; do
      target="${path/#\~/$HOME}"
      [ -d "$target/.git" ] || gh repo clone "$repo" "$target"
    done
```

The path is the skill's global install location; adjust it for a project-local
install. Private entries clone only for members of the GitHub organization.

## Agent worktrees

Coding agents create worktrees under `~/.claude/worktrees` or
`~/.codex/worktrees`. Each carries the repository's mise config; run
`mise trust` inside a new worktree before its commands work.

## Check

```bash
mise doctor
for tool in gh jq age sops actionlint putio; do command -v "$tool" >/dev/null || echo "missing: $tool"; done
gh auth status
jq -r '.[][] | .path' ~/.agents/skills/putio-frontend-dev/repos.json \
  | while read -r path; do [ -d "${path/#\~/$HOME}/.git" ] || echo "missing checkout: $path"; done
```

Silence after `gh auth status` means the machine is ready. Secrets are
verified separately in the vault repository.
