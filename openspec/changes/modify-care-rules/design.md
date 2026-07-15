## Context

The care schedule feature computes tasks (watering, fertilizing, etc.) from species profiles, room configs, and modifiers. Users can create custom care rules that override computed schedules, but the UI doesn't clearly show which tasks are computed vs custom. Users must manually create a custom rule with the same task type to override a computed schedule, which is non-intuitive.

Current state:
- 8 built-in task types with computed schedules
- Custom care rules override computed schedules when task type matches
- UI shows computed tasks and custom rules separately
- No way to edit computed rules directly

## Goals / Non-Goals

**Goals:**
- Unified rule list showing both computed and custom rules
- Clear visual distinction between computed (species-based) and custom (user-defined) rules
- Edit action on computed rules creates a custom override
- Toggle enable/disable on computed rules (suppress without deleting)
- Maintain backward compatibility with existing custom rules

**Non-Goals:**
- Modifying species care profiles (data layer changes)
- Adding new built-in task types
- Changing the schedule computation algorithm
- Mobile push notifications for computed rules

## Decisions

### Decision: Use custom rules as overrides for computed rules

**Choice:** When user edits a computed rule, create a custom care rule with the same task type that overrides the computed schedule.

**Rationale:**
- Reuses existing custom care rule infrastructure
- No changes to schedule engine (already handles overrides)
- Simple implementation with minimal risk
- Custom rules already take precedence in schedule computation

**Alternatives considered:**
1. Add edit capability to computed rules directly → Requires changing species care profiles, complex data model changes
2. Create a new "rule override" entity → Over-engineering, duplicates custom care rule functionality

### Decision: Visual distinction via chips/badges

**Choice:** Use colored chips/badges to distinguish computed vs custom rules in the unified list.

**Rationale:**
- Clear visual cue without cluttering the UI
- Follows Material Design guidelines for status indicators
- Easy to implement with existing widget patterns

**Alternatives considered:**
1. Separate sections for computed and custom → More complex UI, harder to maintain consistency
2. Icons only → Less accessible, harder to distinguish at glance

### Decision: Toggle disable suppresses computed rules

**Choice:** When user disables a computed rule, create a custom rule with `isEnabled: false` to suppress it.

**Rationale:**
- Reuses existing toggle mechanism
- No schedule engine changes needed
- User can re-enable later

**Alternatives considered:**
1. Add "suppress" flag to computed rules → Requires new data model field
2. Remove from schedule entirely → Loses species default, harder to restore

## Risks / Trade-offs

**[Risk]** User creates multiple custom rules for same task type → **Mitigation:** Enforce one custom rule per task type per plant (existing constraint)

**[Risk]** Confusion about which rule is active → **Mitigation:** Clear visual indicators and tooltip explanations

**[Risk]** Breaking existing custom rules → **Mitigation:** Backward compatible, no schema changes

**[Trade-off]** Computed rules are read-only in species data → **Mitigation:** Custom overrides provide editability without data model changes
