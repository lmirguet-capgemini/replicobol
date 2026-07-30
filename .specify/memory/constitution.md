<!--
Sync Impact Report
Version change: 1.0.0 -> 2.0.0
Modified principles: IV. Web Frontend Clarity now governs weekly, rather than daily, time entry
Added sections: None
Removed sections: None
Follow-up TODOs: Existing feature specifications and plans remain compatible because the baseline product stores weekly project-day entries.
-->

# Replicobol Constitution

## Core Principles

### I. Timesheet Data Integrity
Time entries MUST preserve project identity, date, start and end time or duration, and any
correction history needed to explain changes. The system MUST prevent ambiguous or impossible
records, including negative durations and entries that cannot be assigned to a project. Rationale:
timesheet data is the product's source of truth, so convenience cannot override accurate records.

### II. Local-First Ownership
The application MUST run as a local management system and MUST keep timesheet data under the
operator's control unless an explicit future specification adds synchronization or export behavior.
Features MUST NOT assume a hosted service, third-party account, or network dependency for core time
recording. Rationale: local operation protects availability and privacy for personal project records.

### III. GNU Cobol Backend Contract
Business rules for creating, validating, calculating, and reporting time MUST live behind a GNU Cobol
backend interface. The web frontend MUST communicate through documented inputs and outputs rather
than duplicating backend rules. Rationale: keeping authority in the Cobol backend makes behavior
portable, auditable, and consistent across user interfaces.

### IV. Web Frontend Clarity
The web frontend MUST make weekly time entry, project selection, correction feedback, and review flows direct
and inspectable. UI states MUST show whether data is unsaved, saved, invalid, or failed to persist.
Rationale: time tracking succeeds only when routine entry is fast and mistakes are visible before
they become records.

### V. Testable Evolution
Every behavior change MUST include a verification path appropriate to its risk: Cobol backend tests
or scripted checks for business rules, frontend checks for user flows, and integration checks for
contract changes. Rationale: this project starts small, but timesheet correctness depends on being
able to prove that changes preserve prior behavior.

## Technical Constraints

The backend runtime target is GNU Cobol. Specifications and plans MUST identify any required file
formats, storage layout, command interface, or service interface before implementation changes are
made. The frontend is web-based and MUST remain decoupled from Cobol internals through a stable
backend contract. Dependencies MUST be justified by a concrete requirement and MUST preserve local
operation.

Data storage decisions MUST prioritize readable, recoverable local data. Any migration of existing
timesheet records MUST include a rollback or backup procedure. Any future network, authentication,
multi-user, or cloud capability is outside the baseline constitution and requires a new approved
specification before implementation.

## Development Workflow

Work MUST proceed through Spec Kit artifacts before implementation: constitution, specification,
plan, tasks, then implementation. Specifications MUST describe user-visible behavior and data rules
before selecting implementation mechanics. Plans MUST name the Cobol/frontend boundary, persistence
model, and verification strategy for the feature.

Tasks MUST be small enough to validate independently. Changes that affect time calculations, saved
records, or the frontend/backend contract MUST include an executable validation step before being
considered complete. Manual checks are acceptable only when no practical automated check exists, and
the exact manual procedure MUST be recorded in the relevant plan or task notes.

## Governance

This constitution governs project decisions and supersedes informal preferences when conflicts
arise. Amendments require an explicit constitution update that records the reason for the change, the
version impact, and any migration work needed for existing specifications or implementation plans.

Versioning follows semantic versioning. MAJOR changes remove or redefine governance commitments;
MINOR changes add principles, sections, or materially expanded guidance; PATCH changes clarify wording
without changing obligations. Compliance review is required during planning and before implementation:
plans and tasks MUST identify how they satisfy the Core Principles and Technical Constraints.

**Version**: 2.0.0 | **Ratified**: 2026-07-29 | **Last Amended**: 2026-07-30
