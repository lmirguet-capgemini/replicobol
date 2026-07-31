# Tasks: Timesheet Grid Usability and Totals

**Input**: Design documents from `/specs/003-grid-usability-totals/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), and [calendar contract](contracts/calendar-grid-totals-contract.md)

**Tests**: Contract tests are included because this feature extends the CGI reporting contract and preserves calculation semantics. Browser validation follows the recorded procedures in [quickstart.md](quickstart.md).

**Organization**: Tasks are grouped by user story so each increment can be implemented and verified independently.

## Phase 1: Setup (Shared Test Data)

**Purpose**: Create deterministic data that exercises the feature's cross-story reporting and visual states without changing persistent storage format.

- [X] T001 Update deterministic grid scenarios in `backend/tests/fixtures/dashboard-data.sh` with inside/outside-period values, zero values, exactly-5, past-below-5, future-below-5, and latest-visible correction cases

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Extend the existing `GET /cgi-bin/calendar` contract so GNU Cobol owns all default-period, calendar, total, and status calculations before any frontend rendering work begins.

- [X] T002 Add failing strict JSON assertions for backend-calculated default periods, ISO week numbers, current-week flags, period totals/statuses, lifetime totals, selected-period isolation, zero declarations, and latest-visible corrections in `backend/tests/contract/test_calendar.sh`
- [X] T003 Implement GNU Cobol calculation and emission of the default period, `iso_week_number`, `is_current_week`, `period_total_days`, `period_total_status`, and `lifetime_total_days` in `backend/cgi/calendar.cob`

**Checkpoint**: T001-T003 provide a strict, backend-authoritative calendar contract; frontend story work can begin.

---

## Phase 3: User Story 1 - Scan the Current Weekly Grid (Priority: P1) MVP

**Goal**: Make the default 12-week grid immediately readable through local current-week context, ISO headers, and clear period-total state.

**Independent Test**: Load the fixture-backed default period at a 1440px-or-wider viewport and verify the current week is second-to-last and highlighted, headers have ISO week/date lines, and exactly-5, past-below-5, and future/current-below-5 totals use the required treatments.

### Implementation for User Story 1

- [X] T004 [US1] Request the backend-selected default period when no explicit start week is selected and retain explicit period requests in `frontend/app.js`
- [X] T005 [US1] Render backend-provided ISO headers, current-week flags, period totals, and period-total status values without client-side calendar or total computation in `frontend/app.js`
- [X] T006 [US1] Add compact 12-column, two-line-header, current-week-column, and backend-status color styles in `frontend/styles.css` for a 1440px desktop viewport
- [X] T007 [US1] Validate backend-provided current-week placement, header labels, status colors, and no desktop horizontal scroll using `specs/003-grid-usability-totals/quickstart.md`

**Checkpoint**: The default grid can be scanned for current-week context and weekly declaration status without editing a cell.

---

## Phase 4: User Story 2 - Review Project Lifetime Totals (Priority: P2)

**Goal**: Show each project’s all-time latest-visible declared days while preserving existing selected-period totals.

**Independent Test**: With one declaration inside and one outside the requested range, verify strict calendar JSON returns distinct selected-period and lifetime totals, then confirm the visible project Total uses the lifetime value while the period-total row excludes the outside declaration.

### Implementation for User Story 2

- [X] T008 [US2] Render backend-provided `row.lifetime_total_days` in the project Total column while retaining backend-provided selected-period values in `frontend/app.js`
- [X] T009 [US2] Run and correct calendar contract coverage for lifetime and selected-period totals with `backend/tests/contract/test_calendar.sh`

**Checkpoint**: Project totals represent all recorded time, selected-period rows remain scoped to displayed weeks, and the calendar response stays backward compatible.

---

## Phase 5: User Story 3 - Read and Edit Grid Cells Without Visual Noise (Priority: P3)

**Goal**: Keep missing and zero values visually quiet while preserving intentional click-to-edit and all existing save feedback states.

**Independent Test**: Load blank and zero cells, hover without seeing an input, then activate one cell and verify only that cell enters the existing edit/save lifecycle.

### Implementation for User Story 3

- [X] T010 [US3] Render absent and zero backend-provided `display_value` cells as empty buttons while preserving their numeric dataset values and accessible edit labels in `frontend/app.js`
- [X] T011 [P] [US3] Add non-editing hover and keyboard-focus feedback for project-week buttons without exposing inputs in `frontend/styles.css`
- [X] T012 [US3] Confirm click-to-edit retains unsaved, saved, invalid, and failed feedback for blank, zero, and populated cells using `specs/003-grid-usability-totals/quickstart.md`

**Checkpoint**: Empty cells are quiet until deliberately selected, and existing weekly-entry persistence feedback remains intact.

---

## Phase 6: Polish and Cross-Cutting Validation

**Purpose**: Verify the complete feature preserves backend and browser behavior.

- [X] T013 Run the complete backend build and contract suite with `scripts/test-backend.sh`
- [X] T014 Run the full 1440px desktop and period-change validation checklist in `specs/003-grid-usability-totals/quickstart.md`

---

## Dependencies and Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001 can begin immediately.
- **Foundational (Phase 2)**: T002 must fail before T003. T003 blocks all frontend story work.
- **User Story 1 (Phase 3)**: T004 through T007 run in order after T003.
- **User Story 2 (Phase 4)**: T008 follows T003; T009 verifies its completed rendering and contract coverage. It does not depend on User Story 1.
- **User Story 3 (Phase 5)**: T010 and T011 follow T003; T012 follows both. It does not depend on User Stories 1 or 2.
- **Polish (Phase 6)**: T013 and T014 follow all desired story phases.

### User Story Dependencies

- **US1 (P1)**: Depends on the backend-authoritative calendar contract in T003. It is the recommended MVP.
- **US2 (P2)**: Depends on the backend-authoritative calendar contract in T003.
- **US3 (P3)**: Depends on T003 and the existing click-to-edit event handling.

### Parallel Opportunities

- T010 and T011 can run in parallel because they change `frontend/app.js` and `frontend/styles.css` respectively.
- After T003, US2's frontend rendering can proceed in parallel with US1's frontend work.
- US3 can also proceed after T003, provided its `frontend/app.js` edits are coordinated with US1 and US2 changes to that file.

## Parallel Execution Examples

### Foundational Cobol Contract

```text
Task: "Add failing strict JSON assertions in backend/tests/contract/test_calendar.sh"
Task: "Implement lifetime total aggregation in backend/cgi/calendar.cob"
```

Run the assertion task first; Cobol implementation starts after its expected failure is confirmed.

### User Story 3

```text
Task: "Render blank and zero cells in frontend/app.js"
Task: "Add hover and focus styles in frontend/styles.css"
```

## Implementation Strategy

### MVP First

1. Complete T001.
2. Complete the backend contract work in T002 and T003.
3. Complete T004 through T007 for US1.
4. Validate the default grid at 1440px before continuing.

### Incremental Delivery

1. Deliver US1 for fast weekly scanning.
2. Deliver US2 for backend-authoritative lifetime totals and strict contract protection.
3. Deliver US3 for quieter cell presentation without changing save behavior.
4. Run T013 and T014 before declaring the full feature complete.

## Format Validation

Every implementation task uses the required checkbox, sequential task ID, optional parallel marker, user-story label for story work, and an exact file path.