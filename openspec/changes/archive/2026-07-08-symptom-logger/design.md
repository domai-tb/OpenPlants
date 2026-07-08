## Context

OpenPlants is a Flutter plant companion app using Clean Architecture (Page → UseCase → Repository → DataSource). Plant care is currently tracked through care status fields and timestamp-based logging (last watered, last fertilized). The app stores data locally via shared_preferences with JSON serialization. There is no structured way to record plant health problems — users can only take photos through the camera-capture flow.

The goal is to add a symptom logger that collects structured data about plant problems, enabling better diagnosis context and health trend tracking over time.

## Goals / Non-Goals

**Goals:**
- Provide a structured form for recording plant symptoms with categorical and observational data
- Store symptom logs locally with each plant for history and timeline display
- Integrate symptom entries into the existing care-tracking timeline as health events
- Support optional photo attachment per symptom entry (reuse camera-capture)

**Non-Goals:**
- AI-based diagnosis or recommendations from symptom data (future feature)
- Cloud sync or sharing of symptom logs
- Push notifications based on symptom patterns
- Multi-photo galleries per symptom entry (one photo max for now)

## Decisions

### 1. Entity model: flat `SymptomLogEntry` with enum-based symptom types

**Decision**: Use a single flat entity with an enum for symptom categories (yellowLeaves, brownTips, drooping, pests, mold, softStems, drySoil, wetSoil, leafSpots) rather than a free-text field or a nested model.

**Rationale**: Enums enforce valid categories at the type level, enable filtering/display without text parsing, and keep the data structured for future trend analysis. A flat entity keeps serialization simple with shared_preferences.

**Alternatives considered**:
- Free-text symptom field: Rejected — loses structure, can't filter or aggregate reliably.
- Nested model with symptom sub-types: Rejected — over-engineered for the current scope; a single enum covers all known symptoms.

### 2. Storage: local JSON via SharedPreferences (existing pattern)

**Decision**: Store symptom logs as a JSON list per plant in shared_preferences, following the same pattern as SettingsController.

**Rationale**: Consistent with existing persistence approach. No new dependencies. Symptom logs are per-device and don't need relational queries.

**Alternatives considered**:
- SQLite/database: Rejected — adds dependency overhead; shared_preferences is sufficient for the expected volume (< 100 logs per plant over its lifetime).
- File-based storage: Rejected — more complex serialization management with no benefit for this use case.

### 3. UI: dedicated page with multi-step form flow

**Decision**: A standalone page (`symptom_logger_page.dart`) with a step-by-step form: symptom type selection → severity → affected parts → observations (soil, light, timing) → optional notes/photo → review & save.

**Rationale**: Multi-step reduces cognitive load compared to a single long form. Each step focuses on one concern. The flow can be completed in under 30 seconds for quick logging.

**Alternatives considered**:
- Single scrollable form: Rejected — too many fields on one screen; users may abandon.
- Bottom sheet overlay: Rejected — insufficient space for the required fields; page gives proper navigation context.

### 4. Care timeline integration: symptom logs as timeline events

**Decision**: Add symptom logs to the care-tracking timeline alongside watering/fertilizing events, tagged with a distinct icon and color.

**Rationale**: Users benefit from seeing health events in context with care actions. A single timeline view reduces navigation friction.

**Alternatives considered**:
- Separate "Health" tab: Rejected — fragments the user's view of plant history; timeline should be unified.

## Risks / Trade-offs

- **Data volume growth**: Symptom logs accumulate over time. → Mitigation: Cap at 200 entries per plant; oldest entries are archived, not deleted.
- **Form completion abandonment**: Multi-step forms can lose users mid-flow. → Mitigation: Auto-save draft at each step; allow resuming later.
- **Enum extensibility**: Adding new symptom types requires code changes. → Mitigation: Design the enum with Future-proofing in mind; document extension points. The enum is internal and can be expanded without breaking stored data (new values just won't deserialize for old versions).

## Open Questions

- Should symptom severity trigger care-status updates (e.g., severe symptoms auto-set `needs_water`)? → Recommend yes for severe cases, defer to implementation phase.
- How should the timeline distinguish between "symptom logged" and "symptom resolved" events? → Recommend adding a `resolved` boolean field to SymptomLogEntry.
