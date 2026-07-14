# Localization Code Review Checklist

Use this checklist when reviewing code that adds or modifies user-facing text.

## String Handling

- [ ] **No hardcoded user-facing strings in Dart code** — All user-facing text uses `context.l10n.someKey`
- [ ] **New strings added to ARB files** — Every new key exists in `assets/l10n/l10n_en.arb` and at minimum a placeholder in `l10n_de.arb`
- [ ] **ARB files regenerated** — Run `fvm flutter gen-l10n` after editing ARB files
- [ ] **No manual edits to `lib/l10n/`** — Generated files are overwritten on regeneration

## Text Overflow & Layout

- [ ] **No fixed-width containers with text** — Use `Flexible`, `Expanded`, or `IntrinsicWidth` instead of `SizedBox(width: N)` when text is inside
- [ ] **Text widgets have overflow strategy** — Use `TextOverflow.ellipsis`, `TextOverflow.fade`, or wrapping for potentially long text
- [ ] **Buttons use intrinsic width** — No `width: 120` on buttons containing localizable text; use padding or `IntrinsicWidth`
- [ ] **German text expansion considered** — German labels are 30-40% longer than English; layouts must accommodate this

## Units & Formatting

- [ ] **Temperature uses `TemperatureFormatter`** — Never hardcode `°C` or `°F` in Dart code
- [ ] **Dates use `DateFormatter` or `DateFormat`** — Never hardcode date patterns like `dd/MM/yyyy`
- [ ] **Numbers use locale-aware formatting** — Use `NumberFormat` from `intl` package

## Date & Time

- [ ] **Date format follows locale** — English: `Jul 6, 2026`, German: `6. Juli 2026`
- [ ] **Time format follows locale** — English: `3:04 PM`, German: `15:04`
- [ ] **Relative dates are translatable** — "Today", "Yesterday", "X days ago" should use ARB strings

## Common Mistakes

- ❌ `Text('25°C')` → Use `TemperatureFormatter.format(25.0)`
- ❌ `Text('${date.day}/${date.month}/${date.year}')` → Use `DateFormatter.formatShort(date)`
- ❌ `SizedBox(width: 120, child: Text(someLocalizedString))` → Use `Flexible` or `IntrinsicWidth`
- ❌ `Text('Settings')` → Use `Text(context.l10n.settingsTitle)`
