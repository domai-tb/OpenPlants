## 1. Core Implementation

- [x] 1.1 Add plant status update logic to `CareScheduleUsecases.completeTask()` — after recording completion and journal entry, load the plant by ID and call `markAsWatered()` for watering tasks or `markAsFertilized()` for fertilizing tasks
- [x] 1.2 Wrap the plant status update in try/catch for graceful degradation — log errors but don't fail the task completion

## 2. Verification

- [x] 2.1 Run `fvm flutter analyze` to verify no lint errors
- [x] 2.2 Run `fvm flutter test` to verify existing tests pass
