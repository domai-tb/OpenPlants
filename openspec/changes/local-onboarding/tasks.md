## 1. Localization Strings

- [ ] 1.1 Add English privacy-page localization keys to `assets/l10n/l10n_en.arb`
- [ ] 1.2 Add German privacy-page localization keys to `assets/l10n/l10n_de.arb`
- [ ] 1.3 Regenerate Flutter localizations with `fvm flutter gen-l10n`

## 2. Onboarding Privacy UI

- [ ] 2.1 Restructure `onboarding.dart` PageView from 2 children to 3 children (intro → privacy → preferences)
- [ ] 2.2 Create `_PrivacyPage` StatelessWidget with icon-labelled privacy promise rows
- [ ] 2.3 Add compact privacy-summary badges to the intro page below the hint text
- [ ] 2.4 Update page-navigation logic: back button disabled on page 0 only; "Next" on pages 0 and 1; "Finish" on page 2

## 3. Verification

- [ ] 3.1 Run `fvm flutter analyze` and fix any lint violations
- [ ] 3.2 Verify onboarding flow: intro shows privacy badges → tap Next → privacy page with 4 promises → tap Next → preferences → tap Finish → HomePage
