## Why

Users currently record plant problems by taking a photo, but photos alone don't capture the full picture. A yellow leaf could mean overwatering, nutrient deficiency, or light stress — the diagnosis depends on context like soil moisture, when symptoms appeared, which parts are affected, and environmental conditions. Without structured symptom data, the app can't provide meaningful care recommendations or track health trends over time.

## What Changes

- Add a structured symptom logging flow that collects: symptom type (yellow leaves, brown tips, drooping, pests, mold, soft stems, dry/wet soil, leaf spots), severity level, affected plant parts, onset timing, soil moisture observation, light conditions, and optional notes
- Each log entry links to a specific plant and is stored locally for history tracking
- Symptom logs feed into the care-tracking timeline so users can see health events alongside care actions
- Optional photo attachment per symptom entry (reuses existing camera-capture capability)

## Capabilities

### New Capabilities

- `symptom-logger`: Structured symptom recording — form UI, entity model, local persistence, and integration with the plant's care timeline

### Modified Capabilities

- `care-tracking`: Symptom logs appear as health events in the care timeline alongside watering, fertilizing, and repotting records

## Impact

- New feature module: `lib/pages/symptom_logger/` (5-file pattern)
- New entity: `SymptomLogEntry` with fields for symptom type, severity, parts, timing, environment, notes, photo path
- New local storage: symptom logs persisted via existing offline-storage patterns
- Modification to care-tracking timeline to display symptom events
- Navigation entry in home/more page for quick access to symptom logging
- No new external dependencies — uses existing shared_preferences/local storage patterns
