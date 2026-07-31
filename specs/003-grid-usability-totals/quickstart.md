# Quickstart: Grid Usability and Totals Validation

## Prerequisites

- GNU Cobol 3.x (`cobc`), Python 3, and a modern browser.
- Run commands from the repository root.
- The contract fixture rewrites `data/`; back up local entries before executing it.

## Backend Contract Check

```sh
./scripts/test-backend.sh
```

Expected outcomes:

- Calendar JSON parses strictly.
- A project with declarations inside and outside the requested range returns a selected-period `total_days` and an all-history `lifetime_total_days` with the expected different values.
- Each returned week supplies Cobol-calculated ISO week data, current-week state, period total, and period-total status.
- Existing project, timesheet, correction, validation, and calendar tests remain passing.

## Local Browser Check

```sh
PORT=8765 ./scripts/serve-local.sh
```

Open `http://127.0.0.1:8765/frontend/` at a 1440px-or-wider desktop viewport.

1. Confirm the backend-selected default 12-week period puts its current Monday in the second-to-last column and highlights the complete column.
2. Confirm every header shows `Week NN` above its Monday date.
3. Confirm all 12 weeks, project identity, the project Total, and period-total row are visible without horizontal scrolling.
4. Confirm blank and zero declarations render empty, and hovering a cell highlights it without showing an input.
5. Select one cell deliberately and verify only that cell enters the existing edit flow.
6. Confirm a project Total includes a fixture declaration outside the selected period.
7. Confirm period-total cells map the backend-provided `complete`, `overdue`, and `default` statuses to green, red, and default treatments without client-side recalculation.

## Period Change Check

1. Choose a period that excludes the current local week.
2. Confirm no week column is highlighted as current.
3. Confirm the period-total cells update to the selected weeks while each project lifetime total remains unchanged.