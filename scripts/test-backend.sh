#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

"$ROOT_DIR/scripts/build.sh"

for test_script in "$ROOT_DIR"/backend/tests/contract/test_*.sh; do
  [ -f "$test_script" ] || continue
  sh "$test_script"
done