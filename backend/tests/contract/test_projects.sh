#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)

run_post_projects() {
  body=$1
  printf '%s' "$body" | REQUEST_METHOD=POST CONTENT_LENGTH=${#body} "$ROOT_DIR/backend/cgi/projects"
}

run_get_projects() {
  REQUEST_METHOD=GET "$ROOT_DIR/backend/cgi/projects"
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

response=$(run_post_projects 'client_name=Acme&project_name=Migration&project_code=ACME-MIG')
assert_contains "$response" '"ok":true' 'valid project creation succeeds'
assert_contains "$response" '"project_code":"ACME-MIG"' 'created project code is returned'

response=$(run_get_projects)
assert_contains "$response" '"ok":true' 'project list succeeds'
assert_contains "$response" '"client_name":"Acme"' 'project list includes client name'
assert_contains "$response" '"project_name":"Migration"' 'project list includes project name'

response=$(run_post_projects 'client_name=Acme&project_name=MissingCode')
assert_contains "$response" '"ok":false' 'missing project code is rejected'
assert_contains "$response" 'project_code' 'missing project code identifies the field'

response=$(run_post_projects 'client_name=Acme&project_name=Duplicate&project_code=ACME-MIG')
assert_contains "$response" '"ok":false' 'duplicate project code is rejected'
assert_contains "$response" 'Duplicate project code' 'duplicate project code explains the error'