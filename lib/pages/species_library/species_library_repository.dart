import 'package:open_plant/pages/species_library/species_library_datasource.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';

/// Repository wrapping the species data source with search and filter methods.
class SpeciesLibraryRepository {
  final SpeciesLibraryDatasource _datasource;

  const SpeciesLibraryRepository({required SpeciesLibraryDatasource datasource}) : _datasource = datasource;

  /// Returns all species.
  Future<List<SpeciesEntity>> listAll() => _datasource.loadAll();

  /// Searches species by [query] across common names, scientific name,
  /// and description. Case-insensitive substring matching.
  Future<List<SpeciesEntity>> search(String query) async {
    final all = await _datasource.loadAll();
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return all;

    return all.where((s) {
      if (s.scientificName.toLowerCase().contains(trimmed)) return true;
      if (s.commonNames.any((n) => n.toLowerCase().contains(trimmed))) {
        return true;
      }
      if (s.description.toLowerCase().contains(trimmed)) return true;
      return false;
    }).toList(growable: false);
  }

  /// Looks up a species by scientific name.
  ///
  /// First attempts a case-insensitive exact match. If not found, attempts
  /// fuzzy matching with Levenshtein distance ≤ 2.
  Future<SpeciesEntity?> findByScientificName(String name) async {
    final all = await _datasource.loadAll();
    final normalized = name.trim().toLowerCase();

    // Exact case-insensitive match
    for (final s in all) {
      if (s.scientificName.toLowerCase() == normalized) return s;
    }

    // Fuzzy match with Levenshtein distance ≤ 2
    SpeciesEntity? bestMatch;
    int bestDistance = 2;
    for (final s in all) {
      final distance = _levenshteinDistance(s.scientificName.toLowerCase(), normalized);
      if (distance <= bestDistance) {
        bestDistance = distance;
        bestMatch = s;
      }
    }

    return bestMatch;
  }

  /// Filters species by optional criteria.
  Future<List<SpeciesEntity>> filter({
    Difficulty? difficulty,
    bool? toxicOnly,
  }) async {
    final all = await _datasource.loadAll();

    return all.where((s) {
      if (difficulty != null && s.difficulty != difficulty) return false;
      if (toxicOnly == true && !s.toxicToHumans && !s.toxicToPets) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  /// Levenshtein distance between two strings.
  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    final aLen = a.length;
    final bLen = b.length;
    if (aLen == 0) return bLen;
    if (bLen == 0) return aLen;

    // Use two rows for O(min(aLen, bLen)) memory.
    final prev = List<int>.generate(bLen + 1, (i) => i);
    final curr = List<int>.filled(bLen + 1, 0);

    for (var i = 1; i <= aLen; i++) {
      curr[0] = i;
      for (var j = 1; j <= bLen; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1, // insertion
          prev[j] + 1, // deletion
          prev[j - 1] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
      // Swap rows
      for (var k = 0; k <= bLen; k++) {
        prev[k] = curr[k];
      }
    }

    return curr[bLen];
  }
}
