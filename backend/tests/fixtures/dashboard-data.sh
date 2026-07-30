#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

cat > "$ROOT_DIR/data/projects.dat" <<'DATA'
# Replicobol projects data
# Format: project_code|client_name|project_name|created_at
ACME-MIG|Acme|Migration|20260730
BETA-SUP|Beta|Support|20260730
GAMMA-OPS|Gamma|Operations|20260730
DELTA-UX|Delta|UX Review|20260730
EPSILON-QA|Epsilon|Quality Assurance|20260730
DATA

cat > "$ROOT_DIR/data/weekly-entries.dat" <<'DATA'
# Replicobol weekly entries data
# Format: project_code|week_start|days|updated_at
ACME-MIG|2026-04-27|5|20260730
ACME-MIG|2026-05-04|2|20260730
BETA-SUP|2026-05-04|2|20260730
GAMMA-OPS|2026-05-11|1|20260730
DELTA-UX|2026-05-11|1|20260730
EPSILON-QA|2026-05-11|1|20260730
ACME-MIG|2026-07-27|2.5|20260730
BETA-SUP|2026-07-27|1.5|20260730
GAMMA-OPS|2026-08-03|3|20260730
DATA

cat > "$ROOT_DIR/data/weekly-entry-corrections.dat" <<'DATA'
# Replicobol weekly entry correction data
# Format: project_code|week_start|prior_days|replacement_days|replaced_at
DATA