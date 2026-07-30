# Contract: Calendar Dashboard Extension

The frontend redesign preserves the existing CGI routes and form contracts. This document extends the successful response for the existing calendar endpoint.

## Get Calendar Dashboard

`GET /cgi-bin/calendar?start_week=YYYY-MM-DD&week_count=12`

### Query Fields

- `start_week`: Required Monday date in `YYYY-MM-DD` format.
- `week_count`: Optional integer from 1 through 52; defaults to 12.

### Success Response

```json
{
  "ok": true,
  "data": {
    "summary": {
      "declared_days": 18.5,
      "active_projects": 4,
      "missing_declarations": 2,
      "missing_window_start": "2026-04-27",
      "missing_window_end": "2026-07-27"
    },
    "weeks": [
      {
        "week_start": "2026-07-27",
        "week_end": "2026-07-31",
        "label": "2026-07-27 to 2026-07-31"
      }
    ],
    "rows": [
      {
        "project": {
          "client_name": "Acme",
          "project_name": "Migration",
          "project_code": "ACME-MIG"
        },
        "total_days": 2.5,
        "cells": [
          {
            "week_start": "2026-07-27",
            "display_value": 2.5,
            "status": "saved"
          }
        ]
      }
    ],
    "period_total_days": 18.5
  }
}
```

### Summary Semantics

- `declared_days` and `period_total_days` are the sum of latest visible entry values in the requested period.
- `active_projects` is the number of existing projects returned by the project store.
- `missing_window_end` is the Monday of the current local week.
- `missing_window_start` is the earliest Monday on or after the date three calendar months before `missing_window_end`.
- `missing_declarations` counts every included week whose total latest visible values across all projects is less than 5 days.
- Missing-declaration values do not change when the user browses a different selected period.
- Numeric fields are emitted as valid unsigned JSON numbers without leading plus signs.

### Compatibility

- Existing `weeks`, `rows[].project`, and `rows[].cells` fields retain their current meaning.
- `summary`, `rows[].total_days`, and `period_total_days` are additive fields.
- Project creation and timesheet save request/response contracts are unchanged.

### Failure Response

The existing error envelope and calendar validation behavior remain unchanged:

```json
{
  "ok": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "start_week must be a Monday date",
    "field": "start_week"
  }
}
```