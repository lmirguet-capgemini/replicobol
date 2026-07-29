# Feature Specification: Weekly Timesheet

**Feature Branch**: `001-weekly-timesheet`

**Created**: 2026-07-29

**Status**: Draft

**Input**: User description: "Implement the feature specification based on the updated constitution. I want to build a timesheet application with a web frontend and a backend in Cobol. The application name is Replicobol. Each project has a client's name, a project name, and a project code. The application should allow me to define how many days I spent on each project each week. I should be able to create new projects and to input the number of days that I spend on a certain project during a certain week. There should be a calendar view with each line as a project, each column as a week, and each cell showing the number of days spent on this project during this week."

## Clarifications

### Session 2026-07-29

- Q: Should Replicobol prevent the total days across all projects in the same week from exceeding 7 days? -> A: The total number of days in a week is always 5.
- Q: Which days define one Replicobol timesheet week? -> A: Monday through Friday.
- Q: How should a calendar cell with no saved time entry appear? -> A: Show blank cells for no saved entry.
- Q: When an existing weekly day value is changed, what history should Replicobol keep? -> A: Show and calculate with only the latest value, while preserving a local correction record sufficient to explain the change.
- Q: Should the user be able to remove or archive a project after it has time entries? -> A: No removal or archive in v1.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Trackable Projects (Priority: P1)

As the timesheet owner, I want to create projects with client names, project names, and project codes so that every time allocation is tied to a clear project identity.

**Why this priority**: Time cannot be recorded accurately until projects exist and can be identified without ambiguity.

**Independent Test**: Can be fully tested by creating a project, viewing it in the project list, and confirming all three project identity fields are present.

**Acceptance Scenarios**:

1. **Given** no project exists for a client engagement, **When** the user creates a project with a client name, project name, and project code, **Then** the project is saved and appears as an available timesheet row.
2. **Given** the user enters a project without one of the required identity fields, **When** the user attempts to save it, **Then** the system rejects the project and identifies the missing field.

---

### User Story 2 - Record Weekly Project Days (Priority: P2)

As the timesheet owner, I want to enter the number of days spent on a project during a specific week so that my weekly work distribution is recorded.

**Why this priority**: Weekly day allocation is the core business value of the application.

**Independent Test**: Can be fully tested by selecting one existing project and one week, entering a day value, saving it, and confirming the value is retained when revisiting the same project-week cell.

**Acceptance Scenarios**:

1. **Given** an existing project and an empty week entry, **When** the user enters 2.5 days for that project and week, **Then** the system saves 2.5 days for that project-week combination.
2. **Given** an existing saved value for a project and week, **When** the user changes the value and saves, **Then** the updated value replaces the prior visible value, the project-week cell shows the latest value, and a local correction record preserves the prior value and replacement timestamp.
3. **Given** the user enters a value below 0 or above 5 days for one project in one week, **When** the user attempts to save it, **Then** the system rejects the value and explains the allowed range.
4. **Given** saved values already total 4 days for one week, **When** the user attempts to save 1.5 additional days for another project in that same week, **Then** the system rejects the change because the weekly total would exceed 5 days.

---

### User Story 3 - Review Time in Calendar Grid (Priority: P3)

As the timesheet owner, I want a calendar-style grid with projects as rows and weeks as columns so that I can review project effort across weeks at a glance.

**Why this priority**: The grid turns individual entries into a useful management view for comparison and review.

**Independent Test**: Can be fully tested by creating at least two projects, entering values across at least two weeks, and confirming the grid shows one row per project, one column per week, and the correct day values in each cell.

**Acceptance Scenarios**:

1. **Given** multiple projects with saved weekly values, **When** the user opens the calendar view, **Then** each project appears on its own row and each visible week appears as a column.
2. **Given** a project has no days recorded for a visible week, **When** the calendar view is shown, **Then** the corresponding cell appears blank and remains distinguishable from saved numeric values.
3. **Given** saved entries exist for different projects in the same week, **When** the user compares that week column, **Then** the values remain associated with their correct project rows.

### Edge Cases

- A project code that already exists must not create two indistinguishable project rows.
- A weekly entry must not be saved unless it is associated with an existing project.
- Day values must handle partial days and must reject negative, non-numeric, greater-than-five cell values, or weekly totals greater than 5 days.
- Project identity editing is outside v1; existing weekly entries remain associated with the project code saved on the entry.
- Projects cannot be removed or archived in v1, including projects with or without saved weekly entries.
- Editing a saved weekly day value replaces the visible value while retaining a local correction record that explains the prior value and replacement.
- Weeks with no recorded time must be visible or reachable with blank cells that do not imply that time has been recorded.
- The calendar view must remain usable when there are no projects, no weekly entries, or many project rows.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow the user to create a project with client name, project name, and project code.
- **FR-002**: System MUST require client name, project name, and project code before saving a project.
- **FR-003**: System MUST prevent duplicate active project codes.
- **FR-004**: System MUST display created projects as available rows in the timesheet calendar view.
- **FR-005**: System MUST allow the user to record a number of days for an existing project during a selected week.
- **FR-006**: System MUST allow partial-day values in increments of 0.25 days.
- **FR-007**: System MUST reject weekly project day values below 0 or above 5.
- **FR-008**: System MUST allow the user to update a previously saved project-week day value.
- **FR-009**: System MUST preserve saved project-week entries after the user leaves and returns to the calendar view.
- **FR-010**: System MUST present a calendar view where each row represents one project and each column represents one week.
- **FR-011**: System MUST show the recorded number of days in the cell at the intersection of a project row and a week column.
- **FR-012**: System MUST show a blank cell when no saved time entry exists for a project-week combination.
- **FR-013**: System MUST identify invalid project and time-entry input before saving and explain what the user must correct.
- **FR-014**: System MUST keep timesheet data local to the user's application environment unless a future approved specification adds export or synchronization.
- **FR-015**: System MUST prevent the sum of all project day values in the same week from exceeding 5 days.
- **FR-016**: System MUST define each timesheet week as Monday through Friday.
- **FR-017**: System MUST use only the latest saved value for each project-week entry in calendar display and weekly total calculations when a weekly day value is changed.
- **FR-019**: System MUST preserve a local correction record for each changed project-week entry containing the project code, week, prior value, replacement value, and replacement timestamp.
- **FR-018**: System MUST NOT provide project removal or project archiving in v1.

### Key Entities *(include if feature involves data)*

- **Project**: A trackable work assignment identified by client name, project name, and project code. A project can have many weekly time entries and remains active in v1 once created.
- **Week**: A Monday-through-Friday reporting period used for day allocations. A week has a stable label or date range visible to the user.
- **Weekly Time Entry**: The latest saved number of days spent on one project during one week. It belongs to exactly one project and one week.
- **Correction Record**: A local trace record created when a saved weekly time entry is changed. It explains the prior value, replacement value, project code, week, and replacement timestamp without changing what the calendar displays.
- **Calendar View**: A review surface that combines projects, weeks, and weekly time entries into a row-and-column grid.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a valid project and see it in the calendar view in under 1 minute.
- **SC-002**: A user can enter or update days for an existing project-week cell in under 30 seconds.
- **SC-003**: 100% of saved positive weekly day values appear in the correct project row and week column when the calendar view is reopened.
- **SC-004**: 100% of invalid weekly day values below 0, above 5, not numeric, or causing a weekly total above 5 are rejected before they become saved records.
- **SC-005**: A user can review at least 10 projects across at least 12 consecutive weeks without losing the ability to identify the project, week, and value for any visible cell.

## Assumptions

- The initial user is a single local operator managing their own timesheet records.
- A week is treated as a standard Monday-through-Friday 5-day working week with a visible date range.
- Partial days are useful for timesheet entry, with 0.25-day increments as the default minimum precision.
- Project codes are the unique business identifier for active projects.
- Authentication, multi-user permissions, project removal, project archiving, cloud synchronization, invoice generation, and external reporting are outside this feature's scope.
