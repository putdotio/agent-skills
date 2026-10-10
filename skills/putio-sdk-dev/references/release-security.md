# SDK release supply chain

Use this when publishing packages, signing artifacts, creating releases, or
building distributable binaries. Follow stronger target-repository policy when
it exists.

put.io SDK repositories follow the frontend release policy in the put.io Notion
workspace under Frontend / Delivery:
[Delivery model](https://app.notion.com/p/3ded546ba2f58103ae8ce55b0f7a7f9d)
for trusted refs and release identities,
[Release security](https://app.notion.com/p/3ded546ba2f581a39ec9e28f38e6d3fc)
for repository rulesets, runners, and the supply-chain incident runbook, and
[Secrets management](https://app.notion.com/p/3ded546ba2f581e19b74c6d119adb228)
for CI credentials. Verify live provider settings before a posture claim.

## SDK release mechanics

- Release from a verified `main` commit, a protected `v*` tag, or a manual ref
  validated in a secretless job. Load narrowly scoped publish or signing
  credentials from a protected GitHub Environment or OIDC only at that boundary.
- Do not use `pull_request_target` for workflows that execute repository code,
  install dependencies, build, test, package, sign, or publish.
- Prefer registry trusted publishing over long-lived tokens. For npm, use npm
  Trusted Publishing with `id-token: write` and provenance when supported.
- Pin release, publish, upload, and signing actions to full commit SHAs with an
  exact version comment so Renovate can update them.
- Install fresh with the pinned toolchain and frozen dependency contract in
  jobs that receive publish or signing credentials; do not share dependency or
  generated-tree caches between pull requests and privileged release jobs.
- Verify downloaded toolchains and binary archives before extraction or use.
- Run the repository's full verification before loading release credentials,
  then inspect the packed package or built artifact before publishing it.
- Build versioned releases from the release tag. Keep the manifest version,
  tag, package metadata, and public repository URL aligned.
- The durable handoff is the registry package or GitHub Release asset, not an
  Actions artifact. Do not rebuild a package merely to promote it; verify and
  promote the published artifact, recording the commit SHA, tag, package
  version, artifact digest, workflow run, and published artifact identity.
- Keep release and publishing behavior in the target repository's distribution
  or release documentation. Publishing and release creation remain explicit
  external actions.
