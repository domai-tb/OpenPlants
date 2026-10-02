## Context

Plant creation currently accepts species as free text while the classifier already exposes 14,829 model labels. The repository also has an existing bundled species dataset and localized-name capability, but their contracts are scientific-name-centric and do not provide a shared selectable catalog. Android/offline operation, the existing Clean Architecture feature pattern, and stable persisted plant records constrain the design.

## Goals / Non-Goals

**Goals:**

- Provide one bundled catalog keyed by stable species IDs and aligned to classifier label indices.
- Replace unrestricted species entry with searchable selection while retaining manual blank/error states where appropriate.
- Support locale-specific names and catalog information without putting thousands of records into ARB UI translations.
- Preserve existing plants through a migration from text values to species references.
- Keep catalog loading lazy, cached, deterministic, and testable.

**Non-Goals:**

- Remote taxonomy downloads, user-created species, or server-side synchronization.
- Automatic translation generation or completeness for every locale in the first release.
- Changes to ONNX preprocessing, inference, or model quality.

## Decisions

### Stable catalog identity

Use a stable catalog ID for every species and retain model label index as an explicit mapping field. Plant records persist the ID; UI resolves names through the active locale. This avoids breaking persisted data when translations change and avoids matching classifier output by display text.

### Bundled data format

Ship model-aligned catalog data as versioned JSON assets. Keep core species records separate from locale dictionaries so one base record can serve multiple locales without duplicating care metadata. Include scientific name as required fallback and validate uniqueness, label coverage, and schema before packaging.

### Loading and architecture

Extend the existing species datasource/repository/use-case layers rather than introducing global state. Load assets lazily and cache immutable entities in memory. Expose catalog operations through `AppServices`; widgets access them through `AppScope`.

### Search and selection

Expose deterministic case-insensitive search over localized common name, scientific name, and aliases. The picker renders a bounded result set and does not eagerly build a widget for all records. Selection returns the stable ID and the form displays the localized name.

### Localization

Keep UI labels and picker messages in ARB files. Keep species names, aliases, descriptions, and information in locale-keyed catalog assets. Resolve active locale, then configured fallback locale, then scientific name; missing optional information remains absent rather than translated at runtime.

### Compatibility migration

On read, recognize existing text species values. Map exact scientific-name matches to catalog IDs; preserve unmatched text in a legacy field or migration-safe representation until the user edits the plant. New writes use IDs only. Migration must be idempotent and reversible by retaining original text during rollout.

## Risks / Trade-offs

- **[Catalog/model drift]** Labels can change independently of catalog data → validate every model index and fail generation on missing or duplicate mappings.
- **[APK size]** Locale assets increase bundle size → split base metadata from locale files and include only supported initial locales.
- **[Incomplete translations]** Most species may lack localized names → always retain scientific-name fallback and test missing-locale behavior.
- **[Search performance]** 14k records can cause UI jank → cache normalized search fields, filter in use-case/repository code, and limit rendered results.
- **[Legacy data ambiguity]** Free text can contain aliases or typos → migrate exact matches automatically and preserve unmatched values for explicit user correction.
- **[Asset corruption]** Malformed bundled JSON can break catalog access → validate at build time and return classified datasource failures at runtime.

## Migration Plan

1. Add catalog assets, schema validation, repository APIs, and tests without changing persisted plant fields.
2. Add stable species reference fields and read-time compatibility for existing text values.
3. Update add/edit UI and classifier result selection to write catalog IDs.
4. Run migration for exact matches; preserve unmatched legacy text and provide a selectable replacement path.
5. Roll back UI and writes if needed; retain additive catalog assets and compatibility readers so existing records remain readable.

## Open Questions

- Which initial locale set should ship beyond English?
- Should unmatched legacy text remain visible as a custom label, or require replacement before save?
- Which model-label generation source is authoritative when future model versions contain renamed labels?
