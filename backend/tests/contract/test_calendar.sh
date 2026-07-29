#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

run_post_projects() {
  body=$1
  printf '%s' "$body" | REQUEST_METHOD=POST CONTENT_LENGTH=${#body} "$ROOT_DIR/backend/cgi/projects" >/dev/null
}

run_post_timesheet() {
  body=$1
  printf '%s' "$body" | REQUEST_METHOD=POST CONTENT_LENGTH=${#body} "$ROOT_DIR/backend/cgi/timesheet" >/dev/null
}

run_get_calendar() {
  query=$1
  REQUEST_METHOD=GET QUERY_STRING=$query "$ROOT_DIR/backend/cgi/calendar"
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

"$ROOT_DIR/backend/tests/fixtures/empty-data.sh"
run_post_projects 'client_name=Acme&project_name=Migration&project_code=ACME-MIG'
run_post_projects 'client_name=Beta&project_name=Support&project_code=BETA-SUP'
run_post_timesheet 'project_code=ACME-MIG&week_start=2026-07-27&days=2.5'
run_post_timesheet 'project_code=BETA-SUP&week_start=2026-08-03&days=1.25'

response=$(run_get_calendar 'start_week=2026-07-27&week_count=2')
assert_contains "$response" '"ok":true' 'calendar request succeeds'
assert_contains "$response" '"week_start":"2026-07-27"' 'calendar includes first week'
assert_contains "$response" '"week_start":"2026-08-03"' 'calendar includes second week'
assert_contains "$response" '"project_code":"ACME-MIG"' 'calendar includes first project row'
assert_contains "$response" '"project_code":"BETA-SUP"' 'calendar includes second project row'
assert_contains "$response" '"display_value":2.5' 'calendar shows saved value'
assert_contains "$response" '"display_value":""' 'calendar shows blank cell for missing entry'
assert_contains "$response" '"status":"blank"' 'calendar marks blank cells'

response=$(run_get_calendar 'start_week=2026-07-28&week_count=2')
assert_contains "$response" '"ok":false' 'calendar rejects non-Monday start week'

response=$(run_get_calendar 'start_week=2026-07-27&week_count=0')
assert_contains "$response" '"ok":false' 'calendar rejects non-positive week count'