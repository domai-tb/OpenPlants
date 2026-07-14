/// response status code is not 200
class ServerException implements Exception {}

// failed to parse
class ParseException implements Exception {}

/// expected response is not existing
class EmptyResponseException implements Exception {}

/// Generic authentication error (e.g. invalid credentials / expired session).
class AuthenticationException implements Exception {}

/// object is not valid JSON
class JsonException implements Exception {}

/// some unexpected error occured
class UnexpectedException implements Exception {}

/// No connection to a remote dependency.
class NoConnectionException implements Exception {}

/// Too many requests to a remote dependency.
class RateLimitException implements Exception {}

/// A referenced custom care rule does not exist.
class RuleNotFoundException implements Exception {}

// ---------------------------------------------------------------------------
// Local persistence failures
// ---------------------------------------------------------------------------

/// Base class for classified local persistence decode failures.
abstract class CollectionPersistenceFailure implements Exception {
  /// The SharedPreferences key that failed to decode.
  String get collection;
}

/// The stored JSON is malformed and cannot be decoded.
class CollectionDecodeFailure extends CollectionPersistenceFailure {
  @override
  final String collection;

  CollectionDecodeFailure({required this.collection});
}

/// The stored JSON decoded but has an unexpected top-level shape
/// (e.g., a map when a list was expected).
class CollectionShapeFailure extends CollectionPersistenceFailure {
  @override
  final String collection;

  CollectionShapeFailure({required this.collection});
}

/// One record in the collection failed to decode.
class RecordDecodeFailure extends CollectionPersistenceFailure {
  @override
  final String collection;

  /// The zero-based index of the record that failed.
  final int failingIndex;

  RecordDecodeFailure({required this.collection, required this.failingIndex});
}

/// An attempted mutation (save/add/update/delete) was blocked because the
/// preceding LocalCollectionCodec.load returned a decode failure.
class BlockedAfterDecodeFailure implements Exception {
  /// The SharedPreferences key whose collection is in a failed state.
  final String collection;

  BlockedAfterDecodeFailure({required this.collection});
}

// ---------------------------------------------------------------------------
// Photo persistence failures
// ---------------------------------------------------------------------------

/// Base class for classified photo operation failures.
abstract class PhotoPersistenceFailure implements Exception {
  /// The plant ID associated with the failure.
  String get plantId;
}

/// The plant entity could not be persisted after staging a new photo.
///
/// The staged replacement has been cleaned up and the old photo is retained.
class PhotoSaveFailure extends PhotoPersistenceFailure {
  @override
  final String plantId;

  /// The underlying error that caused the persistence failure.
  final Object underlyingError;

  PhotoSaveFailure({required this.plantId, required this.underlyingError});
}

/// The plant entity could not be persisted when clearing a photo.
///
/// The old photo is retained.
class PhotoClearFailure extends PhotoPersistenceFailure {
  @override
  final String plantId;

  /// The underlying error that caused the persistence failure.
  final Object underlyingError;

  PhotoClearFailure({required this.plantId, required this.underlyingError});
}
