#!/usr/bin/env bash
set -euo pipefail

tessl_version="${TESSL_CLI_VERSION:-0.92.0}"

exec npx "tessl@$tessl_version" "$@"
