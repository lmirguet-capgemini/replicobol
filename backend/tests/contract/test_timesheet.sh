#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

run_post_projects() {
  body=$1
  printf '%s' "$body" | REQUEST_METHOD=POST CONTENT_LENGTH=${#body} "$ROOT_DIR/backend/cgi/projects" >/dev/null
}

run_post_timesheet() {
  body=$1
  printf '%s' "$body" | REQUEST_METHOD=POST CONTENT_LENGTH=${#body} "$ROOT_DIR/backend/cgi/timesheet"
}

assert_contains() {
  text=$1
  expected=$2
  label=$3
  printf '%s' "$text" | grep -F "$expected" >/dev/null || {
    printf 'FAIL: %s\nExpected to find: %s\nResponse:\n%s\n' "$label" "$expected" "$text" >&2
    exit 1
  }
}

assert_json() {
  text=$1
  label=$2
  printf '%s' "$text" | python3 -c 'import json, sys
text = sys.stdin.read()
start = text.find("{")
if start < 0:
    raise SystemExit("no JSON object found")
json.loads(text[start:])
' || {
    printf 'FAIL: %s did not return valid JSON\nResponse:\n%s\n' "$label" "$text" >&2
    exit 1
  }
}

"$ROOT_DIR/backend/tests/fixtures/empty-data.sh"
run_post_projects 'client_name=Acme&project_name=Migration&project_code=ACME-MIG'
run_post_projects 'client_name=Beta&project_name=Support&project_code=BETA-SUP'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=2.5')
assert_json "$response" 'valid weekly entry response'
assert_contains "$response" '"ok":true' 'valid weekly entry succeeds'
assert_contains "$response" '"days":2.5' 'saved days are returned'
assert_contains "$response" '"correction_recorded":false' 'new entry has no correction record'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=3')
assert_json "$response" 'updated weekly entry response'
assert_contains "$response" '"ok":true' 'updating weekly entry succeeds'
assert_contains "$response" '"days":3' 'updated days are returned'
assert_contains "$response" '"correction_recorded":true' 'updated entry records correction history'
grep -F 'ACME-MIG|2026-07-27|2.5|3|' "$ROOT_DIR/data/weekly-entry-corrections.dat" >/dev/null || {
  echo 'FAIL: correction record was not appended' >&2
  exit 1
}

response=$(run_post_timesheet 'project_code=UNKNOWN&week_start=2026-07-27&days=1')
assert_json "$response" 'unknown project response'
assert_contains "$response" '"ok":false' 'unknown project is rejected'
assert_contains "$response" 'Unknown project code' 'unknown project explains the error'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-28&days=1')
assert_json "$response" 'non-Monday week response'
assert_contains "$response" '"ok":false' 'non-Monday week is rejected'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=abc')
assert_json "$response" 'non-numeric days response'
assert_contains "$response" '"ok":false' 'non-numeric days are rejected'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=5.25')
assert_json "$response" 'days above five response'
assert_contains "$response" '"ok":false' 'days above five are rejected'

response=$(run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=3.10')
assert_json "$response" 'non-quarter increment response'
assert_contains "$response" '"ok":false' 'non-quarter increments are rejected'

response=$(run_post_timesheet 'project_code=BETA-SUP&week_start=2026-07-27&days=2.25')
assert_json "$response" 'weekly total error response'
assert_contains "$response" '"ok":false' 'weekly total above five is rejected'
assert_contains "$response" 'weekly total' 'weekly total error is explained'