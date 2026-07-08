import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/page_navigator.dart';

class NavBarPreferencesEditor extends StatelessWidget {
  final List<PageItem> orderedItems;
  final Set<PageItem> hiddenItems;
  final ValueChanged<List<PageItem>> onOrderChanged;
  final ValueChanged<Set<PageItem>> onHiddenItemsChanged;

  const NavBarPreferencesEditor({
    super.key,
    required this.orderedItems,
    required this.hiddenItems,
    required this.onOrderChanged,
    required this.onHiddenItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.navigationLabel,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.navigationOrderHint,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.navigationSettingsAlwaysVisibleHint,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderedItems.length,
          onReorder: (oldIndex, newIndex) {
            final nextItems = List<PageItem>.from(orderedItems);
            var adjustedNewIndex = newIndex;
            if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
            final item = nextItems.removeAt(oldIndex);
            nextItems.insert(adjustedNewIndex, item);
            onOrderChanged(nextItems);
          },
          itemBuilder: (context, index) {
            final item = orderedItems[index];
            final presentation = pageItemPresentation(context, item);
            final isVisible = !hiddenItems.contains(item);
            final isLockedVisible = item == PageItem.more;

            return Padding(
              key: ValueKey(item.name),
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Icon(
                    isVisible ? presentation.activeIcon : presentation.inactiveIcon,
                  ),
                  title: Text(presentation.title),
                  subtitle: Text(
                    isLockedVisible
                        ? context.l10n.navigationSettingsAlwaysVisibleHint
                        : context.l10n.navigationVisibilityLabel,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch.adaptive(
                        value: isVisible,
                        onChanged: isLockedVisible
                            ? null
                            : (value) {
                                final nextHiddenItems = Set<PageItem>.from(hiddenItems);
                                if (value) {
                                  nextHiddenItems.remove(item);
                                } else {
                                  nextHiddenItems.add(item);
                                }
                                onHiddenItemsChanged(nextHiddenItems);
                              },
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
