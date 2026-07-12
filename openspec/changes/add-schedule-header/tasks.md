## 1. Schedule Page — Replace AppBar with Centered Inline Header

- [ ] 1.1 Remove `Scaffold.appBar` from `CareSchedulePage.build()` and add a centered inline header as the first child of the `Column` in `_buildContent()` — using `Padding(EdgeInsets.symmetric(horizontal: 20, vertical: 10))` > `Text(context.l10n.careScheduleTitle, style: theme.textTheme.displayMedium, textAlign: TextAlign.center)`
- [ ] 1.2 Adjust body layout — move the header above `_buildFilters`, ensure `Expanded > ListView` still works correctly

## 2. Today Page — Center Existing Header

- [ ] 2.1 Update `_buildHeader()` in `today_dashboard_page.dart` to add `textAlign: TextAlign.center` on the `Text` widget
- [ ] 2.2 Verify both call sites of `_buildHeader()` (`_buildBody` and `_buildLoadingState`) display correctly with centered alignment

## 3. More Page — Center Existing Header

- [ ] 3.1 Update the inline header `Text` in `more_page.dart` to add `textAlign: TextAlign.center`

## 4. Verify

- [ ] 4.1 Run `fvm flutter analyze` to ensure no lint violations
- [ ] 4.2 Run `fvm flutter test` to verify existing tests still pass
