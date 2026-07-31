# Data Model: Grid Usability and Totals

## Existing Persistent Records

### Weekly Entry

| Field | Meaning | Rules |
|-------|---------|-------|
| `project_code` | Project identity | Must reference an existing project. |
| `week_start` | Monday that identifies the week | Existing backend validates Monday format. |
| `days` | Declared days | Existing backend validation and correction rules apply. |
| `updated_at` | Update timestamp | Existing storage field. |

The pipe-delimited data format is unchanged. When records represent the same project and week, the calendar reporting path uses the latest visible saved declaration according to existing backend semantics.

## Derived Calendar View

### Week Column

| Field | Source | Rules |
|-------|--------|-------|
| `week_start` | GNU Cobol calendar response | Monday date for the displayed week. |
| `iso_week_number` | GNU Cobol calendar response | ISO 8601 number shown above the Monday date. |
| `is_current_week` | GNU Cobol calendar response | True only if `week_start` equals the backend runtime's current local Monday. |
| `period_total_days` | GNU Cobol calendar response | Selected-period total of latest visible values; zero includes blank or zero project cells. |
| `period_total_status` | GNU Cobol calendar response | `complete` for exactly 5; `overdue` for a past week below 5; `default` otherwise. |

### Project Row View

| Field | Source | Rules |
|-------|--------|-------|
| `project` | Existing calendar response | Existing client, project name, and project code. |
| `cells[]` | Existing calendar response | Only selected-period values. |
| `total_days` | Existing calendar response | Existing selected-period row total; preserved for compatibility. |
| `lifetime_total_days` | New additive calendar response field | Latest visible declarations for the project across every stored week. |

### Project-Week Cell View State

| State | Trigger | Visible behavior |
|-------|---------|------------------|
| `blank` | Missing or zero saved value | Empty display outside edit mode; contributes zero. |
| `saved` | Positive saved value | Compact value button. |
| `hovered` | Pointer over non-editing button | Cell highlight only, no input. |
| `editing` | Explicit button activation | One input replaces the selected button. |
| `unsaved`, `invalid`, `failed` | Existing save lifecycle | Retains the existing feedback behavior. |

## State Transitions

```text
blank/saved -- explicit select --> editing -- change --> unsaved -- save --> saved
                                           \-- validation error --> invalid
                                           \-- transport failure --> failed
hovered is a presentation-only overlay and never transitions a cell to editing.
```