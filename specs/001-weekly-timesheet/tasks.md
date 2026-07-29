# Tasks: Weekly Timesheet

**Input**: Design documents from `/specs/001-weekly-timesheet/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/cgi-contract.md](contracts/cgi-contract.md), [quickstart.md](quickstart.md)

**Tests**: Backend contract tests are included because the plan and constitution require executable validation for Cobol business rules and frontend/backend contract changes.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

**Constitution Traceability**: Local readable data files satisfy Local-First Ownership; GNU Cobol CGI handlers and copybooks own validation/calculation rules; frontend tasks only render documented contract states; backend contract tests and smoke checks provide executable validation; correction records satisfy Timesheet Data Integrity for changed entries.

**Requirement Coverage**: FR-001-FR-004 map to US1 tasks T012-T018; FR-005-FR-009 and FR-015-FR-017 plus FR-019 map to US2 tasks T019-T026; FR-010-FR-012 map to US3 tasks T027-T033; FR-013 maps to validation helpers and UI state tasks T008-T009, T012, T019, T024-T025; FR-014 maps to local data tasks T002, T010, T020, and T037; FR-018 maps to no project editing/removal/archive review in T038; SC-001-SC-005 map to T035-T036 final validation.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the project skeleton and local runtime scaffolding.

- [X] T001 Create project directory marker files in `backend/cgi/.gitkeep`, `backend/copybooks/.gitkeep`, `backend/tests/contract/.gitkeep`, `backend/tests/fixtures/.gitkeep`, `frontend/.gitkeep`, `data/.gitkeep`, and `scripts/.gitkeep`
- [X] T002 [P] Add local data file placeholders with header comments in `data/projects.dat`, `data/weekly-entries.dat`, and `data/weekly-entry-corrections.dat`
- [X] T003 [P] Add build output and local data guidance to `.gitignore`
- [X] T004 Create GNU Cobol build script in `scripts/build.sh`
- [X] T005 Create local CGI development server script in `scripts/serve-local.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish shared record layouts, CGI response conventions, fixtures, and executable test harnesses needed by all stories.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T006 [P] Define project record layout in `backend/copybooks/project-record.cpy`
- [X] T007 [P] Define weekly entry and correction record layouts in `backend/copybooks/weekly-entry-record.cpy` and `backend/copybooks/correction-record.cpy`
- [X] T008 [P] Define CGI response envelope helpers in `backend/copybooks/cgi-response.cpy`
- [X] T009 [P] Define form-decoding and field-validation helpers in `backend/copybooks/cgi-form.cpy`
- [X] T010 [P] Create shared backend fixture reset data in `backend/tests/fixtures/empty-data.sh`
- [X] T011 Create backend contract test runner in `scripts/test-backend.sh`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Create Trackable Projects (Priority: P1) MVP

**Goal**: User can create a project with client name, project name, and project code, then see it as an available timesheet row.

**Independent Test**: Run the US1 contract test, then create a project through the web UI and confirm it appears in the project list/calendar row set.

### Tests for User Story 1

- [X] T012 [P] [US1] Add project create/list contract tests for `POST /cgi-bin/projects` and `GET /cgi-bin/projects` in `backend/tests/contract/test_projects.sh`

### Implementation for User Story 1

- [X] T013 [P] [US1] Implement project data read/write routines in `backend/copybooks/project-storage.cpy`
- [X] T014 [US1] Implement project create/list CGI handler in `backend/cgi/projects.cob`
- [X] T015 [P] [US1] Build project creation form markup in `frontend/index.html`
- [X] T016 [P] [US1] Style project creation and validation states in `frontend/styles.css`
- [X] T017 [US1] Implement project create/list browser logic in `frontend/app.js`
- [X] T018 [US1] Wire `scripts/build.sh` to compile `backend/cgi/projects.cob`

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Record Weekly Project Days (Priority: P2)

**Goal**: User can save and update latest visible day values for an existing project during a Monday-Friday week while preserving the 5-day weekly total rule and local correction history.

**Independent Test**: Run the US2 contract test with fixture projects, then save and update a project-week cell through the UI and confirm invalid values are rejected.

### Tests for User Story 2

- [X] T019 [P] [US2] Add weekly entry contract tests for `POST /cgi-bin/timesheet`, including correction-record creation on updates, in `backend/tests/contract/test_timesheet.sh`

### Implementation for User Story 2

- [X] T020 [P] [US2] Implement weekly entry read/write routines and correction-record append logic in `backend/copybooks/weekly-entry-storage.cpy`
- [X] T021 [P] [US2] Implement Monday date and 5-day week validation helpers in `backend/copybooks/week-validation.cpy`
- [X] T022 [US2] Implement weekly entry save/update CGI handler in `backend/cgi/timesheet.cob`
- [X] T023 [US2] Add editable day-cell inputs and save status placeholders to `frontend/index.html`
- [X] T024 [US2] Implement weekly entry save/update browser logic and validation message rendering in `frontend/app.js`
- [X] T025 [US2] Add saved, invalid, and failed cell styles in `frontend/styles.css`
- [X] T026 [US2] Wire `scripts/build.sh` to compile `backend/cgi/timesheet.cob`

**Checkpoint**: User Stories 1 and 2 work independently with backend validation.

---

## Phase 5: User Story 3 - Review Time in Calendar Grid (Priority: P3)

**Goal**: User can review a calendar grid with one row per project, one column per week, saved values in matching cells, and blank cells where no entry exists.

**Independent Test**: Run the US3 contract test with multiple projects and weeks, then open the calendar UI and verify rows, week columns, saved values, and blank cells.

### Tests for User Story 3

- [X] T027 [P] [US3] Add calendar contract tests for `GET /cgi-bin/calendar` in `backend/tests/contract/test_calendar.sh`

### Implementation for User Story 3

- [X] T028 [P] [US3] Implement calendar assembly routines in `backend/copybooks/calendar-view.cpy`
- [X] T029 [US3] Implement calendar CGI handler in `backend/cgi/calendar.cob`
- [X] T030 [US3] Build calendar grid markup and week navigation containers in `frontend/index.html`
- [X] T031 [US3] Implement calendar loading, row rendering, week header rendering, and blank-cell display in `frontend/app.js`
- [X] T032 [US3] Style the project-by-week calendar grid for at least 10 projects and 12 weeks in `frontend/styles.css`
- [X] T033 [US3] Wire `scripts/build.sh` to compile `backend/cgi/calendar.cob`

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, documentation alignment, and cleanup across the completed feature.

- [X] T034 [P] Update validation instructions and local server notes in `specs/001-weekly-timesheet/quickstart.md`
- [X] T035 Run backend contract validation via `scripts/test-backend.sh`
- [X] T036 Run local web smoke validation and local timing checks from `specs/001-weekly-timesheet/quickstart.md`
- [X] T037 [P] Review generated data files for readable local recovery format in `data/projects.dat`, `data/weekly-entries.dat`, and `data/weekly-entry-corrections.dat`
- [X] T038 Confirm no project editing/removal/archive controls or backend routes exist in `frontend/index.html`, `frontend/app.js`, `backend/cgi/projects.cob`, and `specs/001-weekly-timesheet/contracts/cgi-contract.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies.
- **Phase 2 Foundational**: Depends on Phase 1; blocks all user stories.
- **Phase 3 US1**: Depends on Phase 2; delivers MVP project creation.
- **Phase 4 US2**: Depends on Phase 2 and uses projects from US1 or fixtures for independent testing.
- **Phase 5 US3**: Depends on Phase 2 and uses projects/entries from US1/US2 or fixtures for independent testing.
- **Phase 6 Polish**: Depends on completed desired user stories.

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational; no dependency on other stories.
- **US2 (P2)**: Can start after Foundational using fixture projects; integrates naturally with US1 project records.
- **US3 (P3)**: Can start after Foundational using fixture projects and entries; integrates naturally with US1/US2 data.

### Within Each User Story

- Contract tests precede implementation and must fail before the story implementation is complete.
- Copybook/storage routines precede CGI handlers.
- CGI handlers precede frontend integration.
- Build script updates precede backend contract validation.

---

## Parallel Opportunities

- T002 and T003 can run in parallel after T001.
- T006, T007, T008, T009, and T010 can run in parallel after setup.
- T012 can be written while T013, T015, and T016 are implemented because they touch different files.
- T019 can be written while T020 and T021 are implemented because they touch different files.
- T027 can be written while T028 and T032 are implemented because they touch different files.
- After Phase 2, US1, US2, and US3 can be developed in parallel with fixture data, then integrated in priority order.

## Parallel Example: User Story 1

```bash
Task: "T012 [P] [US1] Add project create/list contract tests for POST /cgi-bin/projects and GET /cgi-bin/projects in backend/tests/contract/test_projects.sh"
Task: "T013 [P] [US1] Implement project data read/write routines in backend/copybooks/project-storage.cpy"
Task: "T015 [P] [US1] Build project creation form markup in frontend/index.html"
Task: "T016 [P] [US1] Style project creation and validation states in frontend/styles.css"
```

## Parallel Example: User Story 2

```bash
Task: "T019 [P] [US2] Add weekly entry contract tests for POST /cgi-bin/timesheet in backend/tests/contract/test_timesheet.sh"
Task: "T020 [P] [US2] Implement weekly entry data read/write routines in backend/copybooks/weekly-entry-storage.cpy"
Task: "T021 [P] [US2] Implement Monday date and 5-day week validation helpers in backend/copybooks/week-validation.cpy"
```

## Parallel Example: User Story 3

```bash
Task: "T027 [P] [US3] Add calendar contract tests for GET /cgi-bin/calendar in backend/tests/contract/test_calendar.sh"
Task: "T028 [P] [US3] Implement calendar assembly routines in backend/copybooks/calendar-view.cpy"
Task: "T032 [US3] Style the project-by-week calendar grid for at least 10 projects and 12 weeks in frontend/styles.css"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 Setup.
2. Complete Phase 2 Foundational.
3. Complete Phase 3 User Story 1.
4. Validate with `backend/tests/contract/test_projects.sh` through `scripts/test-backend.sh`.
5. Demo project creation and project listing in the local web UI.

### Incremental Delivery

1. Complete Setup and Foundational phases.
2. Deliver US1 project creation and validate independently.
3. Deliver US2 weekly entry saving and validate independently.
4. Deliver US3 calendar review and validate independently.
5. Run quickstart validation across all stories.

### Parallel Team Strategy

1. One developer completes shared setup/build/test harness tasks.
2. Backend-focused work proceeds on Cobol copybooks and CGI handlers.
3. Frontend-focused work proceeds on static markup, styles, and browser integration.
4. Contract tests remain the merge gate for each story.

## Notes

- `[P]` tasks touch different files and can run in parallel once their phase prerequisites are met.
- `[US1]`, `[US2]`, and `[US3]` map tasks to the prioritized user stories in [spec.md](spec.md).
- Tasks deliberately avoid project removal/archive work because v1 explicitly excludes it.
- Contract tests are included to satisfy the constitution's executable validation requirement.