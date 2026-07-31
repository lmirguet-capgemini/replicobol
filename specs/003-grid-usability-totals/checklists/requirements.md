# Specification Quality Checklist: Grid Usability and Totals

**Purpose**: Validate that the feature can be planned and tested without changing existing timesheet rules.
**Created**: 2026-07-31
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] User-visible behavior is described without implementation-specific UI code.
- [x] Each story can be tested independently.
- [x] Existing timesheet workflows and local-first scope are preserved.

## Requirement Completeness

- [x] Default-range placement and current-week highlighting are defined.
- [x] ISO week number and Monday-date header behavior is defined.
- [x] Blank and zero-value display behavior is defined separately from numeric calculations.
- [x] Hover behavior is distinguished from intentional edit activation.
- [x] Project lifetime totals and selected-period totals are distinguished.
- [x] Latest visible declaration semantics are specified for aggregate values.
- [x] Green, red, and default period-total treatments have explicit thresholds and date rules.
- [x] The backend ownership boundary for aggregation is stated.

## Readiness

- [x] Desktop visibility target for all 12 weeks is measurable.
- [x] Required backend and frontend regression checks are identified.
- [x] No unresolved clarification markers remain.
