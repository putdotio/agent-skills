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

find_plugin_dir() {
  local changed_path="$1"
  local current

  if [[ -d "$changed_path" ]]; then
    current="$changed_path"
  else
    current="$(dirname "$changed_path")"
  fi

  while [[ "$current" == skills* && "$current" != "." ]]; do
    if [[ -f "$current/.tessl-plugin/plugin.json" ]]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done

  return 1
}

list_all_plugins() {
  find skills -mindepth 4 -maxdepth 5 -path '*/.tessl-plugin/plugin.json' -print \
    | sed 's#/.tessl-plugin/plugin.json$##' \
    | sort -u
}

list_changed_plugins() {
  if [[ -z "$before_sha" || "$before_sha" == "$zero_sha" ]]; then
    list_all_plugins
    return 0
  fi

  if ! git cat-file -e "${before_sha}^{commit}" 2>/dev/null; then
    git fetch --no-tags origin "$before_sha"
  fi

  git diff --name-only "$before_sha" "$after_sha" -- skills \
    | while IFS= read -r changed_path; do
      find_plugin_dir "$changed_path" || true
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
  mapfile -t plugin_dirs < <(list_all_plugins)
else
  mapfile -t plugin_dirs < <(list_changed_plugins)
fi

if [[ "${#plugin_dirs[@]}" -eq 0 ]]; then
  echo "No changed Tessl plugins to publish."
  exit 0
fi

bump_type="$(publish_bump_type)"
echo "Publishing ${#plugin_dirs[@]} Tessl plugin(s) with ${bump_type} bump:"
printf '  %s\n' "${plugin_dirs[@]}"

if [[ "$dry_run" == "true" ]]; then
  echo "Dry-run mode is enabled; publish commands will not be executed."
fi

for plugin_dir in "${plugin_dirs[@]}"; do
  echo
  echo "==> $plugin_dir"
  tessl plugin lint "$plugin_dir"
  tessl plugin publish --dry-run --bump "$bump_type" "$plugin_dir"
  if [[ "$dry_run" != "true" ]]; then
    tessl plugin publish --bump "$bump_type" "$plugin_dir"
  fi
done
