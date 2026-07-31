# Implementation Plan: Timesheet Grid Usability and Totals

**Branch**: `[003-grid-usability-totals]` | **Date**: 2026-07-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-grid-usability-totals/spec.md`

## Summary

Improve the 12-week dashboard grid so it gives immediate weekly context without changing the time-entry workflow. Extend the `calendar` CGI response with backend-calculated default-period context, ISO headers, week totals/statuses, and project lifetime totals. The frontend renders those supplied values and retains only interaction and display behavior. Preserve the existing readable pipe-delimited storage format and all existing routes.

## Technical Context

**Language/Version**: GNU Cobol 3.x CGI handlers; browser-native HTML, CSS, and JavaScript; Python 3 local development bridge

**Primary Dependencies**: GNU Cobol `cobc`; browser Fetch and DOM APIs; Lucide UMD asset already used by the dashboard; no new runtime dependency

**Storage**: Existing local pipe-delimited `data/projects.dat`, `data/weekly-entries.dat`, and `data/weekly-entry-corrections.dat`; no format change

**Testing**: Shell CGI contract tests under `backend/tests/contract/`; `./scripts/test-backend.sh`; browser validation through `./scripts/serve-local.sh` and desktop viewport checks

**Target Platform**: Local Linux/Unix-like workstation using a modern browser

**Project Type**: Local web application with static frontend and CGI backend

**Performance Goals**: Render all 12 columns and project rows without horizontal scroll at 1440px desktop width; preserve current local save responsiveness

**Constraints**: Local-first; no cloud or account dependency; Cobol owns every calendar, aggregation, latest-value, and period-status computation; frontend only renders backend-provided calendar values and user interaction state; no storage migration; mobile may retain horizontal grid scrolling

**Scale/Scope**: One calendar CGI endpoint, one native dashboard screen, 1-52 requested weeks, and the existing 500-entry in-memory calendar table

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Plan Compliance | Result |
|-----------|-----------------|--------|
| I. Timesheet Data Integrity | Lifetime totals use each project-week's latest visible saved declaration; no entry mutation or new ambiguous data is introduced. | PASS |
| II. Local-First Ownership | Uses existing local files, CGI routes, and browser assets; no network service is introduced for core behavior. | PASS |
| III. GNU Cobol Backend Contract | Cobol calculates default-range placement, ISO week data, current-week flags, period totals/statuses, and project lifetime totals; frontend renders documented response fields only. | PASS |
| IV. Web Frontend Clarity | The plan makes current week, overdue weekly declarations, blank values, hover state, and edit state directly inspectable. | PASS |
| V. Testable Evolution | Adds strict CGI contract coverage for lifetime totals and documented desktop/browser scenarios for presentation behavior. | PASS |

**Post-design re-check**: PASS. The contract extends rather than replaces existing response fields, and all reporting aggregation remains in GNU Cobol.

## Project Structure

### Documentation (this feature)

```text
specs/003-grid-usability-totals/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
backend/
├── cgi/
│   └── calendar.cob                 # calendar data, latest visible entries, lifetime totals
└── tests/
    ├── contract/test_calendar.sh    # strict JSON and total semantics
    └── fixtures/dashboard-data.sh   # deterministic cross-period data

frontend/
├── app.js                           # default range, grid rendering, cell interaction
├── index.html                       # existing dashboard grid container
└── styles.css                       # compact columns and visual states

scripts/
├── test-backend.sh                  # full contract suite
└── serve-local.sh                   # browser validation bridge
```

**Structure Decision**: Extend the existing static frontend and `calendar` CGI handler in place. No new application module or data store is needed.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
