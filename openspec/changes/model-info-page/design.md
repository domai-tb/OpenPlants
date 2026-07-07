## Context

The app bundles an ONNX model (`model.onnx`) with 14,829 species labels (`labels.json`) for local plant identification. Currently there is no way for users to see which model is installed, its version, license terms, or operational limits. This opacity undermines trust—users cannot verify what they're running or understand confidence score meaning.

The project follows Clean Architecture with a 5-file feature pattern (`datasource`, `repository`, `usecases`, `entity`, `page`). All pages live under `lib/pages/`. Dependencies flow Page → UseCase → Repository → DataSource. GetIt provides DI via `lib/core/injection.dart`, exposed through `AppScope.of(context).services`.

## Goals / Non-Goals

**Goals:**
- Surface model metadata (name, version, license, input size, label count, confidence behavior) to users
- Provide a single source of truth for model metadata via a `model_meta.json` asset
- Follow existing architecture patterns (5-file feature, GetIt DI, Clean Architecture layers)
- Keep the page read-only and low-maintenance

**Non-Goals:**
- Model update/download mechanism (future work)
- Runtime model switching or A/B testing
- Detailed technical internals (tensor shapes, preprocessing math) beyond what aids transparency
- Analytics or telemetry about model usage

## Decisions

### Decision 1: Static metadata asset (`model_meta.json`)

**Choice:** Add a `model_meta.json` file to `assets/ml/plant-identification/` containing version, license, limits, and confidence behavior description.

**Rationale:** Model metadata is immutable at build time. A static JSON asset is the simplest source of truth—no code generation, no build-time injection. The file travels with the model asset and can be updated independently when the model changes.

**Alternatives considered:**
- Hardcoded constants in Dart: Fragile—requires code changes for every model update. Rejected.
- Reading from ONNX metadata: Not all models embed version/license. Unreliable. Rejected.
- Build-time injection via `--dart-define`: Adds complexity, no runtime benefit. Rejected.

### Decision 2: New feature module (`lib/pages/model_info/`)

**Choice:** Create a standard 5-file feature module with `ModelInfoDatasource`, `ModelInfoRepository`, `ModelInfoUseCases`, `ModelInfoItemEntity`, and `ModelInfoPage`.

**Rationale:** Follows the established project pattern. Even though this is a simple read-only page, using the same structure keeps the codebase consistent and makes it easy to extend later (e.g., adding model update status).

**Alternatives considered:**
- Inline page in settings: Violates the 5-file pattern. Rejected.
- Shared widget in `lib/core/`: Over-engineered for a single-use display. Rejected.

### Decision 3: Navigation entry in settings

**Choice:** Add "Model Information" as a tile in the settings page, linking to the new `ModelInfoPage`.

**Rationale:** Settings is the natural home for metadata/transparency screens. Keeps the identification flow uncluttered.

**Alternatives considered:**
- Button on identification result screen: Clutters the primary flow. Rejected.
- About page: Too generic—model info deserves its own dedicated screen. Rejected.

## Risks / Trade-offs

- **[Risk] Model metadata drifts from actual model** → Mitigation: Document the update checklist—when swapping `model.onnx`, update `model_meta.json` in the same commit. Add a comment in the asset directory.
- **[Risk] Page feels too technical for casual users** → Mitigation: Write labels in plain language. Technical details (input dimensions) shown behind a "Technical Details" expandable section.
- **[Trade-off] Static asset vs. runtime introspection** → Accepted: Static JSON is simpler and sufficient. Runtime introspection (reading ONNX metadata) adds complexity for marginal gain.
