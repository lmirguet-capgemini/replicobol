#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

cat > "$ROOT_DIR/data/projects.dat" <<'DATA'
# Replicobol projects data
# Format: project_code|client_name|project_name|created_at
DATA

cat > "$ROOT_DIR/data/weekly-entries.dat" <<'DATA'
# Replicobol weekly entries data
# Format: project_code|week_start|days|updated_at
DATA

cat > "$ROOT_DIR/data/weekly-entry-corrections.dat" <<'DATA'
# Replicobol weekly entry correction data
# Format: project_code|week_start|prior_days|replacement_days|replaced_at
DATA