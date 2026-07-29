# Research: Weekly Timesheet

## Decision: GNU Cobol CGI Handlers Own Business Rules

The backend will be implemented as GNU Cobol CGI-style handlers that read request data from CGI environment variables/stdin and write HTTP-compatible responses to stdout.

**Rationale**: This keeps project creation, weekly-entry validation, calendar data assembly, and saved-record behavior inside GNU Cobol as required by the constitution. CGI is a simple, well-understood boundary for local web applications and avoids introducing a second backend language for business rules.

**Alternatives considered**:
- Node.js or Python HTTP backend calling Cobol helpers: rejected because it risks moving validation and orchestration out of Cobol.
- A custom Cobol socket server: rejected because it increases implementation complexity without improving the v1 local workflow.
- Command-line-only Cobol application: rejected because the feature requires a web frontend and calendar grid.

## Decision: Static Web Frontend with Form-Encoded Requests

The frontend will use static HTML, CSS, and vanilla JavaScript. Browser actions will call the Cobol CGI handlers with `application/x-www-form-urlencoded` requests and consume JSON responses.

**Rationale**: Static frontend assets keep the UI simple, local, and framework-free. Form-encoded input is easy for Cobol CGI programs to parse, while JSON responses are convenient for rendering the calendar grid.

**Alternatives considered**:
- Frontend framework: rejected because v1 has a small UI surface and no framework need has been established.
- Full JSON request bodies: rejected because parsing JSON inside GNU Cobol adds avoidable complexity for v1.
- Server-rendered HTML only: rejected because the calendar grid needs responsive cell updates and clear save/error states.

## Decision: Local Pipe-Delimited Data Files

Project and weekly-entry records will be stored under `data/` as readable pipe-delimited files with one record per line.

**Rationale**: The constitution prioritizes local, readable, recoverable data. Pipe-delimited records map cleanly to Cobol fixed-field parsing while remaining easy to inspect and back up manually.

**Alternatives considered**:
- SQLite: rejected for v1 because it adds a runtime dependency and a Cobol binding decision before the storage needs justify it.
- JSON files: rejected because robust JSON parsing and mutation in Cobol would add unnecessary complexity.
- Fixed-width binary files: rejected because they are less readable and harder to recover manually.

## Decision: Latest Visible Project-Week Entries with Local Correction Records

Each project-week combination will store one latest visible value for display and weekly total calculations. Updating an existing cell replaces that current value and appends a local correction record with the prior value, replacement value, project code, week, and replacement timestamp.

**Rationale**: The clarified workflow needs a simple latest-value calendar while the constitution requires correction history needed to explain changes. Separating the current entry record from append-only correction records keeps routine time entry simple and preserves local auditability.

**Alternatives considered**:
- Replacing entries with no correction record: rejected because it conflicts with the constitution's data integrity requirement.
- Requiring a reason for every change: rejected because it exceeds v1 scope and slows routine time entry.

## Decision: Shell Contract Tests for Backend Validation

Backend tests will compile the Cobol handlers and invoke them with controlled CGI variables and stdin payloads.

**Rationale**: This verifies business rules at the same boundary used by the frontend, including duplicate project codes, per-cell validation, 5-day weekly totals, blank cells, latest visible updates, and correction record creation.

**Alternatives considered**:
- Browser-only testing: rejected because it would not isolate Cobol business-rule failures.
- Manual-only validation: rejected because the constitution requires executable validation where practical.
- Full end-to-end automation in v1: deferred until the first implementation establishes concrete server tooling.
