# Research: Grid Usability and Totals

## Decision: Add a backend-calculated project lifetime total to calendar rows

**Rationale**: `calendar.cob` already loads all saved entries into its entry table before rendering the selected period. It can sum the latest visible declaration for every week belonging to each project, including weeks outside the requested range. This keeps reporting calculations behind the GNU Cobol contract as required by the constitution.

**Alternatives considered**:

- Sum only the selected cells in the browser: rejected because it produces a period total, not the requested lifetime total.
- Fetch the raw data files in the browser: rejected because it bypasses the backend contract and local data ownership boundary.
- Add a separate reporting endpoint: rejected because an additive field on the existing calendar response has lower complexity and preserves one calendar load.

## Decision: Preserve the selected-period total separately from lifetime totals

**Rationale**: `period_total_days` and each period-total cell answer the question “what was declared in the displayed weeks,” while a row lifetime total answers “what has been declared for this project overall.” They must not be conflated.

**Alternatives considered**:

- Replace `rows[].total_days`: rejected because existing dashboard consumers treat it as the selected-period total.
- Make period totals include all history: rejected because that would invalidate selected-period review and summary semantics.

## Decision: Return all calendar context and totals from the GNU Cobol backend

**Rationale**: The GNU Cobol calendar handler is the sole authority for time calculations and reporting. It determines the default range from its local current week, emits ISO week numbers, identifies the current displayed week, calculates each displayed week total, and classifies the total as `complete`, `overdue`, or `default`. The frontend renders these documented values without performing date, total, or status calculations.

**Alternatives considered**:

- Derive any calendar or total data in the browser: rejected because it duplicates a backend business rule and violates the constitution.
- Return raw entries and aggregate them in the browser: rejected because it bypasses the Cobol reporting contract.

## Decision: Keep cells as non-editing buttons until explicit selection

**Rationale**: The current grid already uses buttons which swap to inputs on click. Styling the button hover state provides discoverability without creating or revealing an input, preserving intentional edit activation and keyboard access.

**Alternatives considered**:

- Reveal inputs on hover: rejected because it creates visual noise and violates the requested non-editing hover behavior.
- Remove buttons entirely: rejected because an accessible focusable control is needed to initiate editing.

## Decision: Keep only color mapping in the frontend

**Rationale**: The frontend maps backend-provided `period_total_status` values to existing CSS classes. It does not decide whether a week is complete, overdue, or default, and it does not recompute the number displayed.

**Alternatives considered**:

- Calculate status from returned cells in the browser: rejected because this is a reporting calculation.
- Return preselected CSS class names: rejected because transport contracts should express domain states, not presentation implementation details.