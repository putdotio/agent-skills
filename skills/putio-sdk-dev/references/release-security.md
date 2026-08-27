# SDK release supply chain

Use this when publishing packages, signing artifacts, creating releases, or
building distributable binaries. Follow stronger target-repository policy when
it exists; use these defaults when it does not.

## Trusted refs and credentials

- Release from a verified `main` commit, a protected published `v*` tag, or an
  explicitly validated protected ref.
- Treat the workflow run ref and any later checkout input as separate trust
  boundaries. Validate manual ref inputs in a secretless job before a
  privileged job checks them out.
- Do not use `pull_request_target` for workflows that execute repository code,
  install dependencies, build, test, package, sign, or publish.
- Keep publish and signing credentials in a protected GitHub Environment or an
  OpenID Connect (OIDC) provider. Grant job permissions narrowly and load
  credentials only at the publish or signing boundary.
- Prefer registry trusted publishing over long-lived tokens. For npm, use npm
  Trusted Publishing with `id-token: write` and provenance when supported.

## Actions, dependencies, and caches

- Pin release, publish, upload, and signing actions to full commit SHAs with an
  exact version comment. Configure Dependabot to update pinned actions.
- Use the repository's pinned toolchain and frozen dependency contract. Keep
  release installs fresh and disable dependency caches by default in jobs that
  receive publish or signing credentials.
- Do not share dependency or generated-tree caches between pull requests and
  privileged `main`, tag, or manual release jobs.
- Verify downloaded toolchains and binary archives before extraction or use.

## Packages and handoffs

- Run the repository's full verification before loading release credentials.
  Inspect the packed package or built artifact before publishing it.
- Build versioned releases from the release tag. Keep the manifest version,
  tag, package metadata, and public repository URL aligned.
- Use the package registry, GitHub Release asset, or another immutable
  published artifact as the durable handoff. GitHub Actions artifacts are
  temporary and should normally stay within one workflow run.
- Record the commit SHA, tag, package version, artifact digest, workflow run,
  and published artifact identity when promoting or backfilling a release.
- Do not rebuild a package merely to promote it. Verify and promote the
  already-published artifact when the registry or platform supports promotion.

## Documentation and proof

- Keep release and publishing behavior in the target repository's distribution
  or release documentation.
- Report verification, package inspection, provenance, and any skipped live
  publish proof exactly. Publishing and release creation remain explicit
  external actions.
