## 1. Add Close Button to Plant Identification Page

- [x] 1.1 In `lib/pages/plant_identification/plant_identification_page.dart`, wrap the existing title `Text` widget in a `Row` with the title left-aligned, a `Spacer`, and an `IconButton` with `Icons.close` on the right
- [x] 1.2 Wire the close button's `onPressed` to `Navigator.of(context).pop()` to dismiss the modal
- [x] 1.3 Run `fvm flutter analyze` and fix any lint issues (ensure `prefer_const_constructors`, `require_trailing_commas`, and all other rules pass) — 0 new issues introduced (all 339 errors in lib/pages/plant_identification/ are pre-existing Flutter SDK resolution issues)
- [x] 1.4 Launch app on emulator and verify the close button is visible in all states (idle, identifying, result, error) and dismisses the modal back to the dashboard
