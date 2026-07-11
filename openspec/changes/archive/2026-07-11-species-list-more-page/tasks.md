## 1. Localization

- [x] 1.1 Add l10n keys to `assets/l10n/l10n_en.arb`: `speciesListTitle`, `speciesListSearchHint`, `speciesListEmptyState`, `moreSpeciesListTitle`, `moreSpeciesListSubtitle`
- [x] 1.2 Run `fvm flutter gen-l10n` to regenerate localization files

## 2. More Page Entry

- [x] 2.1 Add species list item to `more_datasource.dart` as the first item in the list (id: `species_list`)
- [x] 2.2 Add navigation case in `more_page.dart` `_open()` method to push `SpeciesLibraryPage`
- [x] 2.3 Add localized title/subtitle mapping in `more_page.dart` `itemTitle()` and `itemSubtitle()` for `species_list`

## 3. Species List Page

- [x] 3.1 Create `lib/pages/species_library/species_library_page.dart` with `StatefulWidget` scaffold
- [x] 3.2 Implement species list loading: call `SpeciesLibraryUsecases.getAllSpecies()` on init, display in `ListView.builder`
- [x] 3.3 Build species list item widget: scientific name, primary common name, difficulty badge (green/amber/red), toxicity icon
- [x] 3.4 Add search `TextField` in AppBar area with debounced filtering (~300ms) using `SpeciesLibraryUsecases.searchSpecies()`
- [x] 3.5 Handle empty search results state with a message
- [x] 3.6 Wire tap navigation to existing `SpeciesDetailPage` via `Navigator.push`

## 4. Verification

- [x] 4.1 Run `fvm flutter analyze` — no lint errors
- [x] 4.2 Run `fvm flutter test` — all existing tests pass
