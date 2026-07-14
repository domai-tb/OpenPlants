## ADDED Requirements

### Requirement: Privacy page is displayed during onboarding

The system SHALL display a dedicated privacy page as the second step in the first-run onboarding flow, appearing after the welcome/intro page and before the preferences page. The page SHALL explain the app's privacy model using four distinct statements presented as icon-labelled cards or rows.

#### Scenario: New user sees privacy page during onboarding
- **WHEN** a user launches OpenPlant for the first time
- **AND** the onboarding flow begins
- **AND** the user taps "Next" on the intro page
- **THEN** the system SHALL display the privacy page as the next screen
- **AND** the privacy page SHALL contain a title and four privacy statements

#### Scenario: Each privacy statement has an icon, heading, and body
- **WHEN** the privacy page is displayed
- **THEN** each privacy statement SHALL include a Material icon
- **AND** a bold heading (one or two words)
- **AND** a short body sentence explaining the promise

#### Scenario: "Next" advances to preferences
- **WHEN** the user is on the privacy page
- **AND** the user taps the "Next" button
- **THEN** the system SHALL advance to the preferences page

### Requirement: Four privacy promises are stated

The privacy page SHALL state the following four promises, each with an appropriate icon:

1. **Works Locally** — All data and processing happen on-device. No internet connection is needed.
2. **No Account Required** — No sign-up, login, or account creation. Just open and use.
3. **Photos Stay Private** — Plant photos are processed on-device and are never uploaded.
4. **No Third Parties** — No analytics SDKs, no ad trackers, no external services.

#### Scenario: "Works Locally" promise is displayed
- **WHEN** the privacy page is rendered
- **THEN** a row or card SHALL display with heading "Works Locally" and an appropriate icon (e.g. `Icons.phonelink_off_outlined`)
- **AND** body text SHALL explain that all data and processing happen on-device

#### Scenario: "No Account Required" promise is displayed
- **WHEN** the privacy page is rendered
- **THEN** a row or card SHALL display with heading "No Account Required" and an appropriate icon (e.g. `Icons.account_circle_off_outlined`)
- **AND** body text SHALL explain that no sign-up or login is needed

#### Scenario: "Photos Stay Private" promise is displayed
- **WHEN** the privacy page is rendered
- **THEN** a row or card SHALL display with heading "Photos Stay Private" and an appropriate icon (e.g. `Icons.cloud_off_outlined`)
- **AND** body text SHALL explain that photos are processed on-device and never uploaded

#### Scenario: "No Third Parties" promise is displayed
- **WHEN** the privacy page is rendered
- **THEN** a row or card SHALL display with heading "No Third Parties" and an appropriate icon (e.g. `Icons.shield_outlined`)
- **AND** body text SHALL explain that no analytics, trackers, or external services are used

### Requirement: Privacy summary is visible on the intro page

The intro (welcome) page SHALL include a compact visual privacy summary below the hint text, showing the four privacy promises as a bulleted or badge-style list with small icons and short labels.

#### Scenario: Intro page shows privacy summary badges
- **WHEN** the intro page is displayed during onboarding
- **THEN** the page SHALL display a compact list of four privacy badges below the hint text
- **AND** each badge SHALL consist of a small icon and a short label (e.g. "Local", "No account", "Private photos", "No trackers")

### Requirement: All privacy copy is localised

The privacy page content and the intro-page summary SHALL use localised strings from the app's ARB files for both English and German locales.

#### Scenario: Privacy page uses localised English strings
- **WHEN** the device locale is English
- **THEN** the privacy page SHALL display English text from `l10n_en.arb`

#### Scenario: Privacy page uses localised German strings
- **WHEN** the device locale is German
- **THEN** the privacy page SHALL display German text from `l10n_de.arb`

### Requirement: Onboarding completion is unchanged

Completing the onboarding (after the preferences page) SHALL still set `didCompleteOnboarding = true` via the existing `_applySettings()` method. The new privacy page SHALL NOT change the settings model or completion logic.

#### Scenario: Onboarding still completes after privacy page
- **WHEN** the user navigates through intro → privacy → preferences
- **AND** taps "Finish" on the preferences page
- **THEN** `didCompleteOnboarding` SHALL be set to `true`
- **AND** the user SHALL be taken to the HomePage on subsequent launches
