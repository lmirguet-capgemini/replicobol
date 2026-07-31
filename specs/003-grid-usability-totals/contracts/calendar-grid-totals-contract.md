# Contract: Calendar Grid Totals Extension

This contract extends the existing successful `GET /cgi-bin/calendar` response documented in [../../002-frontend-redesign/contracts/calendar-dashboard-contract.md](../../002-frontend-redesign/contracts/calendar-dashboard-contract.md).

## Additive Week and Row Fields

Each existing `data.weeks[]` item gains backend-calculated calendar and period-total fields.

```json
{
  "week_start": "2026-07-27",
  "week_end": "2026-07-31",
  "label": "2026-07-27 to 2026-07-31",
  "iso_week_number": 31,
  "is_current_week": true,
  "period_total_days": 5,
  "period_total_status": "complete"
}
```

Each existing `data.rows[]` item gains `lifetime_total_days`.

```json
{
  "project": {
    "client_name": "Acme",
    "project_name": "Migration",
    "project_code": "ACME-MIG"
  },
  "total_days": 2.5,
  "lifetime_total_days": 8.5,
  "cells": [
    {
      "week_start": "2026-07-27",
      "display_value": 2.5,
      "status": "saved"
    }
  ]
}
```

## Semantics

- `total_days` remains the sum of the project’s latest visible declarations in the requested period.
- `lifetime_total_days` is the sum of the project’s latest visible declarations across all stored weeks, including weeks outside the requested period.
- `iso_week_number`, `is_current_week`, `period_total_days`, and `period_total_status` are calculated by GNU Cobol for each returned week.
- `period_total_status` is `complete` only when `period_total_days` is exactly 5, `overdue` only when its week is before the backend runtime's current local Monday and its total is below 5, and `default` otherwise.
- Missing and zero values contribute zero.
- Both numeric fields are valid unsigned JSON numbers without a leading plus sign.
- Existing `weeks`, `cells`, `total_days`, `period_total_days`, and `summary` meanings remain unchanged.

## Default Request

When `start_week` is omitted, GNU Cobol selects the default 12-week period with its current local week in the second-to-last column. A supplied valid `start_week` continues to select an explicit period.

## Frontend Rendering Rules

The frontend renders `iso_week_number`, `is_current_week`, `period_total_days`, and `period_total_status` exactly as returned. It performs no calendar, aggregation, or period-status computation.