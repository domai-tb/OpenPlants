## Why

Plant owners have diverse habits, environments, and expertise levels. The current engine computes schedules from species defaults and room context, but users cannot fully override schedules for specific plants or define their own care routines with custom timing and reminders. Experienced growers need to override AI suggestions with their own judgment, while beginners benefit from customizable reminders that match their availability.

## What Changes

- Users can define custom care rules per-plant that fully override generated schedules
- Users can create custom task types with configurable intervals and reminder behavior
- Users can set reminder preferences (time-of-day, days-of-week, notification style) per task type
- The care schedule engine respects custom rules as first-class overrides, falling back to computed schedules only when no custom rule exists
- The care tasks UI exposes a rule editor for creating, editing, and deleting custom care rules

## Capabilities

### New Capabilities

- `custom-care-rules`: User-defined care rules that override generated schedules, including per-rule interval, task type, reminder scheduling, and notification preferences

### Modified Capabilities

- `care-schedule-engine`: Engine must accept and apply custom care rules before computing fallback schedules. Custom rules take precedence over species defaults, room modifiers, and pot-type modifiers.
- `care-tasks-ui`: UI must include a rule editor component for managing custom care rules per plant, with controls for interval, task type, and reminder settings.

## Impact

- **Code**: New entity `CustomCareRule` in `lib/pages/careTracking/`, new use-case methods for rule CRUD, modifications to schedule engine to check rules before computation
- **Dependencies**: None new
- **Data**: New local storage for custom care rules (SharedPreferences or SQLite)
- **APIs**: None — all local
