## ADDED Requirements

### Requirement: Species lookup from identification result
The system SHALL provide a use-case method on `SpeciesLibraryUsecases` that takes a scientific name string and returns the matching `SpeciesEntity`, or null if not found. The plant identification page SHALL display a "View Species Details" button when a species is identified, linking to the species detail page.

#### Scenario: Identified species exists in library
- **WHEN** the plant classifier returns a scientific name that matches a species in the library
- **THEN** the identification result page SHALL show a "View Species Details" button

#### Scenario: Identified species not in library
- **WHEN** the plant classifier returns a scientific name that does NOT match any species in the library
- **THEN** the identification result page SHALL NOT show the species link button

### Requirement: Navigation to species detail
The system SHALL navigate from the plant identification result page to the species detail page when the user taps "View Species Details". Navigation SHALL use the existing tab-specific navigator (push onto the species library tab's navigator stack, or switch to the species library tab).

#### Scenario: Tap opens species detail
- **WHEN** the user taps "View Species Details" on the identification result page
- **THEN** the app SHALL navigate to the species detail page for the identified species

### Requirement: Identification result use-case
The system SHALL provide a bridge use-case in `PlantIdentificationUsecases` (or a dedicated method in `SpeciesLibraryUsecases`) that accepts a classification label string and returns the species detail in a form the identification page can consume.

#### Scenario: Bridged species lookup
- **WHEN** the plant identification page requests species info for a classification result
- **THEN** the use-case SHALL look up the species by scientific name and return the species entity

### Requirement: No changes to classifier output
The integration SHALL NOT modify the existing ONNX classifier pipeline. The species lookup SHALL consume the existing string-based classification result.

#### Scenario: Classifier unchanged
- **WHEN** the user takes a photo and the classifier runs
- **THEN** the classification pipeline SHALL produce identical results regardless of the species library
