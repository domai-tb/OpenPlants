import 'dart:io' show Platform;

/// Height of the bottom navigation bar.
/// iOS: 88px (includes home indicator padding)
/// Android: 98px (includes gesture navigation bar)
const double kBottomNavBarHeight = 88;

/// Android bottom nav bar height (includes gesture navigation bar)
const double kBottomNavBarHeightAndroid = 98;

/// Width of each item in the bottom navigation bar
const double kNavBarItemWidth = 80;

/// Returns the platform-appropriate navbar height
double get bottomNavBarHeight => Platform.isIOS ? kBottomNavBarHeight : kBottomNavBarHeightAndroid;

/// Sentinel value for the "New Room" option in room pickers.
const String kNewRoomSentinel = '__new_room__';

/// Sentinel value for the "Unassigned" filter in plant collection.
const String kUnassignedSentinel = '__unassigned__';
