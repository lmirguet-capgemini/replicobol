# Quickstart: Frontend Redesign Validation

## Prerequisites

- GNU Cobol 3.x available as `cobc`.
- Python 3.
- A modern browser.
- Repository root as the working directory.

The contract details are documented in [contracts/calendar-dashboard-contract.md](contracts/calendar-dashboard-contract.md). Derived values and UI states are documented in [data-model.md](data-model.md).

## Build

```sh
./scripts/build.sh
```

Expected outcome: `projects`, `timesheet`, and `calendar` CGI binaries compile successfully under `backend/cgi/`.

## Backend Contract Validation

```sh
./scripts/test-backend.sh
```

Expected outcomes:

- All existing project, timesheet, correction, validation, and calendar scenarios still pass.
- Calendar responses parse as strict JSON.
- Calendar responses include the dashboard summary, row totals, and period total.
- A week totaling exactly 5 days is not missing.
- A week below 5 days or with no entries is missing.
- The missing window is the rolling three calendar months ending with the current week.

The contract scripts reset local `data/` files. Back up any data you need before running them.

## Launch

```sh
PORT=8765 ./scripts/serve-local.sh
```

Open `http://127.0.0.1:8765/frontend/`.

## Desktop Scenario

Use a viewport of at least 1440 by 900 pixels.

1. Confirm the first viewport shows Replicobol navigation, dashboard title, selected period, notification area, summary metrics, toolbar actions, and timesheet grid.
2. Confirm at least 5 project rows and 6 week columns fit without overlapping text, controls, or inputs when fixture data provides them.
3. Compare the hierarchy, dark navigation, restrained workspace, compact metrics, and dense grid treatment with `design.png`.
4. Change a saved week cell and confirm its unsaved state is visible before leaving the field or otherwise triggering save.
5. Enter a valid quarter-day value in a week cell and leave the field.
6. Confirm the notification moves through saving to `Entry saved`, the cell shows saved state, row and period totals update, and the value persists after reload.
7. Enter an invalid value and confirm the cell and notification communicate the validation failure without replacing the last saved backend value.

## Project Creation Scenario

1. Open the project creation action from the dashboard.
2. Confirm client name, project name, and project code are available in a focused flow.
3. Submit a valid project and confirm the notification reports success and the project appears as a new grid row.
4. Submit a duplicate or incomplete project and confirm the error remains associated with the project flow while the grid stays usable.

## Mobile Scenario

Use a viewport around 390 by 844 pixels.

1. Confirm navigation is accessible without covering dashboard content.
2. Confirm summary metrics reflow without clipped text.
3. Confirm project creation and period controls remain reachable.
4. Confirm the grid scrolls horizontally while project identity, editable cells, and totals remain usable.
5. Confirm notification text does not overlap surrounding controls.

## Direct Smoke Check

With the server running:

```sh
curl -s 'http://127.0.0.1:8765/cgi-bin/calendar?start_week=2026-07-27&week_count=12' \
  | python3 -m json.tool
```

Expected outcome: HTTP response data includes `summary`, `weeks`, `rows`, and `period_total_days` and parses without JSON errors.