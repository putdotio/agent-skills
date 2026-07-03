#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
tessl_cmd=("$repo_root/scripts/tessl.sh")

threshold="${TESSL_THRESHOLD:-90}"
workspace="${TESSL_WORKSPACE:-putio}"
args=()
review_mode="review"

has_threshold=false
has_json=false
has_workspace=false
for arg in "$@"; do
  if [[ "$arg" == "--threshold" ]] || [[ "$arg" == --threshold=* ]]; then
    has_threshold=true
  fi
  if [[ "$arg" == "--json" ]]; then
    has_json=true
  fi
  if [[ "$arg" == "--workspace" ]] || [[ "$arg" == -w ]] || [[ "$arg" == --workspace=* ]]; then
    has_workspace=true
  fi
done

if [[ "$has_json" == true ]]; then
  echo "batch review does not support --json; run ./scripts/tessl.sh review run --json --workspace putio skills/<group>/<name> per skill"
  exit 1
fi

if [[ "$has_threshold" == false ]]; then
  args+=(--threshold "$threshold")
fi

if [[ "$has_workspace" == false ]]; then
  args+=(--workspace "$workspace")
fi

args+=("$@")

if ! "${tessl_cmd[@]}" whoami >/dev/null 2>&1; then
  review_mode="lint"
  echo "Tessl review requires authentication; running plugin lint instead."
fi

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  if [[ "$review_mode" == "review" ]]; then
    echo "== tessl review: ${skill_dir#skills/} =="
    "${tessl_cmd[@]}" review run "${args[@]}" "$skill_dir"
  else
    echo "== tessl lint: ${skill_dir#skills/} =="
    "${tessl_cmd[@]}" plugin lint "$skill_dir"
  fi
done < <(find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort)
