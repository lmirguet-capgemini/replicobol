#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CGI_DIR="$ROOT_DIR/backend/cgi"

command -v cobc >/dev/null 2>&1 || {
  echo "cobc is required to build Replicobol" >&2
  exit 1
}

for program in projects timesheet calendar; do
  source_file="$CGI_DIR/$program.cob"
  output_file="$CGI_DIR/$program"
  if [ -f "$source_file" ]; then
    cobc -x -free -Wall -o "$output_file" "$source_file"
    chmod +x "$output_file"
  fi
done