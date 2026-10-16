# Skill fleet

## Inventory

| Owner repository        | Skill                |
| ----------------------- | -------------------- |
| `putdotio/putio-dev-agent-plugin` | `putio-frontend-dev` |
| `putdotio/putio-dev-agent-plugin` | `putio-sdk-dev`      |
| `putdotio/putio-cli`    | `putio-cli`          |

The owner repository is the only edit target. Consumers re-sync instead of
editing installed copies.

## Cadence

- Pull requests and `main` pushes run the owner repository's verify gate.
- Eval sweeps need model credentials and remain operator-run.
