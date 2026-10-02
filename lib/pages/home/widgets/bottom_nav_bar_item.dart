import 'package:flutter/material.dart';
import 'package:openplants/widgets/custom_button.dart';

const _iconHeight = 26.0;
const _animationCurve = Curves.easeOutExpo;
const _animationDuration = Duration(milliseconds: 300);

/// A widget that displays an item in the bottom navigation menu which allows the user
/// to switch between different pages. When active, the whole item is moved up and the title
/// text fades in while also moving up. The item also changes its icon-color when it's the
/// active navigation menu item.
class BottomNavBarItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;

  /// Padding above and below the icon
  final double iconVerticalPadding;

  /// Title of the page that this menu item refers to
  final String title;

  /// Callback that should be called whenever the button is tapped
  final VoidCallback onTap;

  /// Wether the refered page is the currently displayed one
  final bool isActive;

  const BottomNavBarItem({
    super.key,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.title,
    this.iconVerticalPadding = 6,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomButton(
      tapHandler: onTap,
      child: AnimatedPadding(
        padding: isActive ? const EdgeInsets.only(top: 2) : const EdgeInsets.only(top: 7),
        duration: _animationDuration,
        curve: _animationCurve,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: iconVerticalPadding,
                bottom: iconVerticalPadding,
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                size: _iconHeight,
                color: isActive ? colorScheme.secondary : colorScheme.onSurfaceVariant,
              ),
            ),
            AnimatedPadding(
              padding: isActive ? EdgeInsets.zero : const EdgeInsets.only(top: 6),
              duration: _animationDuration,
              curve: _animationCurve,
              child: Center(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
