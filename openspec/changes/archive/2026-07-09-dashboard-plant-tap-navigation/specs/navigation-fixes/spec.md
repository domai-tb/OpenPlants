## ADDED Requirements

### Requirement: Today Dashboard plant tap navigates to plant detail

When the Today Dashboard displays a recent-plants carousel, tapping a plant SHALL switch to the Plant Collection tab and open the detail page for that plant.

#### Scenario: Tap plant in recent carousel
- **WHEN** the user taps a plant in the Today Dashboard recent-plants carousel
- **THEN** the app switches to the Plant Collection tab AND opens the PlantCollectionDetailPage for the tapped plant

#### Scenario: Plant deleted before tap completes
- **WHEN** the user taps a plant in the carousel AND the plant no longer exists
- **THEN** the app displays a "Plant not found" snackbar AND does not navigate away from the Today Dashboard
