# Skill fleet

## Inventory

| Owner repository | Skill |
| --- | --- |
| `putdotio/agent-skills` | `putio-frontend-dev` |
| `putdotio/agent-skills` | `putio-sdk-dev` |
| `putdotio/putio-cli` | `putio-cli` |

The owner repository is the only edit target. Consumers re-sync instead of
editing installed copies.

## Cadence

- Pull requests and `main` pushes run the owner repository's verify gate.
- This catalog repeats skill lint monthly.
- Eval sweeps need model credentials and remain operator-run.
