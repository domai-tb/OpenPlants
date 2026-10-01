# OpenPlants 🌱

OpenPlants is an open-source, privacy-friendly Flutter companion for tracking plant care.

## Features

- Plant collection, care schedules, journal, and photo timeline
- Local care reminders
- Plant identification, symptom diagnosis, and light assessment
- Dark mode, system text scaling, and English/German localization

Plant identification requires ONNX model files in `assets/ml/plant-identification/`; those model files are not included
in this checkout.

## Development

Flutter is pinned with FVM. From the repository root:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter analyze
fvm flutter test --dart-define=platform=vm
```

Feature modules live under `lib/pages/`; app-wide services and dependency setup live under `lib/core/`. Tests are in `test/`.

## License

AGPL v3 — See [LICENSE](LICENSE).
