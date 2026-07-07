## 1. Data Model & Entity

- [ ] 1.1 Create `JournalEntryType` enum with values: text, photo, task, growth, repotting, pest, diagnosis
- [ ] 1.2 Create `JournalEntry` entity class with fields: id, plantId, type, timestamp, notes, photoPath (optional)
- [ ] 1.3 Add `journalEntryCount` field to existing `Plant` entity for quick reference

## 2. Data Source

- [ ] 2.1 Create SQLite database helper for journal entries table
- [ ] 2.2 Implement `JournalDataSource` with CRUD operations (create, read by plant, update, delete)
- [ ] 2.3 Add database migration to create journal_entries table
- [ ] 2.4 Implement photo file storage utility (save, delete from app documents directory)

## 3. Repository

- [ ] 3.1 Create `JournalRepository` interface with methods: getEntries(plantId), addEntry, updateEntry, deleteEntry
- [ ] 3.2 Implement repository that maps between data source and entity

## 4. Use Cases

- [ ] 4.1 Create `GetJournalEntriesUseCase` - fetches entries for a plant sorted by timestamp descending
- [ ] 4.2 Create `AddJournalEntryUseCase` - validates and persists new entry with optional photo
- [ ] 4.3 Create `UpdateJournalEntryUseCase` - updates entry notes and/or photo
- [ ] 4.4 Create `DeleteJournalEntryUseCase` - removes entry and associated photo file

## 5. UI - Journal Page

- [ ] 5.1 Create journal page widget with ListView.builder for timeline display
- [ ] 5.2 Create entry card widgets for each type (text, photo, task, growth, repotting, pest, diagnosis)
- [ ] 5.3 Add empty state placeholder when no entries exist
- [ ] 5.4 Add "Add entry" button that opens entry creation form

## 6. UI - Entry Creation

- [ ] 6.1 Create entry type selector (bottom sheet or dialog)
- [ ] 6.2 Create text entry form with notes field
- [ ] 6.3 Create photo entry form with camera/gallery picker
- [ ] 6.4 Create other entry type forms (task, growth, repotting, pest, diagnosis)
- [ ] 6.5 Implement save logic that creates entry and navigates back

## 7. UI - Entry Management

- [ ] 7.1 Add tap handler to view/edit entry details
- [ ] 7.2 Add delete button with confirmation dialog
- [ ] 7.3 Implement edit mode for updating entry notes/photo

## 8. Integration

- [ ] 8.1 Add journal button/tab to plant detail page
- [ ] 8.2 Register JournalDataSource, JournalRepository, and use cases in injection.dart
- [ ] 8.3 Add JournalUseCases to AppServices aggregate
- [ ] 8.4 Update plant deletion to cascade delete journal entries and photos

## 9. Testing

- [ ] 9.1 Write unit tests for journal use cases
- [ ] 9.2 Write unit tests for journal repository
- [ ] 9.3 Run `fvm flutter analyze` to verify no lint violations
- [ ] 9.4 Run `fvm flutter test` to verify all tests pass

## 10. Localization

- [ ] 10.1 Add journal-related strings to `assets/l10n/l10n_en.arb`
- [ ] 10.2 Run `fvm flutter gen-l10n` to regenerate localization files
