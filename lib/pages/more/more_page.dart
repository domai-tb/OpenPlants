import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/more/more_about_page.dart';
import 'package:open_plant/pages/more/more_item_entity.dart';
import 'package:open_plant/pages/more/more_settings_page.dart';
import 'package:open_plant/pages/more/more_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_page.dart';
import 'package:open_plant/pages/species_library/species_library_page.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_page.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_page.dart';
import 'package:open_plant/widgets/scroll_to_top_button.dart';

class MorePage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  const MorePage({
    super.key,
    required this.mainNavigatorKey,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
  });

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> with AutomaticKeepAliveClientMixin<MorePage> {
  final ScrollController _scrollController = ScrollController();
  late MoreUsecases _usecases;
  bool _wired = false;
  bool _loading = true;
  List<MoreItemEntity> _items = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.more;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _usecases.getMenuItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _open(MoreItemEntity item) {
    switch (item.id) {
      case 'species_list':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpeciesLibraryPage()));
        break;
      case 'rooms':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoomProfilesPage()));
        break;
      case 'settings':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoreSettingsPage()));
        break;
      case 'about':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoreAboutPage()));
        break;
      case 'log_symptom':
        _logSymptom();
        break;
      case 'diagnosis':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagnosisPage()));
        break;
      default:
        break;
    }
  }

  Future<void> _logSymptom() async {
    final plantCollection = AppScope.of(context).services.plantCollection;
    final plants = await plantCollection.loadPlants();

    if (!mounted || plants.isEmpty) return;

    if (plants.length == 1) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SymptomLoggerPage(
            plantId: plants.first.id,
            plantName: plants.first.name,
          ),
        ),
      );
      return;
    }

    // Show plant picker
    final plant = await showModalBottomSheet<PlantEntity>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.symptomLoggerSelectPlant,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return ListTile(
                      leading: plant.photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(plant.photoPath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.yard),
                      title: Text(plant.name),
                      onTap: () => Navigator.of(context).pop(plant),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (plant != null && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SymptomLoggerPage(
            plantId: plant.id,
            plantName: plant.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    String itemTitle(MoreItemEntity item) {
      switch (item.id) {
        case 'species_list':
          return context.l10n.moreSpeciesListTitle;
        case 'settings':
          return context.l10n.settingsTitle;
        case 'about':
          return context.l10n.aboutTitle;
        default:
          return item.title;
      }
    }

    String itemSubtitle(MoreItemEntity item) {
      switch (item.id) {
        case 'species_list':
          return context.l10n.moreSpeciesListSubtitle;
        case 'settings':
          return context.l10n.menuSettingsSubtitle;
        case 'about':
          return context.l10n.menuAboutSubtitle;
        default:
          return item.subtitle;
      }
    }

    return AnimatedExit(
      key: widget.pageExitAnimationKey,
      child: AnimatedEntry(
        key: widget.pageEntryAnimationKey,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    context.l10n.moreTitle,
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: _loading ? 2 : _items.length,
                          itemBuilder: (context, index) {
                            if (_loading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Container(
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            }

                            final item = _items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Material(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _open(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(itemTitle(item), style: theme.textTheme.headlineSmall),
                                              const SizedBox(height: 6),
                                              Text(itemSubtitle(item), style: theme.textTheme.bodyMedium),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ScrollToTopButton(
                        scrollController: _scrollController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
