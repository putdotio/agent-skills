# Distribution

This repo publishes each skill as its own public Tessl tile in the `putio` workspace.

## Tile names

Do not maintain a hardcoded list here. The source of truth is the `name` field in each `skills/*/*/tile.json`.

To inspect the current published tile names locally:

```bash
jq -r '.name' skills/*/*/tile.json
```

## How publishing works

- Each skill directory under `skills/*/*` has its own `tile.json`
- `tile.json` is the source of truth for Tessl package identity and publishing
- `agents/openai.yaml` is optional, but when present it is the source of truth for OpenAI or Codex picker-facing display names, descriptions, and default prompts
- `.github/workflows/publish-skills.yml` runs a secretless review job first, then publishes from the `release` Environment without an approval gate
- Pushes to `main` publish only the tiles that changed
- Manual workflow runs publish all tiles only when the run ref is `main`; non-`main` manual runs can review, but the publish job is skipped
- The publish job uses [`uinaf/tessl-publish-action`](https://github.com/uinaf/tessl-publish-action) to detect changed tiles, run review and lint, and publish them
- The action derives semantic version bumps from Conventional Commit messages: breaking changes -> `major`, `feat` -> `minor`, everything else -> `patch`
- Before publish, the action probes `tessl tile publish --dry-run` and keeps bumping patch versions in the job workspace until Tessl accepts a free version
- After a successful publish, the workflow commits the resulting `tile.json` version bumps back to `main` as `putio-release-bot[bot]` with a skip-CI commit message
- Publish-path actions are pinned to full commit SHAs with trailing comments for their human version tags

## Required GitHub Environment

Create a GitHub Environment named `release` for the publish job:

- Approval: none; publishing is continuous after the `main` gate passes
- Limit Environment deployment branches to `main`
- Store the Tessl publish token as the Environment secret `TESSL_TOKEN`; do not store it as a plain repository Actions secret
- Store `PUTIO_RELEASE_BOT_APP_ID` as an Environment variable and `PUTIO_RELEASE_BOT_PRIVATE_KEY` as an Environment secret
- Protect `main` so only the put.io team can update it, with force-push and branch deletion blocked where GitHub supports those controls
- `main` and `v*` release tags are restricted to trusted team/admin access plus `putio-release-bot` for release automation

Create a Tessl API key for the `putio` workspace, then add it to the `release` Environment as `TESSL_TOKEN`.

You can create the key either from the Tessl web UI or with the CLI:

```bash
tessl api-key create --workspace putio --name github-actions-publish --role publisher
```

The workflow still references the token as `${{ secrets.TESSL_TOKEN }}`; GitHub resolves that value from the `release` Environment when the `main` release job starts.

## Local checks

```bash
tessl tile lint skills/frontend/docs
tessl tile publish --dry-run skills/frontend/docs
```
