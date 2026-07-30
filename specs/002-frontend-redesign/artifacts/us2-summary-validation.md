# US2 Summary Validation

Validated on 2026-07-30 using `backend/tests/fixtures/dashboard-data.sh` and the calendar contract test.

- Selected-period declared days: `7`
- Active projects: `5`
- Missing declarations: `13`
- Missing window: `2026-04-27` through `2026-07-27`
- The fixture includes an exactly-five-day week, below-five-day weeks, and empty weeks.
- `sh backend/tests/contract/test_calendar.sh` passed with strict JSON parsing and unsigned number checks.
