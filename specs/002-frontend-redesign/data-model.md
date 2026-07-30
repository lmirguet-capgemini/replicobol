# Data Model: Frontend Redesign

This feature does not change persistent storage. It adds a read-only dashboard view model derived from the existing project and weekly-entry records.

## Existing Persistent Entities

### Project

- `client_name`: Required display name of the client.
- `project_name`: Required display name of the project.
- `project_code`: Required unique project identity.
- `created_at`: Existing local creation timestamp.

**Relationships**: One project can have zero or more weekly entries.

### Weekly Entry

- `project_code`: References an existing project.
- `week_start`: Monday date in `YYYY-MM-DD` format.
- `days`: Numeric value from 0 through 5 in increments of 0.25.
- `updated_at`: Existing local update timestamp.

**Relationships**: Entries for all projects sharing the same `week_start` contribute to the week total, which cannot exceed 5 days.

### Correction Record

- `project_code`: Project whose weekly entry changed.
- `week_start`: Week whose visible value changed.
- `prior_value`: Value before the correction.
- `replacement_value`: Latest visible value.
- `changed_at`: Existing local correction timestamp.

**Relationships**: Appended when an existing project-week value is replaced. The redesign does not alter this behavior.

## Derived Dashboard Entities

### Dashboard Summary

- `declared_days`: Sum of saved weekly values across all project cells in the selected calendar period.
- `active_projects`: Count of all existing projects because v1 has no inactive project state.
- `missing_declarations`: Count of weeks in the rolling three-calendar-month window ending with the current week whose total declared work is below 5 days.
- `missing_window_start`: First Monday included in the missing-declaration calculation.
- `missing_window_end`: Monday of the current local week.

**Validation rules**:

- Counts are non-negative integers.
- `declared_days` is a non-negative quarter-day value.
- The missing window is independent of the selected calendar period.
- A week total of exactly 5 is complete; a total below 5 is missing.
- A week with no entries has a total of 0 and is missing.

### Period Selection

- `start_week`: Monday shown as the first grid column.
- `week_count`: Number of visible consecutive weeks; defaults to 12 and remains within the backend-supported range of 1 through 52.
- `end_week`: End date of the last visible work week.
- `label`: Human-readable selected period range.

### Project Row View

- `project`: Existing project identity.
- `cells`: One week cell per selected week.
- `total_days`: Sum of nonblank saved values in the row for the selected period.

### Week Cell View

- `week_start`: Monday represented by the cell.
- `display_value`: Latest saved value or blank when no entry exists.
- `status`: `blank`, `unsaved`, `saving`, `saved`, `invalid`, or `failed` in the rendered interface.

## State Transitions

### Week Cell

```text
blank/saved -> unsaved -> saving -> saved
                            -> invalid
                            -> failed
invalid/failed -> unsaved on next edit
```

- `unsaved` begins when the user changes a blank or saved value before a save request is sent.
- `saving` begins when an unsaved value is sent to the backend.
- `saved` begins only after a successful backend response.
- `invalid` follows a structured validation failure.
- `failed` follows transport, parsing, or backend execution failure.

### Notification Area

```text
idle -> loading/saving -> success
                       -> validation error
                       -> failure
```

The notification is transient presentation state and is never persisted as a submission status.