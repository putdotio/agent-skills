# Distribution

This repo publishes each skill as its own public Tessl plugin in the `putio` workspace.

## Plugin names

Do not maintain a hardcoded list here. The source of truth is the `name` field in each `skills/*/*/.tessl-plugin/plugin.json`.

To inspect the current published plugin names locally:

```bash
find skills -path '*/.tessl-plugin/plugin.json' -exec jq -r .name {} \;
```

## How publishing works

- Each skill directory under `skills/*/*` has its own `.tessl-plugin/plugin.json`
- `.tessl-plugin/plugin.json` is the source of truth for Tessl package identity and publishing
- `agents/openai.yaml` is optional, but when present it is the source of truth for OpenAI or Codex picker-facing display names, descriptions, and default prompts
- `scripts/tessl.sh` owns the audited local Tessl CLI pin; the `setup-tessl` workflow steps pin the same version
- `.github/workflows/review-skills.yml` runs secretless plugin lint on pull requests and authenticated Tessl Review on trusted `main` pushes
- `.github/workflows/publish-skills.yml` runs authenticated Tessl Review first, then publishes from the `release` Environment without an approval gate
- Pushes to `main` that touch `skills/**`, `scripts/publish-skills.sh`, or the publish workflow publish only the plugins that changed
- Pushes with `[skip ci]` in the head commit message skip review and publish jobs
- Manual workflow runs publish all plugins only when the run ref is `main`; non-`main` manual runs can review, but the publish job is skipped
- The publish job uses `scripts/publish-skills.sh` to detect changed plugins, lint them, and publish them with the Tessl CLI
- `tessl plugin publish` publishes eval scenarios from each plugin's `evals/` directory
- [Evals](./EVALS.md) describes scenario layout, local eval commands, and registry Impact triage
- The script derives semantic version bumps from Conventional Commit messages: breaking changes -> `major`, `feat` -> `minor`, everything else -> `patch`
- Before publish, the script probes `tessl plugin publish --dry-run --bump <type>` so Tessl can choose the next available version
- After a successful publish, the workflow commits the resulting `.tessl-plugin/plugin.json` version bumps back to `main` as `putio-release-bot[bot]` with a skip-CI commit message
- Publish-path actions are pinned to full commit SHAs with trailing comments for their human version tags

## Required GitHub Environment

Create a GitHub Environment named `release` for the publish job:

- Approval: none; publishing is continuous after the `main` gate passes
- Limit Environment deployment branches to `main`
- Store the Tessl publish token as the Environment secret `TESSL_TOKEN`; do not store it as a plain repository Actions secret
- Store `PUTIO_RELEASE_BOT_CLIENT_ID` as an Environment variable and `PUTIO_RELEASE_BOT_PRIVATE_KEY` as an Environment secret
- Protect `main` so only the put.io team can update it, with force-push and branch deletion blocked where GitHub supports those controls
- `main` and `v*` release tags are restricted to trusted team/admin access plus `putio-release-bot` for release automation

Create a Tessl API key for the `putio` workspace, then add it to the `release` Environment as `TESSL_TOKEN`.

You can create the key either from the Tessl web UI or with the CLI:

```bash
expiry_date="YYYY-MM-DDT00:00:00Z"
./scripts/tessl.sh api-key create \
  --workspace putio \
  --name github-actions-publish-release-YYYYMMDDHHMMSS \
  --role publisher \
  --expiry-date "$expiry_date"
```

The workflow still references the token as `${{ secrets.TESSL_TOKEN }}`; GitHub resolves that value from the `release` Environment when the `main` release job starts.

## Rotate the Tessl publisher key

Create the replacement key before revoking the current key. Keep the generated
value out of shell history, files, logs, and chat.

1. Create a replacement publisher key with an explicit expiry using the command
   above.
2. Set the replacement value interactively. GitHub CLI encrypts it locally
   before sending it:

   ```bash
   gh secret set TESSL_TOKEN --repo putdotio/skills --env release
   ```

3. Push a trusted `main` change that exercises both review and publish setup,
   then confirm the jobs succeed:

   ```bash
   gh run list --repo putdotio/skills --limit 10
   ```

4. List Tessl key metadata and delete only the superseded key after the
   replacement has succeeded in CI:

   ```bash
   ./scripts/tessl.sh api-key list --workspace putio
   ./scripts/tessl.sh api-key delete --workspace putio <superseded-api-key-id>
   ```

If the workflow fails authentication, keep the previous key active while
repairing the Environment secret.

## Local checks

```bash
./scripts/tessl.sh plugin lint skills/frontend/frontend-dev
./scripts/tessl.sh plugin publish --dry-run skills/frontend/frontend-dev
./scripts/tessl.sh plugin publish --dry-run --bump patch skills/frontend/frontend-dev
```
