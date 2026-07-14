## ADDED Requirements

### Requirement: Plant deletion removes its photo timeline
Growth-photo metadata and files SHALL be owned by their plant and SHALL be removed when that plant is deleted.

#### Scenario: Delete plant with growth photos
- **WHEN** a user confirms deletion of a plant that has dated growth photos
- **THEN** the system deletes every growth-photo file for that plant
- **AND** removes every corresponding metadata record
- **AND** no deleted photo appears in the unified timeline

#### Scenario: Growth photo already missing during cascade
- **WHEN** plant deletion encounters growth-photo metadata whose file is already absent
- **THEN** the system treats the file cleanup as complete
- **AND** removes the stale metadata record
