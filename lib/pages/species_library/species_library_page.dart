import 'dart:async';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/species_library/species_detail_page.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';

/// Browsable, searchable list of all species in the library.
class SpeciesLibraryPage extends StatefulWidget {
  const SpeciesLibraryPage({super.key});

  @override
  State<SpeciesLibraryPage> createState() => _SpeciesLibraryPageState();
}

class _SpeciesLibraryPageState extends State<SpeciesLibraryPage> {
  late SpeciesLibraryUsecases _usecases;
  bool _wired = false;
  bool _loading = true;
  List<SpeciesEntity> _allSpecies = const [];
  List<SpeciesEntity> _filteredSpecies = const [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.speciesLibrary;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final species = await _usecases.getAllSpecies();
    if (!mounted) return;
    setState(() {
      _allSpecies = species;
      _filteredSpecies = species;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() => _filteredSpecies = _allSpecies);
        return;
      }
      final results = await _usecases.searchSpecies(query);
      if (!mounted) return;
      setState(() => _filteredSpecies = results);
    });
  }

  void _openSpecies(SpeciesEntity species) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpeciesDetailPage(
          species: species,
          usecases: _usecases,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.speciesListTitle),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: context.l10n.speciesListSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Species list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSpecies.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            context.l10n.speciesListEmptyState,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredSpecies.length,
                        itemBuilder: (context, index) {
                          final species = _filteredSpecies[index];
                          return _SpeciesListItem(
                            species: species,
                            onTap: () => _openSpecies(species),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// A single species row in the list.
class _SpeciesListItem extends StatelessWidget {
  final SpeciesEntity species;
  final VoidCallback onTap;

  const _SpeciesListItem({
    required this.species,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasToxicity = species.toxicToPets || species.toxicToHumans;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.scientificName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (species.commonNames.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          species.commonNames.first,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasToxicity) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: Colors.red.shade400,
                  ),
                ],
                const SizedBox(width: 8),
                _DifficultyBadge(difficulty: species.difficulty),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small colored badge indicating difficulty level.
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
