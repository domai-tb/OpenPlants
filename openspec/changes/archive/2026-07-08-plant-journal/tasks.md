## 1. Data Model & Entity

- [x] 1.1 Create `JournalEntryType` enum with values: text, photo, task, growth, repotting, pest, diagnosis
- [x] 1.2 Create `JournalEntry` entity class with fields: id, plantId, type, timestamp, notes, photoPath (optional)
- [x] 1.3 Add `journalEntryCount` field to existing `Plant` entity for quick reference

## 2. Data Source

- [x] 2.1 Create SQLite database helper for journal entries table
- [x] 2.2 Implement `JournalDataSource` with CRUD operations (create, read by plant, update, delete)
- [x] 2.3 Add database migration to create journal_entries table
- [x] 2.4 Implement photo file storage utility (save, delete from app documents directory)

## 3. Repository

- [x] 3.1 Create `JournalRepository` interface with methods: getEntries(plantId), addEntry, updateEntry, deleteEntry
- [x] 3.2 Implement repository that maps between data source and entity

## 4. Use Cases

- [x] 4.1 Create `GetJournalEntriesUseCase` - fetches entries for a plant sorted by timestamp descending
- [x] 4.2 Create `AddJournalEntryUseCase` - validates and persists new entry with optional photo
- [x] 4.3 Create `UpdateJournalEntryUseCase` - updates entry notes and/or photo
- [x] 4.4 Create `DeleteJournalEntryUseCase` - removes entry and associated photo file

## 5. UI - Journal Page

- [x] 5.1 Create journal page widget with ListView.builder for timeline display
- [x] 5.2 Create entry card widgets for each type (text, photo, task, growth, repotting, pest, diagnosis)
- [x] 5.3 Add empty state placeholder when no entries exist
- [x] 5.4 Add "Add entry" button that opens entry creation form

## 6. UI - Entry Creation

- [x] 6.1 Create entry type selector (bottom sheet or dialog)
- [x] 6.2 Create text entry form with notes field
- [x] 6.3 Create photo entry form with camera/gallery picker
- [x] 6.4 Create other entry type forms (task, growth, repotting, pest, diagnosis)
- [x] 6.5 Implement save logic that creates entry and navigates back

## 7. UI - Entry Management

- [x] 7.1 Add tap handler to view/edit entry details
- [x] 7.2 Add delete button with confirmation dialog
- [x] 7.3 Implement edit mode for updating entry notes/photo

## 8. Integration

- [x] 8.1 Add journal button/tab to plant detail page
- [x] 8.2 Register JournalDataSource, JournalRepository, and use cases in injection.dart
- [x] 8.3 Add JournalUseCases to AppServices aggregate
- [x] 8.4 Update plant deletion to cascade delete journal entries and photos

## 9. Testing

- [x] 9.1 Write unit tests for journal use cases
- [x] 9.2 Write unit tests for journal repository
- [x] 9.3 Run `fvm flutter analyze` to verify no lint violations
- [x] 9.4 Run `fvm flutter test` to verify all tests pass

## 10. Localization

- [x] 10.1 Add journal-related strings to `assets/l10n/l10n_en.arb`
- [x] 10.2 Run `fvm flutter gen-l10n` to regenerate localization files
