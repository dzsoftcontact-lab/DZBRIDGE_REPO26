#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/git+manegment.sh"

if [[ ! -f "$TARGET" ]]; then
  echo "Missing upgraded manager: $TARGET" >&2
  exit 1
fi

exec bash "$TARGET" "$@"
