## 1. Localization Strings

- [x] 1.1 Add English privacy-page localization keys to `assets/l10n/l10n_en.arb`
- [x] 1.2 Add German privacy-page localization keys to `assets/l10n/l10n_de.arb`
- [x] 1.3 Regenerate Flutter localizations with `fvm flutter gen-l10n`

## 2. Onboarding Privacy UI

- [x] 2.1 Restructure `onboarding.dart` PageView from 2 children to 3 children (intro → privacy → preferences)
- [x] 2.2 Create `_PrivacyPage` StatelessWidget with icon-labelled privacy promise rows
- [x] 2.3 Add compact privacy-summary badges to the intro page below the hint text
- [x] 2.4 Update page-navigation logic: back button disabled on page 0 only; "Next" on pages 0 and 1; "Finish" on page 2

## 3. Verification

- [x] 3.1 Run `fvm flutter analyze` and fix any lint violations
- [x] 3.2 Verify onboarding flow: intro shows privacy badges → tap Next → privacy page with 4 promises → tap Next → preferences → tap Finish → HomePage
