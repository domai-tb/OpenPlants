import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';
import 'package:open_plant/pages/species_library/species_detail_page.dart';

/// List page showing all species with search and filter capabilities.
class SpeciesLibraryPage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  const SpeciesLibraryPage({
    super.key,
    required this.mainNavigatorKey,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
  });

  @override
  State<SpeciesLibraryPage> createState() => _SpeciesLibraryPageState();
}

class _SpeciesLibraryPageState extends State<SpeciesLibraryPage> {
  late SpeciesLibraryUsecases _usecases;
  bool _wired = false;

  List<SpeciesEntity> _allSpecies = [];
  List<SpeciesEntity> _filteredSpecies = [];
  bool _loading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  final Set<Difficulty> _selectedDifficulties = {};
  bool _toxicOnly = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.speciesLibrary;
    _loadSpecies();
    _wired = true;
  }

  Future<void> _loadSpecies() async {
    try {
      final species = await _usecases.getAllSpecies();
      if (!mounted) return;
      setState(() {
        _allSpecies = species;
        _filteredSpecies = species;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  void _onDifficultyToggle(Difficulty difficulty) {
    setState(() {
      if (_selectedDifficulties.contains(difficulty)) {
        _selectedDifficulties.remove(difficulty);
      } else {
        _selectedDifficulties.add(difficulty);
      }
    });
    _applyFilters();
  }

  void _onToxicOnlyToggle(bool? value) {
    setState(() {
      _toxicOnly = value ?? false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text;
    var results = _allSpecies;

    // Text search
    if (query.trim().isNotEmpty) {
      final trimmed = query.trim().toLowerCase();
      results = results.where((s) {
        if (s.scientificName.toLowerCase().contains(trimmed)) return true;
        if (s.commonNames.any((n) => n.toLowerCase().contains(trimmed))) {
          return true;
        }
        if (s.description.toLowerCase().contains(trimmed)) return true;
        return false;
      }).toList();
    }

    // Difficulty filter
    if (_selectedDifficulties.isNotEmpty) {
      results = results.where((s) => _selectedDifficulties.contains(s.difficulty)).toList();
    }

    // Toxicity filter
    if (_toxicOnly) {
      results = results.where((s) => s.toxicToHumans || s.toxicToPets).toList();
    }

    setState(() {
      _filteredSpecies = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedExit(
      key: widget.pageExitAnimationKey,
      child: AnimatedEntry(
        key: widget.pageEntryAnimationKey,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Text(
                    context.l10n.speciesLibraryTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                ),
                const SizedBox(height: 10),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: context.l10n.speciesLibrarySearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Difficulty chips
                      ...Difficulty.values.map(
                        (difficulty) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_difficultyLabel(difficulty)),
                            selected: _selectedDifficulties.contains(difficulty),
                            onSelected: (_) => _onDifficultyToggle(difficulty),
                          ),
                        ),
                      ),
                      // Toxic toggle
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(context.l10n.speciesLibraryToxicOnly),
                        selected: _toxicOnly,
                        onSelected: _onToxicOnlyToggle,
                        avatar: Icon(
                          _toxicOnly ? Icons.warning : Icons.warning_amber_outlined,
                          size: 18,
                          color: _toxicOnly ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Species list
                Expanded(
                  child: _buildContent(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.generalFailureMessage,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _loadSpecies();
                },
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.plantIdTryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredSpecies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.speciesLibraryEmpty,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredSpecies.length,
      itemBuilder: (context, index) {
        final species = _filteredSpecies[index];
        return _SpeciesListTile(
          species: species,
          onTap: () => _openDetail(species),
        );
      },
    );
  }

  void _openDetail(SpeciesEntity species) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpeciesDetailPage(
          species: species,
          usecases: _usecases,
        ),
      ),
    );
  }

  String _difficultyLabel(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => context.l10n.speciesLibraryEasy,
      Difficulty.moderate => context.l10n.speciesLibraryModerate,
      Difficulty.challenging => context.l10n.speciesLibraryChallenging,
    };
  }
}

class _SpeciesListTile extends StatelessWidget {
  final SpeciesEntity species;
  final VoidCallback onTap;

  const _SpeciesListTile({
    required this.species,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      species.commonNames.isNotEmpty ? species.commonNames.first : species.scientificName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species.scientificName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _DifficultyBadge(difficulty: species.difficulty),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (Color bgColor, Color textColor, String label) = switch (difficulty) {
      Difficulty.easy => (
          Colors.green.shade100,
          Colors.green.shade800,
          context.l10n.speciesLibraryEasy,
        ),
      Difficulty.moderate => (
          Colors.orange.shade100,
          Colors.orange.shade800,
          context.l10n.speciesLibraryModerate,
        ),
      Difficulty.challenging => (
          Colors.red.shade100,
          Colors.red.shade800,
          context.l10n.speciesLibraryChallenging,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
