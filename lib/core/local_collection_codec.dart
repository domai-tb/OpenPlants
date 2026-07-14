import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';

// ---------------------------------------------------------------------------
// Result types
// ---------------------------------------------------------------------------

/// The result of decoding a SharedPreferences-backed collection.
///
/// Is either a successful decoded list or a classified persistence failure.
class DecodedCollection<T> {
  final List<T>? _items;
  final CollectionPersistenceFailure? _failure;

  DecodedCollection._success(this._items) : _failure = null;

  DecodedCollection._failure(this._failure) : _items = null;

  /// Whether the collection was decoded successfully.
  bool get isSuccess => _items != null;

  /// Whether the collection failed to decode.
  bool get isFailure => _failure != null;

  /// Returns the decoded items on success, or throws if this is a failure.
  List<T> get asSuccess {
    if (_items == null) {
      throw StateError('DecodedCollection is a failure, not a success.');
    }
    return _items!;
  }

  /// Returns the failure on error, or null if this is a success.
  CollectionPersistenceFailure? get asFailure => _failure;
}

// ---------------------------------------------------------------------------
// Migration support
// ---------------------------------------------------------------------------

/// Signature for a function that migrates a single raw JSON record from an
/// older schema version to the current schema.
typedef RecordMigrator = Map<String, dynamic>? Function(
  Map<String, dynamic> raw,
);

// ---------------------------------------------------------------------------
// Codec
// ---------------------------------------------------------------------------

/// A reusable, typed decoder for SharedPreferences-backed JSON collections.
///
/// Distinguishes missing keys (valid empty state) from corruption, validates
/// each record, and never returns partial writable state. Raw SharedPreferences
/// content is preserved on failure, and mutations are blocked after a failed
/// load to prevent silent data loss.
class LocalCollectionCodec<T> {
  final SharedPreferences _prefs;
  final String _key;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  final RecordMigrator? _migrator;
  final dynamic Function(T)? _keyExtractor;

  /// Whether the most recent [load] call returned a failure.
  bool _blocked = false;

  LocalCollectionCodec({
    required SharedPreferences prefs,
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    RecordMigrator? migrator,
    dynamic Function(T)? keyExtractor,
  })  : _prefs = prefs,
        _key = key,
        _fromJson = fromJson,
        _toJson = toJson,
        _migrator = migrator,
        _keyExtractor = keyExtractor;

  /// Whether mutations are currently blocked due to a prior decode failure.
  bool get isBlocked => _blocked;

  /// Loads and decodes the collection from SharedPreferences.
  ///
  /// Returns [DecodedCollection] indicating success, absence, or a classified
  /// failure. On failure the raw SharedPreferences value is left untouched.
  Future<DecodedCollection<T>> load() async {
    final raw = _prefs.getString(_key);

    // Missing key → valid empty collection.
    if (raw == null || raw.trim().isEmpty) {
      _blocked = false;
      return DecodedCollection._success([]);
    }

    // Attempt to decode the JSON.
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      _blocked = true;
      return DecodedCollection._failure(
        CollectionDecodeFailure(collection: _key),
      );
    }

    // Validate top-level shape (must be a List).
    if (decoded is! List<dynamic>) {
      _blocked = true;
      return DecodedCollection._failure(
        CollectionShapeFailure(collection: _key),
      );
    }

    // Decode each record.
    final items = <T>[];
    for (var i = 0; i < decoded.length; i++) {
      final rawRecord = decoded[i];

      // Must be a JSON map.
      if (rawRecord is! Map<String, dynamic>) {
        _blocked = true;
        return DecodedCollection._failure(
          RecordDecodeFailure(collection: _key, failingIndex: i),
        );
      }

      // Attempt migration if supported.
      Map<String, dynamic> record = rawRecord;
      if (_migrator != null) {
        final migrated = _migrator!(record);
        if (migrated != null) {
          record = migrated;
        }
      }

      // Attempt to decode the record into the target type.
      try {
        items.add(_fromJson(record));
      } catch (_) {
        _blocked = true;
        return DecodedCollection._failure(
          RecordDecodeFailure(collection: _key, failingIndex: i),
        );
      }
    }

    _blocked = false;
    return DecodedCollection._success(items);
  }

  /// Replaces the entire collection.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the most recent [load] returned a
  /// failure.
  Future<void> save(List<T> items) {
    _assertNotBlocked();
    final json = items.map((e) => _toJson(e)).toList();
    return _prefs.setString(_key, jsonEncode(json));
  }

  /// Appends an item to the collection.
  ///
  /// Loads the current collection, adds the item, and saves. Throws
  /// [BlockedAfterDecodeFailure] if the most recent [load] returned a failure.
  Future<void> add(T item) async {
    _assertNotBlocked();
    final items = await _loadForMutation();
    items.add(item);
    await save(items);
  }

  /// Replaces the item that matches the same identity (by key) in the
  /// collection.
  ///
  /// If [matchKey] is provided, it is used to identify items. Otherwise the
  /// [keyExtractor] passed to the constructor is used. Throws
  /// [BlockedAfterDecodeFailure] if the most recent [load] returned a failure.
  Future<void> update(
    T item, {
    dynamic Function(T)? matchKey,
  }) async {
    _assertNotBlocked();
    final extractor = matchKey ?? _keyExtractor;
    if (extractor == null) {
      throw StateError(
        'update requires a matchKey or a keyExtractor at construction.',
      );
    }
    final items = await _loadForMutation();
    final targetKey = extractor(item);
    final index = items.indexWhere((e) => extractor(e) == targetKey);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await save(items);
  }

  /// Removes the item matching [value] from the collection.
  ///
  /// If [matchKey] is provided, it is used to identify items. Otherwise the
  /// [keyExtractor] passed to the constructor is used. Throws
  /// [BlockedAfterDecodeFailure] if the most recent [load] returned a failure.
  Future<void> delete(
    dynamic value, {
    dynamic Function(T)? matchKey,
  }) async {
    _assertNotBlocked();
    final extractor = matchKey ?? _keyExtractor;
    if (extractor == null) {
      throw StateError(
        'delete requires a matchKey or a keyExtractor at construction.',
      );
    }
    final items = await _loadForMutation();
    items.removeWhere((e) => extractor(e) == value);
    await save(items);
  }

  /// Loads the collection for a mutation operation.
  ///
  /// Returns the decoded list on success. Throws [BlockedAfterDecodeFailure]
  /// if the load failed (corruption detected).
  Future<List<T>> _loadForMutation() async {
    final result = await load();
    if (result.isFailure) {
      throw BlockedAfterDecodeFailure(collection: _key);
    }
    return result.asSuccess;
  }

  void _assertNotBlocked() {
    if (_blocked) {
      throw BlockedAfterDecodeFailure(collection: _key);
    }
  }
}
