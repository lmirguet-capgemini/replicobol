# Research: Frontend Redesign

## Decision: Preserve The Existing Frontend Stack

**Decision**: Implement the redesign in the existing `frontend/index.html`, `frontend/styles.css`, and `frontend/app.js` files using browser-native HTML, CSS, DOM, and Fetch APIs.

**Rationale**: The feature changes one local dashboard screen and does not require routing, shared component packages, client-side persistence, or a complex state graph. The current stack already supports all required interactions and keeps the application local, inspectable, and dependency-free.

**Alternatives considered**:

- Add React, Vue, or another frontend framework: rejected because it introduces a build pipeline and runtime dependency without solving an unmet requirement.
- Introduce a CSS framework: rejected because matching the supplied design requires a tailored visual system, and an external framework would add unused styling and dependency overhead.

## Decision: Adapt The Reference Rather Than Copy It Literally

**Decision**: Use `design.png` as the structural and visual reference: dark persistent navigation, restrained light workspace, compact header, summary metrics, notification area, toolbar, and dense timesheet table. Retain Replicobol naming and only expose supported actions.

**Rationale**: The reference includes controls and concepts outside the feature scope. Adapting its hierarchy, spacing, typography, color contrast, and table treatment achieves the requested design direction without implying unsupported export, project lifecycle, pagination, or submission behavior.

**Alternatives considered**:

- Pixel-copy every visible reference control: rejected because several controls have no corresponding Replicobol behavior.
- Preserve the current visual layout and only recolor it: rejected because it would not deliver the requested dashboard hierarchy or scanability.

## Decision: Keep Reporting Calculations In GNU Cobol

**Decision**: Extend `GET /cgi-bin/calendar` with a `summary` object calculated by `calendar.cob`. The frontend will render declared days, active projects, and missing declarations without independently implementing those reporting rules.

**Rationale**: The constitution assigns calculating and reporting time to the GNU Cobol backend. The calendar handler already loads projects and weekly entries and is the nearest owning abstraction for dashboard data.

**Alternatives considered**:

- Sum calendar cells in JavaScript: rejected because it duplicates backend reporting rules and cannot reliably calculate a rolling window outside the selected grid.
- Add a separate summary CGI handler: rejected because the summary and grid use the same project/entry inputs, so another handler would duplicate file reads and contract surface.

## Decision: Define The Rolling Three-Month Window By Calendar Date

**Decision**: Anchor the window on the Monday of the current local week. Include each Monday whose date is on or after the date three calendar months before that anchor, through and including the current week. A week is missing when its total across all projects is below 5 days.

**Rationale**: This implements the clarified phrase “rolling 3 months ending with the current week” without reducing a calendar-month requirement to an arbitrary fixed number of weeks. It also produces deterministic behavior across months of different lengths.

**Alternatives considered**:

- Always inspect 13 weeks: rejected because 13 weeks is not consistently equivalent to three calendar months.
- Use the selected grid period: rejected because the clarification anchors the status to the current week, independent of browsing.
- Use three previous full calendar months: rejected because that would exclude the current partial month and current week.

## Decision: Treat All Existing Projects As Active

**Decision**: `active_projects` equals the number of projects returned by the current project store.

**Rationale**: Replicobol v1 has no inactive, archived, or deleted project state. Counting only projects with entries would silently redefine “active” and make newly created projects disappear from the summary.

**Alternatives considered**:

- Count projects with at least one selected-period entry: rejected because activity state is not inferred from usage in the existing domain model.
- Add an active flag: rejected because project lifecycle management is explicitly outside this feature.

## Decision: Use Focused Contract And Browser Validation

**Decision**: Extend the existing shell calendar contract test for summary values and strict JSON. Validate the rendered feature with browser automation at desktop and mobile viewports, including a screenshot comparison against the design direction and real save/create flows.

**Rationale**: Backend tests prove calculation ownership and contract correctness; browser checks prove responsive layout, visible states, and end-to-end interaction. Both are required by the constitution for this cross-boundary change.

**Alternatives considered**:

- Manual visual inspection only: rejected because it does not protect the contract or repeated user flows.
- Snapshot-only frontend testing: rejected because a screenshot cannot prove saves, errors, accessibility labels, or persisted values.