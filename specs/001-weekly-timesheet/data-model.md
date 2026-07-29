# Data Model: Weekly Timesheet

## Project

Represents an active work assignment that can receive weekly time entries.

**Fields**:
- `project_code`: Required unique business identifier for active projects.
- `client_name`: Required client label shown in project creation and calendar rows.
- `project_name`: Required project label shown in project creation and calendar rows.
- `created_at`: Local creation timestamp for record traceability.

**Relationships**:
- One project has zero or more weekly time entries.

**Validation Rules**:
- `project_code`, `client_name`, and `project_name` must be present and non-blank.
- `project_code` must be unique among all projects.
- Projects cannot be removed or archived in v1.

**State Transitions**:
- `Created` -> `Active`: A valid project is saved and appears as a calendar row.
- No inactive, archived, or deleted state exists in v1.

## Week

Represents one Monday-through-Friday 5-day reporting period.

**Fields**:
- `week_start`: Required Monday date in ISO format (`YYYY-MM-DD`).
- `week_end`: Derived Friday date for display.
- `week_label`: Derived visible date range for the calendar header.

**Relationships**:
- One week has zero or more weekly time entries across projects.

**Validation Rules**:
- `week_start` must identify a Monday.
- The week total across all projects must not exceed 5 days.

## Weekly Time Entry

Represents the latest saved number of days for one project during one week.

**Fields**:
- `project_code`: Required reference to an existing project.
- `week_start`: Required Monday date in ISO format (`YYYY-MM-DD`).
- `days`: Required decimal day value for saved entries.
- `updated_at`: Local timestamp for the latest save.

**Relationships**:
- Belongs to exactly one project.
- Belongs to exactly one week.
- Uniqueness is enforced by the pair (`project_code`, `week_start`).

**Validation Rules**:
- `project_code` must refer to an existing project.
- `days` must be numeric, from 0 through 5 inclusive, in increments of 0.25.
- Saving an entry must not make the total for its week exceed 5 days.
- Updating an existing project-week entry replaces the visible/calculated value and appends a correction record with the prior and replacement values.

**State Transitions**:
- `Blank` -> `Saved`: User saves a valid value for a project-week cell.
- `Saved` -> `Saved`: User replaces the latest value with another valid value.
- There is no deletion state for weekly entries in v1.

## Weekly Entry Correction

Represents the local explanation record created when a saved weekly time entry changes.

**Fields**:
- `project_code`: Required reference to the project whose entry changed.
- `week_start`: Required Monday date for the changed entry.
- `prior_days`: Required decimal day value that was replaced.
- `replacement_days`: Required decimal day value saved by the change.
- `replaced_at`: Local timestamp for the replacement.

**Relationships**:
- Belongs to exactly one project.
- Describes a change to exactly one project-week entry.

**Validation Rules**:
- Correction records are appended only after a valid update replaces an existing saved entry.
- Correction records must be readable local records and must not affect calendar display or weekly total calculations.

## Calendar Cell

Represents the display intersection of one project row and one week column.

**Fields**:
- `project_code`: Project row identifier.
- `week_start`: Week column identifier.
- `display_value`: Blank when no saved entry exists; otherwise the saved `days` value.
- `status`: One of `blank`, `saved`, `invalid`, or `failed` for frontend state display.

**Validation Rules**:
- Blank cells mean no saved entry exists.
- Numeric cells show saved latest values only.
- Invalid or failed save states must not be treated as saved records.
