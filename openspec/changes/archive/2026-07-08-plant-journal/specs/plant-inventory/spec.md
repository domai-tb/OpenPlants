## ADDED Requirements

### Requirement: Plant entity references journal entries
The system SHALL associate each plant with its journal entries via a plant identifier reference.

#### Scenario: Journal entries linked to plant
- **WHEN** user creates a journal entry for a specific plant
- **THEN** the entry is stored with the plant's identifier and appears only in that plant's journal

#### Scenario: Delete plant removes journal entries
- **WHEN** user deletes a plant that has journal entries
- **THEN** the system removes all associated journal entries and their photo files from disk
