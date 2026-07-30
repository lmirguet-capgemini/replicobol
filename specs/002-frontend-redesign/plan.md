# Implementation Plan: Frontend Redesign

**Branch**: `002-frontend-redesign` | **Date**: 2026-07-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-frontend-redesign/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Redesign the existing local timesheet frontend to follow the dashboard structure and visual language of `design.png` while preserving project creation, calendar loading, weekly entry, and save/error behavior. The implementation will retain the current dependency-free HTML, CSS, and JavaScript frontend; enhance the GNU Cobol calendar contract with backend-computed summary values; and verify the result through backend contract tests plus browser-based desktop and mobile checks.

## Technical Context

**Language/Version**: GNU Cobol 3.x; HTML5; CSS; modern browser JavaScript (ES2020-compatible); Python 3 local bridge

**Primary Dependencies**: GnuCOBOL `cobc`; browser Fetch and DOM APIs; Python standard library local server; no new runtime libraries

**Storage**: Existing local pipe-delimited files in `data/`; no schema or migration change

**Testing**: Existing POSIX shell CGI contract tests; strict JSON parsing checks; browser validation with Playwright at desktop and mobile viewports

**Target Platform**: Local Linux host with a modern desktop or mobile browser

**Project Type**: Local web application with static frontend and GNU Cobol CGI backend

**Performance Goals**: Dashboard and 12-week grid load in under 2 seconds locally; entry save feedback appears within 1 second locally; layout remains stable during loading and updates

**Constraints**: Local-first operation; no hosted dependency; no frontend duplication of backend reporting rules; preserve current CGI routes and data files; no project lifecycle, authentication, sync, or multi-user scope

**Scale/Scope**: One dashboard screen; up to 500 projects and 52 calendar weeks supported by current backend tables; acceptance target of at least 5 rows by 6 weeks on desktop and complete workflow access on mobile

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Timesheet Data Integrity — PASS**: The redesign preserves existing entries and correction history. Summary values are derived read-only from current records, and no storage migration is introduced.
- **II. Local-First Ownership — PASS**: All assets, calculations, and data remain local. No external service, account, font CDN, or hosted dependency is required.
- **III. GNU Cobol Backend Contract — PASS**: The calendar handler will compute declared days, active projects, and rolling three-month missing declarations. JavaScript only renders returned values and does not own reporting rules.
- **IV. Web Frontend Clarity — PASS**: The design explicitly includes blank, unsaved, saving, saved, invalid, and failed states plus a dedicated notification area.
- **V. Testable Evolution — PASS**: Contract tests cover the extended JSON response and summary calculations; browser checks cover the dashboard, project flow, entry flow, responsiveness, and visual reference alignment.
- **Technical Constraints — PASS**: Existing readable files and CGI boundaries remain intact. The contract extension is documented before implementation and requires no data migration.

## Project Structure

### Documentation (this feature)

```text
specs/002-frontend-redesign/
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
│   └── calendar.cob          # extend response with backend-owned summary
└── tests/
    └── contract/
        └── test_calendar.sh  # summary and JSON contract coverage

frontend/
├── index.html                # dashboard and project form structure
├── styles.css               # responsive reference-aligned visual system
└── app.js                   # rendering, period controls, API integration

scripts/
└── serve-local.sh           # existing local runtime bridge
```

**Structure Decision**: Keep the existing flat static frontend and CGI backend structure. This is one focused dashboard redesign with one contract extension; adding a frontend framework, build pipeline, component tree, or new service layer would not satisfy an unmet requirement.

## Complexity Tracking

No constitution violations require justification.

## Post-Design Constitution Re-evaluation

- **Timesheet Data Integrity — PASS**: [data-model.md](data-model.md) leaves all persistent records unchanged and defines summary values from latest visible weekly entries only.
- **Local-First Ownership — PASS**: [research.md](research.md) selects browser-native assets and the existing local runtime with no hosted dependency.
- **GNU Cobol Backend Contract — PASS**: [contracts/calendar-dashboard-contract.md](contracts/calendar-dashboard-contract.md) assigns all dashboard totals and missing-declaration reporting to `calendar.cob` through an additive response extension.
- **Web Frontend Clarity — PASS**: The data model defines explicit cell and notification states, including unsaved values, and [quickstart.md](quickstart.md) validates them across desktop and mobile layouts.
- **Testable Evolution — PASS**: The quickstart combines existing contract execution, new summary assertions, strict JSON checks, real browser save/create flows, and responsive visual validation.
- **Technical Constraints — PASS**: No file format, storage layout, deployment model, or existing request contract changes. No migration or rollback procedure is required because this feature adds read-only derived response fields and presentation changes only.
