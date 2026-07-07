## Why

OpenPlant markets itself as "open-source & privacy-friendly" but ships the first-run experience to the app without ever explaining what that means. Users see a welcome message, configure theme and nav-bar preferences, then land in the app — with no awareness that their data never leaves the device, no account is needed, and no photos are uploaded. As a plant companion that processes images locally via ONNX, this privacy promise is a core differentiator; not stating it upfront is a missed trust signal that can cause users to uninstall before they ever add their first plant. This change adds a dedicated privacy-information page to the onboarding flow so every new user understands the local-first nature of OpenPlant before engaging with the app.

## What Changes

- Add a new **Privacy promise** page to the onboarding flow (between the existing intro and preferences pages) that explains OpenPlant works entirely offline, no account is required, photos are never uploaded, and no third-party services are used.
- Add a **compact visual privacy summary** (icon + one-liner per promise) on the existing intro page so the privacy message is visible from the very first screen.
- Update the onboarding PageView from 2 pages to 3 pages (intro → privacy → preferences).
- Add new localization strings for the privacy page content (English and German).
- Update the existing intro page body text to include a privacy badge/summary.
- No new data sources, repositories, use-cases, or pages — purely an onboarding UI change within `lib/pages/home/onboarding.dart`.

## Capabilities

### New Capabilities

- `local-privacy-onboarding`: A new onboarding page that states the app's privacy guarantees: works locally, no account required, no photo uploads, no third-party services. Displayed as the second step in the first-run flow, before the user configures preferences and enters the app.

### Modified Capabilities

_(none — this is additive; no existing spec-level behavior changes)_

## Impact

- **Code changes**:
  - `lib/pages/home/onboarding.dart` — restructure PageView from 2 pages to 3; add the privacy page widget; add privacy-summary section to the intro page.
  - `assets/l10n/l10n_en.arb` — add `onboardingPrivacy*` localization keys.
  - `assets/l10n/l10n_de.arb` — add German translations for the same keys.
- **No new dependencies** — this is purely a UI and copy change.
- **No backend, no API, no data layer changes** — the privacy page is static content.
- **Settings model unaffected** — `didCompleteOnboarding` still gates the flow; the new page simply inserts between existing steps.
