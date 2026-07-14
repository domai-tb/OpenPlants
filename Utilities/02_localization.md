# Localization (l10n)

OpenPlants uses Flutter's built-in `gen-l10n` system with ARB files.

## Where Translations Live

- `assets/l10n/l10n_en.arb`
- `assets/l10n/l10n_de.arb`

Configuration lives in `l10n.yaml`; generated output is written to `lib/l10n/`.

## Using Translations in Widgets

Use the `BuildContext` extension from `lib/l10n/l10n_x.dart`:

```dart
Text(context.l10n.appTitle)
```

## Adding a New String

1. Add the key to every supported locale in `assets/l10n/`.
2. Run `fvm flutter gen-l10n` to regenerate `lib/l10n/`.
3. Use the new key via `context.l10n.<key>`.

`LocaleService` applies an explicit user choice when supported, otherwise uses the device locale and falls back to English. Keep the ARB files aligned so that every supported locale has each key.
