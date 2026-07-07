## Why

Plant owners need a way to track their plant's condition over time. Without a journal, users lose context about what changed between care sessions—when they repotted, what pests they treated, or how growth progressed. This makes it hard to understand patterns and make informed care decisions.

## What Changes

- Add a new plant journal feature that lets users create timestamped entries for each plant
- Support multiple entry types: text notes, photos, completed tasks, growth updates, repotting logs, pest observations, and diagnosis results
- Display entries in a chronological timeline view per plant
- Store all journal data locally (no cloud sync required)

## Capabilities

### New Capabilities

- `plant-journal`: Core journaling capability—creating, reading, updating, and deleting journal entries tied to specific plants. Covers data model, persistence, and UI for the journal timeline.

### Modified Capabilities

- `plant-inventory`: Plant entity needs a reference to its journal entries (or journal entries reference plant ID). This is a data-model extension, not a behavioral change.

## Impact

- **Code**: New feature module following the 5-file pattern (datasource, repository, usecases, entity, page). Integration with existing plant inventory for linking entries to plants.
- **Data**: New local storage for journal entries (likely SQLite via sqflite or similar). Existing plant data schema requires a minor extension to support journal entry references.
- **Dependencies**: May need a photo picking library (image_picker) if not already included. Camera capture already exists as a capability.
- **Navigation**: New journal page accessible from plant detail view. Navigation entry in home page or plant detail page.
