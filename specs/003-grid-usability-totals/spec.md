# Feature Specification: Timesheet Grid Usability and Totals

**Feature Branch**: `[003-grid-usability-totals]`

**Created**: 2026-07-31

**Status**: Draft

**Input**: User description: "Improve current-week context, blank entries, week headers, project totals, period-total status coloring, and hover behavior in the timesheet grid."

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.

  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Scan the Current Weekly Grid (Priority: P1)

As a timesheet user, I want to recognize the current week, each week number, and weeks that need attention at a glance, so that I can quickly understand where I should record time.

**Why this priority**: Current-week context and weekly declaration status are the main scanning aids for a recurring weekly timesheet.

**Independent Test**: Load the default 12-week grid with weeks before and after the current week, then verify the current-week column, two-line headers, and period-total cell states without editing any entry.

**Acceptance Scenarios**:

1. **Given** the user opens the default timesheet view, **When** the 12-week range is loaded, **Then** the current local calendar week is the second-to-last displayed week and is visually highlighted.
2. **Given** the viewed range contains the current local calendar week, **When** the grid is shown, **Then** exactly that week column is visually highlighted across the header, project rows, and period-total row.
3. **Given** the user views a week column, **When** they scan its header, **Then** it shows its ISO week number on the first line and the Monday date on the second line.
4. **Given** a week in the period-total row totals exactly 5 declared days, **When** it is displayed, **Then** that weekly total has a green status treatment.
5. **Given** a past week in the period-total row totals less than 5 declared days, **When** it is displayed, **Then** that weekly total has a red status treatment.
6. **Given** a current or future week totals less than 5 declared days, **When** it is displayed, **Then** it retains the default period-total treatment rather than appearing overdue.

---

### User Story 2 - Review Project Lifetime Totals (Priority: P2)

As a timesheet user, I want each project total to include all recorded days for that project, so that I can understand the project’s full accumulated effort while working in any selected period.

**Why this priority**: The existing visible-period total can misrepresent the amount of time already recorded for a project.

**Independent Test**: Seed one project with entries both inside and outside the selected period, then verify that its Total column includes both values while the period-total row includes only displayed weeks.

**Acceptance Scenarios**:

1. **Given** a project has saved declarations outside and inside the selected period, **When** the user views the grid, **Then** its Total column shows the sum of all saved declarations for that project.
2. **Given** a project has no saved declarations, **When** the user views its row, **Then** its Total column displays zero.
3. **Given** the selected period changes, **When** the grid reloads, **Then** week cells and period totals reflect the selected weeks while project lifetime totals continue to include all saved declarations.

---

### User Story 3 - Read and Edit Grid Cells Without Visual Noise (Priority: P3)

As a timesheet user, I want blank entries to look empty and hover feedback to remain non-editing, so that the table stays easy to read until I intentionally choose a cell to edit.

**Why this priority**: A dense grid is easier to scan when empty cells are visually quiet and incidental pointer movement does not reveal form controls.

**Independent Test**: Load rows containing blank and zero-valued cells, move the pointer across cells, and intentionally select a cell to verify blank display, hover styling, and edit activation separately.

**Acceptance Scenarios**:

1. **Given** a project-week has no declared value or has a saved value of zero, **When** the grid is not in edit mode, **Then** the cell appears blank rather than displaying a dash or zero.
2. **Given** the pointer moves over a non-editing project-week cell, **When** the user has not selected it, **Then** the cell receives a hover highlight and does not reveal an input field.
3. **Given** the user intentionally selects a project-week cell, **When** they begin an edit, **Then** that cell alone presents the existing editable value control and retains the existing unsaved, saved, invalid, and failed feedback behavior.

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- If the selected range does not contain the current local calendar week, no week column receives current-week highlighting.
- If the current local calendar week is the first or final displayed week because the user manually changes the range, it is highlighted at its actual position; only the default range places it second-to-last.
- A past week is any displayed week whose Monday is before the Monday of the current local calendar week; the current week is not past.
- A week total above 5 retains the default period-total treatment; only exactly 5 is green.
- A blank or zero-valued project-week cell contributes zero to both the week’s period total and the project’s lifetime total.
- If no project-week cells contain values, the period-total row must still show a total of zero for every displayed week.
- A project may have correction history; totals must use the latest visible declaration for each project-week, consistent with existing timesheet reporting semantics.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The GNU Cobol calendar backend MUST provide the default 12 consecutive Monday-starting weeks, with its current local calendar week in the second-to-last column and one future week after it.
- **FR-002**: The GNU Cobol calendar backend MUST mark the complete current-week column when the selected period contains its current local calendar week; manually selected periods that exclude it MUST not mark any week column.
- **FR-003**: The GNU Cobol calendar backend MUST provide each week's ISO 8601 week number and Monday date for separate-line header rendering.
- **FR-004**: A project-week cell with no value or a zero value MUST display as blank outside edit mode, while preserving zero as a numeric value in calculations and edit behavior.
- **FR-005**: The grid MUST use non-editing hover feedback for project-week cells; hovering alone MUST NOT create, reveal, or focus an editable input.
- **FR-006**: Intentional selection of a project-week cell MUST continue to provide the existing weekly-entry editing workflow and visible unsaved, saved, invalid, and failed states.
- **FR-007**: The Total column for each project MUST show the sum of that project’s latest visible saved declarations across all weeks, including weeks outside the selected period.
- **FR-008**: The GNU Cobol calendar backend MUST provide a numeric total for every displayed week and an overall total for the selected period; these values MUST be based only on the selected period’s latest visible declarations.
- **FR-009**: The GNU Cobol calendar backend MUST mark a period-total cell as complete when its displayed week total is exactly 5 days; the frontend MUST render that mark with a green status treatment.
- **FR-010**: The GNU Cobol calendar backend MUST mark a period-total cell as overdue when its displayed week total is less than 5 days and that week is past; the frontend MUST render that mark with a red status treatment.
- **FR-011**: The GNU Cobol calendar backend MUST mark all other period-total cells as default; the frontend MUST render that mark with the default period-total treatment.
- **FR-012**: Time-entry aggregation, including project lifetime totals and latest visible declaration selection, MUST remain authoritative in the GNU Cobol backend contract.
- **FR-013**: The compact 12-week desktop grid MUST remain readable without horizontal scrolling at a viewport width of 1440 pixels or greater.

### Key Entities *(include if feature involves data)*

- **Current Calendar Week**: The Monday-through-Friday timesheet week containing the GNU Cobol runtime's local date; used by the backend for default range placement, marking, and past-week classification.
- **Week Column**: A displayed Monday-starting week, identified by its ISO week number and Monday date, containing project declarations and one period-total value.
- **Project Lifetime Total**: Sum of a project’s latest visible saved declarations across all recorded weeks, regardless of the selected period.
- **Period Week Total**: Sum of all projects’ latest visible declarations for one displayed week; used for the period-total row and weekly status treatment.
- **Project-Week Cell**: A displayed declaration for one project and one week, which is blank outside edit mode when its value is absent or zero.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At a 1440-pixel-wide desktop viewport, all 12 week columns, project identity, project Total column, and period-total row are visible simultaneously without horizontal scrolling.
- **SC-002**: A user can identify the current local calendar week and each header’s week number and Monday date within 5 seconds of loading the default view.
- **SC-003**: In a test dataset with one project declaration inside and one outside the selected period, the project Total equals their combined sum while the selected-period total excludes the outside declaration.
- **SC-004**: In a test dataset covering exactly-5, past-below-5, and future-below-5 period totals, the corresponding cells are green, red, and default-styled respectively.
- **SC-005**: Blank and zero project-week cells show no visible placeholder outside edit mode, and moving the pointer over them does not produce an input field.
- **SC-006**: Existing project creation, weekly entry saving, correction history, and validation contract checks continue to pass.

## Assumptions

- The GNU Cobol runtime's local date determines the current calendar week; the frontend performs no calendar, aggregation, or status calculation.
- ISO week numbering follows ISO 8601, where weeks begin on Monday.
- The current 12-week table remains the desktop target; narrow viewports may retain existing horizontal scrolling behavior.
- Existing timesheet entry, project creation, correction history, and local-first storage remain in scope only as compatibility requirements; this feature adds no new project management or cloud capabilities.
- Project lifetime totals are returned by the existing calendar reporting interface as an additive value; the existing data format is unchanged.
