## 1. Room Data Layer

- [ ] 1.1 Create `room_profiles/` module directory with the 5-file pattern (datasource, repository, usecases, entity, page)
- [ ] 1.2 Define `RoomEntity` with id, name, lightLevel (enum), humidityLevel (enum), notes, createdAt, updatedAt
- [ ] 1.3 Define `LightLevel` enum (low, medium, bright, directSun) and `HumidityLevel` enum (low, medium, high) with JSON serialization
- [ ] 1.4 Implement `RoomProfilesDatasource` — shared_preferences JSON persistence for rooms list
- [ ] 1.5 Implement `RoomProfilesRepository` — maps raw JSON to RoomEntity, enforces unique names
- [ ] 1.6 Implement `RoomProfilesUsecases` — create, update, delete, getAll, getById operations
- [ ] 1.7 Register room profiles classes in `lib/core/injection.dart` (lazy singletons)

## 2. Room Management UI

- [ ] 2.1 Build `RoomProfilesPage` — list view showing all rooms with name, light badge, humidity badge
- [ ] 2.2 Build empty state for rooms page ("No rooms yet" with add button)
- [ ] 2.3 Build room creation/edit form with name input, light level dropdown, humidity level dropdown, notes field
- [ ] 2.4 Add room preset selector (Bedroom, Kitchen, Bathroom, Living Room, Balcony, Office) with pre-filled defaults
- [ ] 2.5 Implement delete confirmation dialog with affected-plants count display
- [ ] 2.6 Add navigation entry for rooms page in the "More" tab or settings

## 3. Plant Collection — Room Integration

- [ ] 3.1 Add `roomId` field (String?) to `PlantEntity` alongside existing `room` string field
- [ ] 3.2 Update `PlantEntity` JSON serialization to include `roomId`
- [ ] 3.3 Update `PlantCollectionDatasource` to handle roomId in persistence
- [ ] 3.4 Replace free-text room input in `PlantCollectionFormPage` with room picker dropdown
- [ ] 3.5 Add "+ New Room" trailing option in room picker that navigates to room creation
- [ ] 3.6 Pre-select the newly created room when returning from room creation form
- [ ] 3.7 Display room name badge (from roomId reference) on plant collection list items

## 4. Plant Collection — Room Filtering

- [ ] 4.1 Add room filter chip row above the plant collection list
- [ ] 4.2 Implement "All" filter chip as default selection
- [ ] 4.3 Populate filter chips from defined rooms (one chip per room)
- [ ] 4.4 Implement filter logic to show only plants matching selected roomId
- [ ] 4.5 Show "Unassigned" filter chip for plants with no roomId

## 5. Care Schedule Engine — Room-Aware Modifiers

- [ ] 5.1 Update care engine function signature to accept RoomEntity (or null) instead of generic room config
- [ ] 5.2 Implement light-level multipliers: directSun=0.7×, bright=0.85×, medium=1.0×, low=1.3× for watering
- [ ] 5.3 Implement humidity-level multipliers: high=1.3×, medium=1.0×, low=0.7× for watering and misting
- [ ] 5.4 Apply room multipliers in sequence with seasonal modifiers (room × season)
- [ ] 5.5 Ensure missing/null roomId defaults to 1.0× (baseline behavior)

## 6. Care UI — Room Context Display

- [ ] 6.1 Update care task cards to show assigned room name and environment summary
- [ ] 6.2 Format room context as "Room Name — LightLevel, HumidityLevel" on care cards
- [ ] 6.3 Omit room information when plant has no room assigned
- [ ] 6.4 Add room assignment indicator to the plant detail page header

## 7. Integration & Polish

- [ ] 7.1 Update `AppServices` to include `RoomProfilesUsecases` in the service aggregate
- [ ] 7.2 Add room profiles page to navigation bar or "More" tab
- [ ] 7.3 Run `fvm flutter analyze` and fix any lint violations
- [ ] 7.4 Add unit tests for `RoomProfilesUsecases` (CRUD, unique name enforcement)
- [ ] 7.5 Add unit tests for care engine room-context multipliers
- [ ] 7.6 Verify backward compatibility — existing plants with `room` string still display correctly
