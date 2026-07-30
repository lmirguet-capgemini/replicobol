# Backend Validation

Executed on 2026-07-30:

```sh
./scripts/test-backend.sh
```

Result: PASS.

The suite rebuilt all CGI handlers and ran the project, timesheet, correction, and calendar contract scripts. Calendar checks include strict JSON parsing, additive row and period totals, dashboard summary values, rolling-window boundaries, missing declaration thresholds, and unsigned numeric output.
