# OpenPlant 🌱

An open-source & privacy-friendly companion app for your plants.

## Features

- Track your plants and their care routines
- Set watering and care reminders
- Responsive layout (bottom nav on phones, side nav on tablets)
- Dark mode support
- Multi-language support (English, German)

## Architecture

Clean Architecture with layered design:
- **Presentation**: Flutter widgets (pages)
- **Application**: Use-cases orchestrate business logic
- **Domain**: Entities and repositories
- **Infrastructure**: Datasources (API, DB, platform)

## Getting Started

```bash
fvm flutter pub get
fvm flutter run
```

## Project Structure

- `lib/pages/` — Feature modules (page1–page6 placeholders)
- `lib/core/` — App-wide concerns (settings, theme, DI)
- `lib/widgets/` — Reusable UI building blocks
- `assets/l10n/` — Localization ARB files

## License

AGPL v3 — See [LICENSE](LICENSE).
