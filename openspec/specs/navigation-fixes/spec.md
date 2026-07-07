# Navigation Fixes

Cross-tab navigation corrections for empty-state surfaces.

## Purpose

Fixes broken navigation paths when the app is in an empty state (no plants configured). Ensures that call-to-action buttons on the Today Dashboard and Care Schedule pages correctly navigate to the Plant Collection tab.

## Requirements

### Requirement: Today Dashboard Add Plant navigates to add form

When the Today Dashboard shows the quick-action strip or the onboarding empty state, the "Add Plant" button SHALL switch to the plant_collection tab and open the add-plant form.

#### Scenario: Add Plant from quick-action strip
- **WHEN** the user taps "Add Plant" in the Today Dashboard quick-action strip
- **THEN** the app switches to the Plant Collection tab AND opens the add-plant form

#### Scenario: Add Plant from empty-state CTA
- **WHEN** the user has no plants and taps "Add your first plant" on the Today Dashboard empty state
- **THEN** the app switches to the Plant Collection tab AND opens the add-plant form
