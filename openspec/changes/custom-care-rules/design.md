## Context

The care schedule engine currently computes task schedules from species defaults, room context, and pot type. Users can override individual intervals via `schedule-config`, but cannot define entirely custom care routines with their own task names, timing, or reminder preferences. The system needs a first-class "care rule" abstraction that lets users fully override or supplement computed schedules.

Current architecture: `Page → UseCase → Repository → DataSource`. All care-related entities live in `lib/pages/careTracking/`.

## Goals / Non-Goals

**Goals:**
- Users can define custom care rules per-plant with user-specified intervals
- Users can create custom task types (name + interval + reminder config)
- Users can set per-rule reminders (time-of-day, days-of-week)
- The schedule engine respects custom rules as primary overrides
- Custom rules persist locally and survive app restarts

**Non-Goals:**
- Cloud sync of custom rules (local-only for now)
- Sharing rules between users or across plants in bulk (per-plant only)
- Push notification delivery (reminder configuration only; actual delivery is a separate concern)
- Modifying species defaults or room modifiers (these remain as fallbacks)

## Decisions

### Decision 1: CustomCareRule entity design

Create a `CustomCareRuleEntity` with fields:
- `id` (String, UUID)
- `plantId` (String, FK to plant)
- `taskType` (String, e.g. "watering", "Check for flowers")
- `intervalDays` (int, user-specified interval)
- `reminderEnabled` (bool)
- `reminderTime` (String?, HH:mm format)
- `reminderDays` (List<String>?, e.g. ["monday", "wednesday"])
- `isEnabled` (bool, allows disabling without deleting)
- `createdAt` (DateTime)

**Rationale**: Flat entity avoids over-engineering. `taskType` as String supports both built-in types (for override) and user-defined types (for new tasks). Reminder config is optional and nullable to keep simple rules simple.

**Alternatives considered**: 
- Separate `ReminderConfig` value object — rejected as over-abstracting for local storage
- Embedding rules in `ScheduleConfig` — rejected because rules are per-plant while schedule config is per-plant-per-task, different lifecycle

### Decision 2: Persistence via SharedPreferences with JSON

Store rules as a JSON list in SharedPreferences under key `custom_care_rules`. 

**Rationale**: Rules are small (typically <50 per user), read in bulk (all rules for a plant), and don't need relational queries. SharedPreferences is already used for settings. JSON serialization is simple and debuggable.

**Alternatives considered**:
- SQLite — rejected as overkill for this data volume; adds migration complexity
- Hive/Isar — rejected as new dependencies; SharedPreferences is sufficient

### Decision 3: Engine integration — rules as pre-check

The schedule engine will check for custom rules BEFORE computing from species defaults. If a matching rule exists for a plant+taskType, the rule's interval is used directly (no modifiers applied). If no rule exists, the existing computation pipeline runs unchanged.

**Rationale**: Custom rules are explicit user intent. Applying modifiers to user-specified intervals would violate the "user knows best" principle. The override is absolute when a rule exists.

**Alternatives considered**:
- Allow users to opt-in to modifiers — rejected as premature complexity; can add later if requested
- Rules as additional modifiers — rejected because users expect their rules to be final

### Decision 4: UI — rule editor as modal/sheet on plant detail

Access custom rules from the plant detail page via a "Care Rules" section. Tapping opens a list of rules for that plant. Each rule can be edited inline. "Add rule" opens a form with task type (dropdown for built-in + free text for custom), interval, and optional reminder settings.

**Rationale**: Keeps rule management contextual (per-plant) and avoids a separate navigation destination. Modal/sheet pattern is consistent with existing edit flows in the app.

## Risks / Trade-offs

- **[Rule proliferation]** Users may create too many rules, making management complex → Mitigation: Show rule count per plant; could add "simplify" suggestion in future
- **[Reminder accuracy]** Reminder time-of-day is configuration only; actual notification delivery depends on platform notification system → Mitigation: Document this clearly; notification delivery is out of scope
- **[Data migration]** Existing schedule-config interval overrides may conflict with new rules → Mitigation: Rules take precedence; schedule-config overrides remain as fallback for users who don't create rules
- **[Storage limits]** SharedPreferences has no hard limit but JSON parsing degrades with large payloads → Mitigation: Rules per plant are naturally bounded by task types; not a practical concern
