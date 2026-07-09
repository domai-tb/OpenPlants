## ADDED Requirements

### Requirement: Tapping a plant on the Today Dashboard navigates to plant detail

The system SHALL navigate to the PlantCollectionDetailPage when the user taps a plant in the Today Dashboard's recent-plants carousel.

#### Scenario: Tap plant in carousel
- **WHEN** the user taps a plant thumbnail in the Today Dashboard recent-plants carousel
- **THEN** the app switches to the Plant Collection tab AND opens the PlantCollectionDetailPage for that plant

#### Scenario: Plant not found after tap
- **WHEN** the user taps a plant in the carousel but the plant no longer exists in the collection
- **THEN** the app displays a snackbar message "Plant not found" AND remains on the Today Dashboard

### Requirement: Tapping a care task navigates to the associated plant's detail

The system SHALL navigate to the PlantCollectionDetailPage when the user taps a care-task card on the Today Dashboard, provided the care task includes a plant identifier.

#### Scenario: Tap care task with plant ID
- **WHEN** the user taps a care-task card that has an associated plant ID
- **THEN** the app switches to the Plant Collection tab AND opens the PlantCollectionDetailPage for that plant

#### Scenario: Care task without plant ID
- **WHEN** the user taps a care-task card that has no plant ID
- **THEN** the care-task card does not trigger navigation
