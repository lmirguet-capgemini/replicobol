# US1 Desktop Validation

Validated on 2026-07-30 at `http://127.0.0.1:8765/frontend/` using the dashboard fixture.

- Dashboard rendered the persistent navigation, selected period, notification region, summary metrics, and a twelve-week project grid.
- The grid displayed five projects and backend-provided per-row and period totals.
- Editing `ACME-MIG` for `2026-08-03` to `1.25` displayed `Unsaved entry` before blur.
- Blurring the field submitted the existing CGI request and the notification changed to `Entry saved`.
- The page refreshed from the backend after the successful save.

The integrated-browser screenshot confirms the styled desktop dashboard. The task-specific image artifact could not be written because the available browser screenshot API exposes a chat resource rather than a workspace file.
