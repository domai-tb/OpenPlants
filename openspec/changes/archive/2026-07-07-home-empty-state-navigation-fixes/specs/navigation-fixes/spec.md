# Navigation Fixes

Bug-fix change — no new capabilities. Corrects two broken navigation paths in empty-state surfaces.

## ADDED Requirements

### Requirement: Today Dashboard Add Plant navigates to add form

When the Today Dashboard shows the quick-action strip or the onboarding empty state, the "Add Plant" button SHALL switch to the plant_collection tab and open the add-plant form.

#### Scenario: Add Plant from quick-action strip
- **WHEN** the user taps "Add Plant" in the Today Dashboard quick-action strip
- **THEN** the app switches to the Plant Collection tab AND opens the add-plant form

#### Scenario: Add Plant from empty-state CTA
- **WHEN** the user has no plants and taps "Add your first plant" on the Today Dashboard empty state
- **THEN** the app switches to the Plant Collection tab AND opens the add-plant form

### Requirement: Care Schedule Go to Collection navigates correctly

When the Care Schedule page shows its empty state (no plants configured), the "Go to Plant Collection" button SHALL switch to the plant_collection tab without crashing.

#### Scenario: Navigate to Plant Collection from empty schedule
- **WHEN** the user has no care tasks and taps "Go to Plant Collection"
- **THEN** the app switches to the Plant Collection tab

### Requirement: Empty schedule state uses l10n

The Care Schedule empty state SHALL not use hardcoded user-facing strings — all text SHALL come from `AppLocalizations`.

#### Scenario: Empty schedule button uses l10n
- **WHEN** the Care Schedule empty state renders a button
- **THEN** the button label comes from an l10n key, not a string literal
