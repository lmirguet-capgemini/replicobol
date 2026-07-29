# Quickstart: Weekly Timesheet Validation

This guide validates the planned Replicobol weekly timesheet feature end to end after implementation.

## Prerequisites

- GNU Cobol compiler/runtime available as `cobc`.
- A local CGI-capable web server configured to run compiled handlers from `backend/cgi/`.
- Repository root as the working directory.

## Build

```bash
./scripts/build.sh
```

Expected outcome: GNU Cobol CGI handlers compile successfully and generated executables are available to the local server.

## Backend Contract Checks

```bash
./scripts/test-backend.sh
```

Expected outcomes:
- Creating a project with client name, project name, and project code succeeds.
- Creating a project with a missing required field fails with a validation message.
- Creating a second project with the same project code fails.
- Saving 2.5 days for an existing project and Monday week succeeds.
- Saving a non-numeric value, a value above 5, or a value that makes the week total exceed 5 fails.
- Updating an existing project-week entry replaces the visible value, returns the latest value, and appends a local correction record for the prior value.
- Calendar data returns blank cells for missing project-week entries.

## Local Web Smoke Test

```bash
./scripts/serve-local.sh
```

Open `http://127.0.0.1:8000/frontend/` unless `PORT` is set to a different value. The script builds missing CGI executables before starting the local server.

Expected outcomes:
- The project creation form saves a valid project and shows it as a calendar row.
- The calendar displays Monday-through-Friday week columns.
- Entering a valid day value saves the cell and persists after reload.
- Blank project-week cells remain blank until saved.
- Invalid values show correction messages and do not become saved records.
- A 10-project by 12-week calendar view loads in under 2 seconds locally, and project creation plus weekly entry save each complete in under 1 second locally.
- Projects cannot be removed or archived from the v1 interface.

Optional timing smoke check from another terminal while the server is running:

```bash
time curl -s 'http://127.0.0.1:8000/cgi-bin/calendar?start_week=2026-07-27&week_count=12' >/dev/null
```

## Contract Reference

See [contracts/cgi-contract.md](contracts/cgi-contract.md) for request and response details.
See [data-model.md](data-model.md) for entity and validation rules.