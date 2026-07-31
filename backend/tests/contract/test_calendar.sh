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

assert_grid_totals() {
  text=$1
  printf '%s' "$text" | python3 -c 'import json, sys
text = sys.stdin.read()
data = json.loads(text[text.find("{"):])["data"]
weeks = data["weeks"]
assert [(week["week_start"], week["iso_week_number"], week["is_current_week"], week["period_total_days"], week["period_total_status"]) for week in weeks] == [
    ("2026-07-20", 30, False, 4, "overdue"),
    ("2026-07-27", 31, True, 5, "complete"),
    ("2026-08-03", 32, False, 3, "default"),
]
rows = {row["project"]["project_code"]: row for row in data["rows"]}
assert rows["ACME-MIG"]["total_days"] == 7.5
assert rows["ACME-MIG"]["lifetime_total_days"] == 14.5
assert rows["EPSILON-QA"]["total_days"] == 0
assert rows["EPSILON-QA"]["lifetime_total_days"] == 1
assert rows["ZETA-EMPTY"]["total_days"] == 0
assert rows["ZETA-EMPTY"]["lifetime_total_days"] == 0
assert data["period_total_days"] == 12
' || {
    printf 'FAIL: calendar grid totals do not match the Cobol reporting contract\nResponse:\n%s\n' "$text" >&2
    exit 1
  }
}

"$ROOT_DIR/backend/tests/fixtures/dashboard-data.sh"

response=$(run_get_calendar 'start_week=2026-07-27&week_count=2')
assert_json "$response" 'calendar response'
assert_contains "$response" '"ok":true' 'calendar request succeeds'
assert_contains "$response" '"week_start":"2026-07-27"' 'calendar includes first week'
assert_contains "$response" '"week_start":"2026-08-03"' 'calendar includes second week'
assert_contains "$response" '"project_code":"ACME-MIG"' 'calendar includes first project row'
assert_contains "$response" '"project_code":"BETA-SUP"' 'calendar includes second project row'
assert_contains "$response" '"display_value":3.5' 'calendar shows saved value'
assert_contains "$response" '"display_value":""' 'calendar shows blank cell for missing entry'
assert_contains "$response" '"status":"blank"' 'calendar marks blank cells'
assert_contains "$response" '"total_days":3.5' 'calendar includes first project row total'
assert_contains "$response" '"total_days":3' 'calendar includes third project row total'
assert_contains "$response" '"period_total_days":8' 'calendar includes selected period total'
assert_contains "$response" '"declared_days":8' 'summary uses selected period declared days'
assert_contains "$response" '"active_projects":6' 'summary counts all active projects'
assert_contains "$response" '"missing_declarations":12' 'summary counts below-threshold and empty rolling weeks'
assert_contains "$response" '"missing_window_start":"2026-04-27"' 'summary starts at the first Monday in the rolling window'
assert_contains "$response" '"missing_window_end":"2026-07-27"' 'summary ends at the current week Monday'
if printf '%s' "$response" | grep -Eq '"(declared_days|period_total_days)":\+'; then
  printf 'FAIL: summary totals must not use a leading plus sign\nResponse:\n%s\n' "$response" >&2
  exit 1
fi

response=$(run_get_calendar 'start_week=2026-07-20&week_count=3')
assert_json "$response" 'grid totals response'
assert_grid_totals "$response"

response=$(run_get_calendar 'start_week=2025-12-29&week_count=1')
assert_json "$response" 'ISO year boundary response'
assert_contains "$response" '"iso_week_number":1' 'calendar uses ISO week one across a year boundary'

response=$(run_get_calendar 'week_count=12')
assert_json "$response" 'default calendar response'
assert_contains "$response" '"ok":true' 'calendar selects the default period without start_week'
printf '%s' "$response" | python3 -c 'import json, sys
text = sys.stdin.read()
weeks = json.loads(text[text.find("{"):])["data"]["weeks"]
assert len(weeks) == 12
assert [index for index, week in enumerate(weeks) if week["is_current_week"]] == [10]
' || {
  printf 'FAIL: default calendar period must mark the current week second-to-last\nResponse:\n%s\n' "$response" >&2
  exit 1
}

response=$(run_get_calendar 'start_week=2026-07-28&week_count=2')
assert_json "$response" 'non-Monday week response'
assert_contains "$response" '"ok":false' 'calendar rejects non-Monday start week'

response=$(run_get_calendar 'start_week=2026-07-27&week_count=0')
assert_json "$response" 'non-positive week count response'
assert_contains "$response" '"ok":false' 'calendar rejects non-positive week count'