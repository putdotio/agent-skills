The user says:

"Fix an empty-list keyboard focus regression in our put.io web app. Keep the
existing task graph and finish with evidence we can review."

This is a synthetic repository. Its documented policy says:

- `pnpm verify:web` checks the web app and affected shared dependencies
- `pnpm verify:tv` checks the separate TV app
- `pnpm verify` checks both apps and is mandatory when the root lockfile or
  shared build configuration changes, or when the affected graph is uncertain
- `pnpm test:package` installs the shared UI package tarball into a fresh
  consumer; it stays separate from the default gate
- The shared UI package has web and TV consumers
- Browser focus, empty/error/recovery and keyboard proof accompanies web
  interaction changes; TV remote behavior requires the established device lane

The fix changes only the web app. `pnpm verify:web` and the affected browser
flow passed on the current source and unchanged environment. No shared inputs
changed. You reach another conversation turn and prepare the completed handoff.

Explain what to run or reuse, and what evidence to report. Then explain how
your answer changes if (a) the fix instead changes shared UI keyboard behavior,
or (b) the root lockfile changes after the checks passed. The TV device is
unavailable, and no live account writes, deploys or paid evaluations are
authorized. Do not execute commands for this scenario.
