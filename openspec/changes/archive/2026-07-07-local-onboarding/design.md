## Context

OpenPlant currently shows a 2-page onboarding on first launch: an intro page with the app title, a welcome message, and a hint; then a preferences page for theme, accessibility, and nav-bar configuration. Once dismissed, `settings.didCompleteOnboarding` flips to `true` and the user sees `HomePage` on subsequent starts.

The app's privacy story (local-only, no account, no uploads, no third-party services) is never stated during onboarding — users only discover it implicitly via the "About" page. Since ONNX-based plant identification is the app's marquee feature (and processes photos locally), the privacy promise is a trust-building differentiator that belongs front-and-centre before the user adds their first plant.

This design inserts a dedicated **Privacy page** into the onboarding flow and enriches the intro page with a compact visual privacy summary.

## Goals / Non-Goals

**Goals:**

- Add a new privacy page as the second step in the 3-page onboarding flow (intro → privacy → preferences).
- Each privacy promise is presented with an icon, a bold headline, and a short body sentence.
- Compact privacy-summary badges on the intro page so the message is visible from the very first screen.
- All copy localised in English and German.
- Onboarding completion continues to set `didCompleteOnboarding = true` via the existing `_applySettings()` method — no changes to the settings model.

**Non-Goals:**

- No changes to the `Settings` model, `SettingsController`, or persistence.
- No new data sources, repositories, use-cases, or feature pages.
- No backend, network, or dependency changes.
- No changes to the preferences page content or logic.
- No analytics or event tracking for which onboarding page the user saw.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Page insertion point** | Between intro and preferences | Natural narrative flow: "Welcome → Here's our privacy promise → Now configure your experience". The preferences page is the last step before entering the app — privacy info should come before configuration, not after. |
| **Privacy page widget** | Standalone `StatelessWidget` (`_PrivacyPage`) in `onboarding.dart` | Keeps all onboarding code in one file. The page is purely presentational (no state) so a `StatelessWidget` suffices. Consistent with the existing pattern (intro and preferences are inline widgets within `_OnboardingPageState.build`). |
| **Privacy page navigation** | Third item in the existing `PageView` children list | The `PageController` already handles swipe/page-button navigation. Page index 0 = intro, 1 = privacy, 2 = preferences. The existing `TextButton` (back) / `FilledButton` (next/finish) logic updates to accommodate the new index. |
| **Privacy summary on intro** | Column of `Row(Icon, Text)` entries below the hint text | Compact visual treatment. Uses a subtle dot-separator or bullet style. No animation or interactivity — static informational element. |
| **Visual treatment** | Shield/lock/circle-check icons, muted secondary text colour | Matches Material 3 card/body styling already used in onboarding. Icons from `Icons.shield_outlined`, `Icons.phonelink_off_outlined`, `Icons.cloud_off_outlined`, `Icons.account_circle_off_outlined`. |
| **Localization keys** | `onboardingPrivacy*` prefix, one key per element | Follows existing naming convention (`onboardingIntroBody`, `onboardingIntroHint`, `onboardingPreferencesTitle`). |

### Alternatives considered

- **Single expanded intro page** (combined welcome + privacy): Rejected — the privacy message would compete with the welcome text and lose visual weight. A dedicated page signals importance.
- **Privacy as a dialog or bottom sheet**: Rejected — modals can be dismissed without reading. The PageView ensures users must consciously page through (or press "Next") to proceed.
- **Skip privacy if returning user**: Not applicable — onboarding is first-run only.

## Risks / Trade-offs

- **[Onboarding length] Adding a third page increases onboarding time by ~5–10 seconds.** → Mitigation: the privacy page is purely informational (no interactive controls), so users can rapidly tap "Next" through it. The trust benefit of stating the privacy promise outweighs the friction.
- **[Translation maintenance] New localization keys add to the ARB file burden.** → Mitigation: only two locales are currently supported (en, de). The copy is short and stable. No repeated sync overhead.
- **[Navigation logic regression] Inserting a page changes the `_pageIndex` mapping.** → Mitigation: the existing `_pageIndex == 0` check (for back-button disable) and `_pageIndex == 0` → "Next" / else → "Finish" logic will be updated to `_pageIndex == 0` → "Next", `_pageIndex == 1` → "Next", `_pageIndex == 2` → "Finish". Adding a test after implementation is recommended.
