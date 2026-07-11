# Plant Health Timeline — REMOVED

## REMOVED Requirements

**Reason**: The standalone Plant Health Timeline feature is superseded by the unified journal timeline, which merges all plant events (journal entries, symptom logs, diagnosis results) into a single reverse-chronological feed. The health timeline's purpose — showing symptom and diagnosis events — is absorbed into the enhanced journal feature.

**Migration**: All plant detail pages that previously linked to `PlantHealthTimelinePage` should link to the enhanced journal page instead. The `plant_health_timeline/` feature module is deleted.

### Requirement: Health timeline displayed on plant detail page

#### Scenario: Timeline shows mixed events
#### Scenario: Timeline shows only symptoms
#### Scenario: Timeline shows only diagnoses
#### Scenario: Empty timeline

### Requirement: Each event type has a distinct visual appearance

#### Scenario: Symptom log appearance
#### Scenario: Diagnosis result appearance
#### Scenario: Linked events shown as paired

### Requirement: Timeline supports filtering

#### Scenario: Filter by active symptoms
#### Scenario: Show all events

### Requirement: Timeline provides action entry points

#### Scenario: Log symptom from timeline
#### Scenario: Diagnose from timeline

### Requirement: Symptoms can be marked resolved from the timeline

#### Scenario: Mark resolved
#### Scenario: Unresolved entry shows action
#### Scenario: Resolved entry shows info

### Requirement: Timeline loads efficiently

#### Scenario: Initial load
