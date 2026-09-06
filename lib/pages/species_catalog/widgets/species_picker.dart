import 'package:flutter/material.dart';
import 'package:open_plants/l10n/l10n.dart';
import 'package:open_plants/pages/species_catalog/species_catalog_entity.dart';
import 'package:open_plants/pages/species_catalog/species_catalog_usecases.dart';

/// Searchable species picker using the catalog.
///
/// Returns the selected species catalog entry via [onSelected].
class SpeciesPicker extends StatefulWidget {
  final SpeciesCatalogUsecases usecases;
  final ValueChanged<SpeciesCatalogEntry> onSelected;
  final String? initialQuery;
  final String locale;

  const SpeciesPicker({
    super.key,
    required this.usecases,
    required this.onSelected,
    this.initialQuery,
    this.locale = 'en',
  });

  @override
  State<SpeciesPicker> createState() => _SpeciesPickerState();
}

class _SpeciesPickerState extends State<SpeciesPicker> {
  final _controller = TextEditingController();
  List<SpeciesCatalogEntry> _results = [];
  bool _loading = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _controller.text = widget.initialQuery!;
    }
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final results = await widget.usecases.listAll();
    if (mounted) {
      setState(() {
        _results = results.take(20).toList();
        _loading = false;
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      await _loadInitial();
      return;
    }

    setState(() => _searching = true);
    final results = await widget.usecases.search(query, locale: widget.locale);
    if (mounted) {
      setState(() {
        _results = results;
        _searching = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.speciesPickerTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.speciesPickerSearch,
                hintText: l10n.speciesPickerSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _searching
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? _buildEmptyState(l10n)
                        : _buildResultsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.speciesPickerEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme) {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final entry = _results[index];
        return ListTile(
          title: Text(entry.scientificName),
          subtitle: Text(entry.aliases.isNotEmpty ? entry.aliases.first : ''),
          onTap: () => widget.onSelected(entry),
        );
      },
    );
  }
}
