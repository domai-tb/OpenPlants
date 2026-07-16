## 1. Catalog contract and assets

- [ ] 1.1 Inspect current model labels, species assets, plant entity serialization, and supported locales; document authoritative label/index inputs.
- [ ] 1.2 Define immutable catalog entity and JSON schemas for stable IDs, model indices, scientific names, aliases, care metadata, and locale data.
- [ ] 1.3 Build catalog generation and validation tooling from model labels; fail on duplicate IDs, duplicate indices, missing mappings, or malformed records.
- [ ] 1.4 Generate and add the bundled base catalog plus initial locale assets; declare assets in `pubspec.yaml` and verify package inclusion.

## 2. Data and domain layers

- [ ] 2.1 Implement lazy cached catalog datasource with classified errors for missing or malformed assets.
- [ ] 2.2 Extend species repository with stable-ID lookup, model-index lookup, localized search, exact scientific-name compatibility lookup, and bounded results.
- [ ] 2.3 Implement locale resolution using active locale, fallback locale, and scientific-name fallback for names and information.
- [ ] 2.4 Add catalog use cases and register datasource, repository, and use cases through dependency injection and `AppServices`.
- [ ] 2.5 Add read-time compatibility migration for legacy free-text species values and idempotent stable-ID writes.

## 3. Plant and classifier integration

- [ ] 3.1 Update plant entity, persistence mapping, and migration-safe serialization to store stable species IDs while preserving unmatched legacy text.
- [ ] 3.2 Update classifier postprocessing to resolve model indices through the shared catalog and return mapping errors for unknown indices.
- [ ] 3.3 Replace add/edit free-text species input with a searchable, bounded species picker using localized display values.
- [ ] 3.4 Update identification-result selection to persist catalog IDs and display localized names.
- [ ] 3.5 Update plant detail, dashboard, care, and journal display paths to resolve species names through the catalog localization use case.

## 4. Verification and rollout

- [ ] 4.1 Add unit tests for catalog parsing, schema validation, stable-ID/model-index lookup, search normalization, and locale fallback.
- [ ] 4.2 Add migration tests for exact scientific-name matches, unmatched legacy text, repeated migration, and stable-ID persistence.
- [ ] 4.3 Add classifier integration tests for correct label mapping, unknown indices, and model/catalog mismatch errors.
- [ ] 4.4 Add widget tests for picker opening, search, selection, empty state, identification failure, and localized display.
- [ ] 4.5 Run `fvm dart format --line-length=120 .`, `fvm flutter analyze`, and `fvm flutter test`; verify offline catalog access and APK asset inclusion.
