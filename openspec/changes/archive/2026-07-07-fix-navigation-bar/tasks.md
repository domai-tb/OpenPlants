## 1. Remove per-item padding overrides

- [x] 1.1 Remove `iconPaddingLeft` and `iconPaddingRight` fields from `PageItemPresentation` class in `page_navigator.dart`
- [x] 1.2 Remove `iconPaddingLeft` and `iconPaddingRight` parameters from all `PageItemPresentation()` constructors in `pageItemPresentation()` function
- [x] 1.3 Remove `iconPaddingLeft` and `iconPaddingRight` fields from `BottomNavBarItem` widget in `bottom_nav_bar_item.dart`
- [x] 1.4 Remove `iconPaddingLeft` and `iconPaddingRight` parameters from `BottomNavBarItem()` constructor and the `Padding` widget that uses them

## 2. Replace Row with PageView in BottomNavBar

- [x] 2.1 Replace `SingleChildScrollView` + `Row` with `PageView.builder` in `bottom_nav_bar.dart`
- [x] 2.2 Add `PageController` to `_BottomNavBarState` and sync it with `widget.currentPage`
- [x] 2.3 Set `PageController.initialPage` to the index of `widget.currentPage` in `widget.pages`
- [x] 2.4 Add `viewportFraction` to control how many adjacent items are visible (start with ~0.2)
- [x] 2.5 Use `PageScrollPhysics` for snap-to-item behavior

## 3. Sync PageController with page changes

- [x] 3.1 Add `didUpdateWidget` to animate `PageController` when `widget.currentPage` changes from parent
- [x] 3.2 Handle the case where the user swipes the bar (update selection via `onPageChanged` callback)
- [x] 3.3 Dispose `PageController` in `dispose()`

## 4. Verify and test

- [x] 4.1 Run `fvm flutter analyze` to check for lint violations
- [ ] 4.2 Test with maximum visible pages (9) — verify no overflow
- [ ] 4.3 Test with minimum visible pages (3) — verify centering works
- [ ] 4.4 Test active item animation (slide up + label fade) still works
- [ ] 4.5 Test bar scroll-to-center on item tap
