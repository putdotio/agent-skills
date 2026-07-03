#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

event_name="${GITHUB_EVENT_NAME:-manual}"
before_sha="${PUBLISH_BEFORE_SHA:-${GITHUB_EVENT_BEFORE:-}}"
after_sha="${PUBLISH_AFTER_SHA:-${GITHUB_SHA:-HEAD}}"
zero_sha="0000000000000000000000000000000000000000"
dry_run="${PUBLISH_DRY_RUN:-}"

if [[ -z "$dry_run" ]]; then
  if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
    dry_run="false"
  else
    dry_run="true"
  fi
fi

find_tile_dir() {
  local changed_path="$1"
  local current

  if [[ -d "$changed_path" ]]; then
    current="$changed_path"
  else
    current="$(dirname "$changed_path")"
  fi

  while [[ "$current" == skills* && "$current" != "." ]]; do
    if [[ -f "$current/tile.json" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done

  return 1
}

list_all_tiles() {
  find skills -mindepth 2 -maxdepth 3 -name tile.json -print \
    | sed 's#/tile.json$##' \
    | sort -u
}

list_changed_tiles() {
  if [[ -z "$before_sha" || "$before_sha" == "$zero_sha" ]]; then
    list_all_tiles
    return 0
  fi

  if ! git cat-file -e "${before_sha}^{commit}" 2>/dev/null; then
    git fetch --no-tags origin "$before_sha"
  fi

  git diff --name-only "$before_sha" "$after_sha" -- skills \
    | while IFS= read -r changed_path; do
      find_tile_dir "$changed_path" || true
    done \
    | sort -u
}

publish_bump_type() {
  local range
  local messages

  if [[ -z "$before_sha" || "$before_sha" == "$zero_sha" ]]; then
    echo "patch"
    return 0
  fi

  range="${before_sha}..${after_sha}"
  messages="$(git log --format=%B "$range")"

  if grep -Eq '(^|\n)BREAKING[- ]CHANGE:|^[a-z]+(\([^)]+\))?!:' <<<"$messages"; then
    echo "major"
    return 0
  fi

  if grep -Eq '^feat(\([^)]+\))?:' <<<"$messages"; then
    echo "minor"
    return 0
  fi

  echo "patch"
}

if [[ "$event_name" == "workflow_dispatch" ]]; then
  mapfile -t tile_dirs < <(list_all_tiles)
else
  mapfile -t tile_dirs < <(list_changed_tiles)
fi

if [[ "${#tile_dirs[@]}" -eq 0 ]]; then
  echo "No changed Tessl tiles to publish."
  exit 0
fi

bump_type="$(publish_bump_type)"
echo "Publishing ${#tile_dirs[@]} Tessl tile(s) with ${bump_type} bump:"
printf '  %s\n' "${tile_dirs[@]}"

if [[ "$dry_run" == "true" ]]; then
  echo "Dry-run mode is enabled; publish commands will not be executed."
fi

for tile_dir in "${tile_dirs[@]}"; do
  echo
  echo "==> $tile_dir"
  tessl tile lint "$tile_dir"
  tessl tile publish --dry-run --bump "$bump_type" "$tile_dir"
  if [[ "$dry_run" != "true" ]]; then
    tessl tile publish --bump "$bump_type" "$tile_dir"
  fi
done
