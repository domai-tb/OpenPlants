## 1. Asset Setup

- [ ] 1.1 Create `assets/ml/plant-identification/model_meta.json` with fields: name, version, license, inputSize, labelCount, confidenceDescription
- [ ] 1.2 Register `model_meta.json` in `pubspec.yaml` under `flutter > assets` if not already covered by the directory glob

## 2. Feature Module — Entity

- [ ] 2.1 Create `lib/pages/model_info/model_info_item_entity.dart` with `ModelInfoItem` class holding all metadata fields (name, version, license, inputSize, labelCount, confidenceDescription)

## 3. Feature Module — DataSource

- [ ] 3.1 Create `lib/pages/model_info/model_info_datasource.dart` with `ModelInfoDatasource` that loads and parses `model_meta.json` from the asset bundle

## 4. Feature Module — Repository

- [ ] 4.1 Create `lib/pages/model_info/model_info_repository.dart` with `ModelInfoRepository` that maps raw JSON from the datasource to `ModelInfoItem` entities

## 5. Feature Module — UseCase

- [ ] 5.1 Create `lib/pages/model_info/model_info_usecases.dart` with `ModelInfoUseCase` that exposes a `getModelInfo()` method returning `ModelInfoItem`

## 6. Feature Module — Page

- [ ] 6.1 Create `lib/pages/model_info/model_info_page.dart` as a `StatefulWidget` that fetches model info via the use-case and displays: model name/version (prominent), license, input dimensions, label count, and confidence description
- [ ] 6.2 Use a clean layout with sections: "Model", "Technical Details", "Confidence Behavior"

## 7. DI Registration

- [ ] 7.1 Register `ModelInfoDatasource`, `ModelInfoRepository`, and `ModelInfoUseCase` in `lib/core/injection.dart` as lazy singletons
- [ ] 7.2 Add `ModelInfoUseCase` field to `AppServices` in `lib/core/app_services.dart` and pass it through the constructor

## 8. Navigation

- [ ] 8.1 Add a "Model Information" entry to the settings page (`lib/pages/more/more_settings_page.dart`) that navigates to `ModelInfoPage`

## 9. Validation

- [ ] 9.1 Run `fvm flutter analyze` and fix any lint violations
- [ ] 9.2 Run `fvm flutter test` and ensure no regressions
