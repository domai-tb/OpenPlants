## Context

The collection page has filter chips for "Needs Water" and "Needs Fertilizer" that query `PlantCollectionUsecases.filterByCareStatus()`. Currently, this method does a strict `p.careStatus == status` comparison against the stored `careStatus` field. The stored field defaults to `happy` when a plant is created and is only updated when the user manually changes it or uses the mark-as-watered/fertilized actions. A plant that has never received care keeps `careStatus = happy` and is invisible to the filter — defeating the purpose of the feature.

The schedule engine (`schedule_engine.dart`, `overdue_detector.dart`) already knows how to determine when a plant is overdue for watering/fertilizing based on species intervals, room/pot modifiers, and completion history. However, it is not yet wired into this use-case (per the TODO in `today_dashboard_datasource.dart`).

## Goals / Non-Goals

**Goals:**
- "Needs Water" filter includes plants whose `lastWateredAt` is `null` (never watered)
- "Needs Fertilizer" filter includes plants whose `lastFertilizedAt` is `null` (never fertilized)
- The care-status indicator (colored dot on tiles / detail page) reflects the effective status, so a never-watered plant shows as needing water even without an explicit `careStatus` override
- Minimal, safe change — no data migration, no schema change, no new dependencies

**Non-Goals:**
- Wiring the full schedule engine into `CareStatus` computation (e.g., computing overdue status from species intervals + room modifiers) — that remains a future enhancement tracked in the existing TODO
- Changing how `careStatus` is stored or serialized — the stored field stays as-is, only the runtime interpretation changes
- Adding overdue detection for plants that were watered/fertilized in the past but are now overdue — this requires the schedule engine wiring

## Decisions

### Decision 1: Computed `effectiveCareStatus` instead of modifying `filterByCareStatus` alone

**Chosen approach:** Add a `PlantEntity.effectiveCareStatus` getter that computes the runtime status using the stored `careStatus` as a base, then inferring `needsWater` or `needsFertilizer` from null timestamps. The filter and UI both use this getter.

**Alternatives considered:**
- **Modify `filterByCareStatus` in place** — simpler, but leaves the UI indicator out of sync (a never-watered plant would show a green dot but match the blue-water filter). Would need the same logic in two places (filter + display).
- **Overhaul `CareStatus` to be fully dynamic** — too invasive for this fix; the schedule engine isn't ready and the stored `careStatus` serves a purpose for manual overrides.

**Rationale:** A single getter is the smallest unit of shared behavior. Both the filter and the display code use it, ensuring consistency. The stored `careStatus` acts as an explicit override: if the user manually set it, that value takes priority.

### Decision 2: Priority order for effective status

The effective status is computed with this priority (highest wins):
1. If stored `careStatus` is `needsWater` or `needsFertilizer` (user explicitly set it) → use that
2. If `lastWateredAt` is `null` → `needsWater`
3. If `lastFertilizedAt` is `null` → `needsFertilizer`
4. Otherwise → stored `careStatus` (which is `happy`)

**Rationale:** Manual override should always win. Watering need takes priority over fertilizing need because water is more urgent.

### Decision 3: Filter uses effective status, not separate null checks

`filterByCareStatus(CareStatus.needsWater)` calls `plants.where((p) => p.effectiveCareStatus == CareStatus.needsWater)` rather than checking `lastWateredAt == null` independently. This keeps the filter and display consistent and means the priority logic only lives in one place.

**Trade-off:** A plant with `lastFertilizedAt == null` AND `lastWateredAt == null` shows as `needsWater` in the effective status (priority rule 2). It will NOT appear in the "Needs Fertilizer" filter. This is intentional — water is more urgent, and when they water it, `lastWateredAt` gets set, so it will then appear as `needsFertilizer`.

## Risks / Trade-offs

- **[Edge case] Plant with both timestamps null** — Shows as `needsWater`. After first watering, will appear as `needsFertilizer`. This is intentional behavior, but may surprise users who expected a plant with both missing to appear in both filters.
  → **Mitigation**: Add comment in code documenting the priority logic.

- **[Backward compat] Existing plants** — All existing plants with `careStatus` set explicitly are unaffected. Only plants with `lastWateredAt == null` / `lastFertilizedAt == null` and `careStatus == happy` change behavior. No data migration needed.

- **[Scope creep] Wiring schedule engine** — The immediate fix covers the "never received care" case. It does not cover "hasn't received care in N days past the schedule." That's a separate feature that should wire the schedule engine into the `effectiveCareStatus` getter.
