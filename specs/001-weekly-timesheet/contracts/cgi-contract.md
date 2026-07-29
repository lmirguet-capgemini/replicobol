# Contract: Cobol CGI Backend

The web frontend communicates with GNU Cobol CGI-style handlers. Requests use `application/x-www-form-urlencoded` unless noted otherwise. Responses use `application/json` with a consistent status envelope.

## Response Envelope

### Success

```json
{
  "ok": true,
  "data": {}
}
```

### Validation or Save Failure

```json
{
  "ok": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable correction message",
    "field": "optional_field_name"
  }
}
```

## Create Project

`POST /cgi-bin/projects`

**Form fields**:
- `client_name`: Required.
- `project_name`: Required.
- `project_code`: Required and unique.

**Success response data**:

```json
{
  "project": {
    "client_name": "Acme",
    "project_name": "Migration",
    "project_code": "ACME-MIG"
  }
}
```

**Validation failures**:
- Missing `client_name`, `project_name`, or `project_code`.
- Duplicate `project_code`.

## List Projects

`GET /cgi-bin/projects`

**Success response data**:

```json
{
  "projects": [
    {
      "client_name": "Acme",
      "project_name": "Migration",
      "project_code": "ACME-MIG"
    }
  ]
}
```

## Save Weekly Time Entry

`POST /cgi-bin/timesheet`

**Form fields**:
- `project_code`: Required existing project code.
- `week_start`: Required Monday date in `YYYY-MM-DD` format.
- `days`: Required numeric value from 0 through 5 in increments of 0.25.

**Success response data**:

```json
{
  "entry": {
    "project_code": "ACME-MIG",
    "week_start": "2026-07-27",
    "days": 2.5
  },
  "correction_recorded": false,
  "week_total": 4.5
}
```

When the request replaces an existing saved value, `correction_recorded` is `true` after the backend appends a local correction record containing the project code, week, prior value, replacement value, and replacement timestamp.

**Validation failures**:
- Unknown project code.
- `week_start` is not a Monday or is not a valid date.
- `days` is non-numeric, below 0, above 5, or not a 0.25 increment.
- Saving the value would make the total across all projects for that week exceed 5.

## Get Calendar View

`GET /cgi-bin/calendar?start_week=YYYY-MM-DD&week_count=12`

**Query fields**:
- `start_week`: Required Monday date in `YYYY-MM-DD` format.
- `week_count`: Optional positive integer; defaults to 12.

**Success response data**:

```json
{
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
      "cells": [
        {
          "week_start": "2026-07-27",
          "display_value": 2.5,
          "status": "saved"
        },
        {
          "week_start": "2026-08-03",
          "display_value": "",
          "status": "blank"
        }
      ]
    }
  ]
}
```

**Validation failures**:
- `start_week` is not a Monday or is not a valid date.
- `week_count` is not a positive integer.
