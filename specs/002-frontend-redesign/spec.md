# Feature Specification: Frontend Redesign

**Feature Branch**: `[002-frontend-redesign]`

**Created**: 2026-07-30

**Status**: Draft

**Input**: User description: "I would like to evolve the frontend design of the application towards something that would look like the design 'design.png' (in the current folder)"

## Clarifications

### Session 2026-07-30

- Q: How should the redesigned dashboard handle the “submission status” shown in the reference design? → A: Treat it as an application notification area for messages such as “Entry saved”, not as a submission workflow or persisted submission state.
- Q: What should count as a “missing declaration” in the redesigned summary cards? → A: Missing declarations are recent weeks whose total declared work is less than 5 days.
- Q: How many recent weeks should the dashboard use when counting missing declarations? → A: Count weeks in the last 3 months.
- Q: What date should anchor the “last 3 months” used for missing declarations? → A: Count the rolling 3 months ending with the current week.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Work From A Dashboard-Style Timesheet (Priority: P1)

As a timesheet user, I want the application to present the weekly timesheet in a polished dashboard layout inspired by `design.png`, so that project rows, weekly columns, totals, and save states are easy to scan during routine entry.

**Why this priority**: The main value of the redesign is improving the primary timesheet screen without changing the underlying time-recording workflow.

**Independent Test**: Can be tested by opening the timesheet screen and confirming that the first visible experience uses the reference-style dashboard structure while still allowing existing project/week time entry.

**Acceptance Scenarios**:

1. **Given** the application has project and calendar data, **When** the user opens the frontend, **Then** the page shows a dashboard-style timesheet view with a left navigation area, page title, period selector area, notification area, summary cards, toolbar, and editable project-week grid.
2. **Given** a user needs to scan the period, **When** they look at the calendar grid, **Then** week labels, project identity, row totals, and period totals are visually distinct and readable.
3. **Given** a user changes a saved weekly value, **When** the change has not yet been saved, **Then** the screen clearly indicates the unsaved state without disrupting the grid.
4. **Given** a user edits a valid weekly value, **When** the save completes, **Then** the screen clearly indicates the saved state without disrupting the grid.

---

### User Story 2 - See High-Level Timesheet Progress At A Glance (Priority: P2)

As a timesheet user, I want prominent summary cards for declared days, active projects, and missing declarations, plus a visible notification area for application messages, so that I can understand the selected period and see save or error feedback before editing details.

**Why this priority**: The reference design emphasizes management-oriented summary information above the grid, which improves orientation and reduces manual counting.

**Independent Test**: Can be tested by loading a period with projects and saved entries and verifying that the summary area presents current period status in a readable, consistent way.

**Acceptance Scenarios**:

1. **Given** a selected period with saved values, **When** the dashboard loads, **Then** the summary cards show declared days, active project count, and missing declaration count.
2. **Given** one or more weeks in the rolling 3 months ending with the current week have less than 5 total declared days, **When** the user views the summary, **Then** those weeks are counted as missing declarations without requiring the user to inspect every cell.
3. **Given** the application saves data or reports an error, **When** the message is shown, **Then** it appears in the notification area without implying a separate submission state.

---

### User Story 3 - Manage Projects From The Same Visual System (Priority: P3)

As a timesheet user, I want project creation to fit the redesigned interface, so that adding a project feels like part of the same application rather than a separate plain form.

**Why this priority**: Project creation supports timesheet entry, but the core redesign value is the timesheet dashboard itself.

**Independent Test**: Can be tested by creating a project from the redesigned interface and verifying that the project appears in the grid with the same visual style and state handling.

**Acceptance Scenarios**:

1. **Given** the user needs a new project row, **When** they choose the project creation action, **Then** the interface provides a clear project creation flow with client name, project name, and project code fields.
2. **Given** project creation succeeds, **When** the user returns to the timesheet grid, **Then** the new project appears as a row without a page reload requirement visible to the user.
3. **Given** project creation fails validation, **When** the user submits the form, **Then** the validation message is shown near the project creation flow and the existing timesheet grid remains usable.

---

### Edge Cases

- If there are no projects, the redesigned timesheet area must show an empty state that explains how to add the first project.
- If the selected period contains more week columns than fit horizontally, the grid must remain usable without breaking project labels, totals, or input fields.
- If backend communication fails, the redesigned screen must preserve the current user-visible error behavior and clearly mark failed saves or failed loads.
- If a saved value is blank for a project-week cell, the cell must remain visually blank rather than implying a zero-day declaration.
- If the viewport is narrow, navigation, summary cards, toolbar actions, and the grid must remain accessible without overlapping text or controls.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The frontend MUST visually align the primary timesheet screen with the `design.png` reference, including a persistent left navigation area, dashboard page header, period controls, notification area, summary cards, action toolbar, and project-week grid.
- **FR-002**: The redesigned interface MUST keep existing timesheet capabilities available: loading calendar data, creating projects, editing project-week values, saving valid values, and displaying validation or persistence errors.
- **FR-003**: The project-week grid MUST show each project row with project name and project code, editable week cells, per-row total days, and a final period total row.
- **FR-004**: The selected period area MUST display a human-readable period range and week count so users know what calendar span they are editing.
- **FR-005**: The summary area MUST show declared days, active projects, and missing declarations, where each missing declaration represents a week in the rolling 3 months ending with the current week that has less than 5 total declared work days.
- **FR-006**: The redesigned interface MUST preserve visible unsaved, saved, invalid, failed, and blank cell states.
- **FR-007**: Project creation MUST be available from the redesigned interface and MUST collect client name, project name, and project code.
- **FR-008**: The interface MUST expose clear actions for creating a project and refreshing or changing the viewed period.
- **FR-009**: The redesigned layout MUST remain readable and operable on common desktop and mobile viewport sizes, including cases where the week grid needs horizontal scrolling.
- **FR-010**: The redesign MUST NOT add project editing, project removal, archiving, authentication, cloud sync, or multi-user behavior.
- **FR-011**: The frontend MUST continue to treat the existing backend contract as the source of truth for project creation, validation, timesheet saving, and calendar data.
- **FR-012**: Error and success messages MUST be visible, concise, and associated with the user action that produced them; the notification area MUST support messages such as “Entry saved” without introducing a submission workflow.

### Key Entities *(include if feature involves data)*

- **Dashboard Summary**: User-facing period progress including declared days, active projects, and missing declarations for weeks in the rolling 3 months ending with the current week whose total declared work is less than 5 days.
- **Notification Area**: User-facing status region for application feedback such as saved, invalid, failed, or loading messages.
- **Project Row**: Visual representation of one project in the timesheet grid, including project identity, editable week cells, and total days.
- **Week Cell**: Editable period value for one project and one week, with visible blank, unsaved, saved, invalid, or failed state.
- **Period Selection**: User-facing selected calendar span, including start week, range label, and week count.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can identify the selected period, active project count, and declared days within 5 seconds of opening the frontend with existing data.
- **SC-002**: A user can save a valid weekly value for an existing project in under 10 seconds from the loaded dashboard.
- **SC-003**: The redesigned view displays at least 5 project rows and 6 week columns without overlapping labels, controls, or inputs on a desktop viewport.
- **SC-004**: The redesigned view remains usable on a mobile-width viewport, with all navigation, summary, project creation, and timesheet editing controls reachable.
- **SC-005**: Existing behavior checks continue to pass after the redesign, proving the visual update did not change time-recording rules.
- **SC-006**: At least 90% of visible interactive elements have labels or nearby context that make their purpose clear without reading external documentation.

## Assumptions

- The visual target is the provided `design.png` file in the repository root.
- The redesign should adapt the visual language of the reference image to Replicobol rather than reproducing unrelated branding or inaccessible decorative details exactly.
- Existing local-first behavior, saved records, and backend-owned business rules remain unchanged.
- Export, pagination, project status management, and project-code management beyond the current creation flow are visual references only unless separately specified later.
