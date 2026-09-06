## Why

Plant species are currently entered as free text, which causes inconsistent names, weak searchability, and unreliable joins with identification-model results. A bundled catalog aligned with model labels will make plant creation dependable offline while preparing species names and information for localization.

## What Changes

- Replace free-text species entry with a searchable, selectable species picker.
- Bundle a catalog of approximately 14,000 species derived from identification-model labels.
- Store a stable species identifier rather than a localized display string.
- Add localized species names and structured species information with fallback behavior.
- Keep model-label-to-catalog mapping validated so identification results can be selected directly.
- Preserve offline use; do not add remote taxonomy synchronization in this change.

## Capabilities

### New Capabilities

- `plant-species-catalog`: Provides an offline, model-aligned catalog of selectable species, stable identifiers, searchable names, and localized metadata.

### Modified Capabilities

- `plant-inventory`: Plant records use a selected species reference instead of unrestricted species text.
- `species-data`: The bundled species dataset becomes model-aligned, identifier-based, searchable, and localization-ready.
- `localized-plant-names`: Species display names and information support catalog locales and deterministic fallback.
- `plant-classifier`: Identification results resolve through the shared species catalog and stable identifiers.

## Impact

- Plant creation and edit UI, plant entity serialization, and existing plant persistence migrations.
- New catalog data assets and generation/validation tooling based on identification-model labels.
- Species datasource, repository, and use-case layers plus dependency injection registration.
- Localization asset loading and fallback logic; ARB UI strings remain separate from large catalog data.
- Unit/widget tests for catalog parsing, search, localization fallback, model alignment, and plant-record compatibility.
