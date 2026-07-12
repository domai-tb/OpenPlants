# Feature Areas

OpenPlants exposes three primary navigation destinations: **Today**, **Care Schedule**, and **More**. The dashboard and feature detail screens provide access to the wider set of plant-management tools.

## Plant Management

- **Plant Collection** — create, edit, and inspect the user's plants.
- **Plant Journal** and **Photo Timeline** — record observations and photos over time.
- **Room Profiles** — maintain room context used by care and diagnosis features.
- **Plant Names** — manage plant naming data.

## Care and Insights

- **Today Dashboard** — presents the current plant overview.
- **Care Schedule** — calculates and manages care tasks, including custom care rules.
- **Light Assessment** — assesses light with camera-based estimation and can associate a result with a plant photo.
- **Symptom Logger** and **Diagnosis** — capture symptoms, keep diagnosis history, and provide automated diagnosis support.

## Reference and Identification

- **Plant Identification** — uses the bundled local classifier to identify a plant from an image.
- **Species Library** — provides species information and care-plan data.
- **Model Info** — presents information about the bundled identification model.

Each feature owns its presentation, use cases, repository, data source, and domain data where those layers apply. See [Architecture](Architecture) for the dependency rules.

---

# More

The **More** destination provides navigation to app settings and the About screen.

## Settings

Settings are stored locally and take effect immediately. Users can choose:

- system, light, or dark theme;
- system default, English, or German language;
- Celsius or Fahrenheit temperature display; and
- whether to respect the system text-scaling preference.

The settings UI is implemented in `lib/pages/more/more_settings_page.dart`; persistence is owned by `SettingsController` in `lib/core/settings.dart`.

---

