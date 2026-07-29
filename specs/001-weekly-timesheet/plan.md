# Implementation Plan: Weekly Timesheet

**Branch**: `001-weekly-timesheet` | **Date**: 2026-07-29 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-weekly-timesheet/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Build Replicobol as a local weekly timesheet application with a static web frontend and an authoritative GNU Cobol backend. The feature supports creating active projects, entering latest visible weekly day allocations in 0.25-day increments, enforcing Monday-Friday 5-day weekly totals, preserving local correction records for changed entries, and reviewing values in a project-by-week calendar grid. The backend will expose CGI-style request handlers with a documented form/JSON contract and persist readable local data files.

## Technical Context

**Language/Version**: GNU Cobol 3.x for backend business rules; HTML5, CSS3, and vanilla JavaScript for the web frontend

**Primary Dependencies**: GnuCOBOL compiler/runtime; a local CGI-capable web server for development/runtime hosting; no frontend framework

**Storage**: Local readable data files under `data/` using pipe-delimited records for projects, weekly entries, and weekly-entry correction records

**Testing**: Shell-based backend contract tests invoking compiled Cobol CGI handlers with controlled environment/stdin; browser-based manual smoke checks documented in quickstart

**Target Platform**: Local Linux workstation

**Project Type**: Local web application with CGI-style Cobol backend

**Performance Goals**: Calendar view loads 10 projects across 12 weeks in under 2 seconds on a local machine; project creation and weekly entry save complete in under 1 second locally

**Constraints**: Local-first operation; no cloud, authentication, multi-user, project editing, removal/archive, external reporting, or framework dependency in v1; weekly totals capped at 5 days; project-week entries display and calculate with the latest value while changed entries append local correction records

**Scale/Scope**: Single local operator; at least 10 active projects and 12 visible consecutive weeks for v1 validation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Timesheet Data Integrity**: PASS. Project identity, project-week entries, 5-day weekly total validation, latest-visible update behavior, correction records for changed entries, and blank no-entry cells are explicit in the spec and will be enforced by the Cobol backend contract.
- **Local-First Ownership**: PASS. Storage is local readable files; no hosted service, account, cloud sync, or network dependency is required for core time recording.
- **GNU Cobol Backend Contract**: PASS. Business rules are planned in GNU Cobol CGI-style handlers; frontend behavior depends on documented request/response contracts.
- **Web Frontend Clarity**: PASS. Plan includes a calendar grid and save/invalid/error UI states tied to backend responses.
- **Testable Evolution**: PASS. Backend contract tests cover business rules; quickstart includes end-to-end validation for project creation, weekly entry, and calendar review.

## Project Structure

### Documentation (this feature)

```text
specs/001-weekly-timesheet/
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
│   ├── projects.cob
│   ├── timesheet.cob
│   └── calendar.cob
├── copybooks/
│   ├── project-record.cpy
│   ├── weekly-entry-record.cpy
│   └── correction-record.cpy
└── tests/
    ├── contract/
    └── fixtures/

frontend/
├── index.html
├── styles.css
└── app.js

data/
├── projects.dat
├── weekly-entries.dat
└── weekly-entry-corrections.dat

scripts/
├── build.sh
├── test-backend.sh
└── serve-local.sh
```

**Structure Decision**: Use a split local web structure: `backend/` contains GNU Cobol CGI handlers and shared record copybooks, `frontend/` contains static assets, `data/` stores readable local records, and `scripts/` provides reproducible build/test/run commands. This keeps business rules in Cobol while keeping the frontend decoupled through documented contracts.

## Complexity Tracking

No constitution violations require complexity justification.

## Post-Design Constitution Check

*GATE: Re-check after Phase 1 design.*

- **Timesheet Data Integrity**: PASS. [data-model.md](data-model.md) defines project identity, Monday-Friday weeks, latest visible entries, correction records for changed entries, blank cells, and 5-day total validation; [contracts/cgi-contract.md](contracts/cgi-contract.md) exposes validation failures for impossible records.
- **Local-First Ownership**: PASS. [research.md](research.md) selects local pipe-delimited files and rejects hosted or cloud-dependent storage.
- **GNU Cobol Backend Contract**: PASS. [contracts/cgi-contract.md](contracts/cgi-contract.md) defines the Cobol CGI request/response boundary, with validation owned by backend handlers.
- **Web Frontend Clarity**: PASS. [quickstart.md](quickstart.md) requires visible saved, blank, invalid, and failed states through the local web smoke test.
- **Testable Evolution**: PASS. [quickstart.md](quickstart.md) specifies executable backend contract checks plus browser smoke validation for the user flows.
