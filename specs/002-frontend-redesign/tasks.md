# Tasks: Frontend Redesign

**Input**: Design documents from `/specs/002-frontend-redesign/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/calendar-dashboard-contract.md`, `quickstart.md`

**Tests**: Backend contract tasks and browser validation tasks are included because the specification requires existing behavior checks, strict contract validation, desktop/mobile usability, and real save/create workflows.

**Organization**: Tasks are grouped by user story so the dashboard grid, summary information, and project creation can be implemented and validated as incremental slices.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches a different file and does not depend on an incomplete task
- **[Story]**: Maps the task to a user story from `spec.md`
- Every task includes the exact file path or validation artifact it operates on

## Phase 1: Setup (Shared Test Data)

**Purpose**: Provide repeatable local data for contract and browser validation without changing production storage formats

- [X] T001 Create a deterministic five-project dashboard fixture with visible-period entries and rolling-window weeks in `backend/tests/fixtures/dashboard-data.sh`

---

## Phase 2: Foundational (Blocking Contract Prerequisites)

**Purpose**: Add the backend-owned period totals required by the dashboard grid before frontend story work begins

**CRITICAL**: Complete this phase before implementing any user story.

- [X] T002 Add failing strict-JSON assertions for additive `rows[].total_days` and `period_total_days` fields in `backend/tests/contract/test_calendar.sh`
- [X] T003 Implement row totals and selected-period total calculation and JSON output in `backend/cgi/calendar.cob`
- [X] T004 Run `./scripts/test-backend.sh` and reconcile any documented response mismatch in `specs/002-frontend-redesign/contracts/calendar-dashboard-contract.md`

**Checkpoint**: The existing calendar contract remains compatible and exposes valid backend-computed totals.

---

## Phase 3: User Story 1 - Work From A Dashboard-Style Timesheet (Priority: P1) MVP

**Goal**: Deliver the reference-aligned dashboard shell and editable project-week grid with visible project identity, week labels, row totals, period totals, period controls, and save states.

**Independent Test**: Open the app with dashboard fixture data and verify the desktop scenario in `specs/002-frontend-redesign/quickstart.md`, including a valid entry save and persisted reload.

### Implementation for User Story 1

- [X] T005 [P] [US1] Replace the page structure with semantic sidebar, dashboard header, period toolbar, notification region, and timesheet workspace markup in `frontend/index.html`
- [X] T006 [P] [US1] Implement the reference-aligned visual foundation, stable dashboard dimensions, dense table layout, and blank/unsaved/saving/saved/invalid/failed states in `frontend/styles.css`
- [X] T007 [US1] Render the selected period label, project rows, week cells, row totals, and final period-total row from backend data in `frontend/app.js`
- [X] T008 [US1] Mark changed week cells as unsaved before submission, then preserve valid-save, validation-error, transport-failure, and reload behavior while routing all feedback through the notification region in `frontend/app.js`
- [X] T009 [US1] Execute the desktop grid and entry-save scenario from `specs/002-frontend-redesign/quickstart.md` and capture the reference comparison screenshot at `specs/002-frontend-redesign/artifacts/us1-desktop.png`

**Checkpoint**: The dashboard-style timesheet is independently usable with the existing project and save contracts.

---

## Phase 4: User Story 2 - See High-Level Timesheet Progress At A Glance (Priority: P2)

**Goal**: Show backend-owned declared days, active projects, and rolling-three-month missing declarations, while using the reference status element as application notification feedback.

**Independent Test**: Load fixture weeks totaling exactly 5, below 5, and 0 days and verify the summary counts, rolling window dates, and notification behavior without inspecting grid cells.

### Tests for User Story 2

- [X] T010 [US2] Add failing contract cases for `summary.declared_days`, `active_projects`, rolling three-calendar-month boundaries, complete 5-day weeks, incomplete weeks, empty weeks, and valid unsigned JSON in `backend/tests/contract/test_calendar.sh`

### Implementation for User Story 2

- [X] T011 [US2] Compute the current-week anchor, rolling three-calendar-month Monday window, weekly totals, and missing-declaration count in `backend/cgi/calendar.cob`
- [X] T012 [US2] Emit the additive `summary` object with declared days, active projects, missing declarations, and window dates in `backend/cgi/calendar.cob`
- [X] T013 [US2] Add accessible summary metric markup and value hooks to the dashboard in `frontend/index.html`
- [X] T014 [US2] Render backend summary values, refresh them after successful entry saves, and keep notification state separate from summary state in `frontend/app.js`
- [X] T015 [US2] Style summary metrics and notification states to match the hierarchy and compact proportions of `design.png` in `frontend/styles.css`
- [X] T016 [US2] Execute the summary and notification scenarios from `specs/002-frontend-redesign/quickstart.md` and record observed values in `specs/002-frontend-redesign/artifacts/us2-summary-validation.md`

**Checkpoint**: Dashboard progress is understandable at a glance and all reporting rules remain owned by GNU Cobol.

---

## Phase 5: User Story 3 - Manage Projects From The Same Visual System (Priority: P3)

**Goal**: Integrate project creation into the dashboard visual system without adding project editing, deletion, archiving, or lifecycle management.

**Independent Test**: Open the project creation flow, create a valid project, verify its new grid row, then submit invalid and duplicate data and verify localized errors while the grid remains usable.

### Implementation for User Story 3

- [X] T017 [P] [US3] Replace the always-visible project form with an accessible dashboard project-creation dialog or drawer in `frontend/index.html`
- [X] T018 [P] [US3] Style the project action, focused creation surface, field errors, and desktop/mobile states in `frontend/styles.css`
- [X] T019 [US3] Implement open, close, focus restoration, submit, success refresh, and localized validation behavior for project creation in `frontend/app.js`
- [ ] T020 [US3] Execute the valid, duplicate, and incomplete project scenarios from `specs/002-frontend-redesign/quickstart.md` and record results in `specs/002-frontend-redesign/artifacts/us3-project-validation.md`

**Checkpoint**: All three stories are independently functional and visually coherent.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Complete responsive, accessibility, regression, and documentation validation across all stories

- [X] T021 [P] Add narrow-viewport navigation, summary reflow, toolbar wrapping, sticky project identity, horizontal grid scrolling, and text-overflow safeguards in `frontend/styles.css`
- [X] T022 [P] Add or verify labels, live-region semantics, keyboard focus order, dialog focus handling, and descriptive controls in `frontend/index.html`
- [X] T023 Run `./scripts/test-backend.sh` and document the final contract result in `specs/002-frontend-redesign/artifacts/backend-validation.md`
- [ ] T024 Execute desktop 1440x900 and mobile 390x844 browser checks from `specs/002-frontend-redesign/quickstart.md`, verify no overlap or blank rendering, and save screenshots under `specs/002-frontend-redesign/artifacts/`
- [ ] T025 Measure dashboard load and entry-save timing against the plan goals and record results in `specs/002-frontend-redesign/artifacts/performance-validation.md`
- [X] T026 [P] Update frontend usage and design-reference notes in `README.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 - Setup**: Starts immediately.
- **Phase 2 - Foundational**: Depends on T001 and blocks all user-story work.
- **Phase 3 - US1**: Depends on Phase 2 and forms the MVP dashboard.
- **Phase 4 - US2**: Depends on Phase 2 contract foundations; frontend tasks T013-T015 integrate with the US1 shell, while backend tasks T010-T012 may begin after Phase 2.
- **Phase 5 - US3**: Depends on the US1 dashboard shell for integration; project API behavior itself remains unchanged.
- **Phase 6 - Polish**: Depends on all stories selected for delivery.

### User Story Dependencies

- **US1 (P1)**: Requires only the foundational total fields and delivers the MVP.
- **US2 (P2)**: Backend summary work is independent after Phase 2; frontend rendering integrates into the US1 dashboard.
- **US3 (P3)**: Reuses the existing project contract and integrates its focused creation flow into the US1 dashboard.

### Within Each User Story

- Contract tests must be added and observed failing before their backend implementation.
- Semantic HTML and CSS may proceed in parallel when they touch different files.
- JavaScript rendering follows the required markup and backend response fields.
- Browser validation follows implementation and must exercise real CGI requests.

### Parallel Opportunities

- T005 and T006 can run in parallel for the US1 shell and visual foundation.
- After Phase 2, T010-T012 backend summary work can proceed while US1 frontend work is underway.
- T017 and T018 can run in parallel for the US3 creation surface.
- T021, T022, and T026 can run in parallel after story implementation because they touch different files.

---

## Parallel Example: User Story 1

```text
Task T005: Replace the page structure in frontend/index.html
Task T006: Implement the visual foundation in frontend/styles.css
```

After both complete:

```text
Task T007: Render the grid and totals in frontend/app.js
Task T008: Preserve save and notification behavior in frontend/app.js
```

## Parallel Example: User Story 2

```text
Task T010: Add summary contract cases in backend/tests/contract/test_calendar.sh
Task T013: Add summary metric markup in frontend/index.html after the response hooks are known
Task T015: Style summary metrics in frontend/styles.css after the markup contract is established
```

## Parallel Example: User Story 3

```text
Task T017: Add the project creation surface in frontend/index.html
Task T018: Style the project creation surface in frontend/styles.css
```

After both complete:

```text
Task T019: Implement project creation interactions in frontend/app.js
```

---

## Implementation Strategy

### MVP First

1. Complete T001-T004 to establish deterministic data and additive total fields.
2. Complete T005-T009 for User Story 1.
3. Stop and validate the desktop dashboard and entry-save workflow.
4. Demo or deploy the redesigned timesheet grid before adding summary and project-flow refinements.

### Incremental Delivery

1. **Foundation**: Deterministic fixture plus compatible backend totals.
2. **US1 MVP**: Dashboard shell, grid, totals, period controls, and save states.
3. **US2**: Backend-owned dashboard progress and notification treatment.
4. **US3**: Integrated project creation flow.
5. **Polish**: Mobile, accessibility, performance, complete regression, and documentation.

### Requirement Coverage

| Requirement | Tasks |
|-------------|-------|
| FR-001 | T005, T006, T013, T015, T017, T018 |
| FR-002 | T007, T008, T019, T023, T024 |
| FR-003 | T002, T003, T007 |
| FR-004 | T005, T007 |
| FR-005 | T010-T016 |
| FR-006 | T006, T008, T024 |
| FR-007 | T017-T020 |
| FR-008 | T005, T007, T017, T019 |
| FR-009 | T021, T022, T024 |
| FR-010 | T017-T020, T026 |
| FR-011 | T002-T004, T010-T012, T023 |
| FR-012 | T005, T008, T014, T015, T024 |

## Notes

- The `data/` format and existing request contracts must not change.
- The frontend must render backend-provided summary values rather than recomputing reporting rules.
- `design.png` is a direction for hierarchy and visual language; unsupported reference controls must not be implemented.
- Tests and browser checks reset or modify local fixture data, so preserve user data before validation.
- Commit after each task or coherent task group.
