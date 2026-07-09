import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Data source for plant growth photo file I/O.
///
/// Photo files are stored in the app's documents directory under
/// `plant_photos/{plantId}/{photoId}.jpg`. Metadata is stored within
/// the plant entity via PlantCollectionDataSource.
class PlantPhotoTimelineDataSource {
  static const String _photoSubdir = 'plant_photos';
  final Uuid _uuid;

  PlantPhotoTimelineDataSource() : _uuid = const Uuid();

  /// Save a photo file to disk, compressing to JPEG.
  ///
  /// Returns the absolute path to the saved file.
  Future<String> savePhotoFile(File image, String plantId) async {
    final dir = await getApplicationDocumentsDirectory();
    final plantPhotoDir = Directory('${dir.path}/$_photoSubdir/$plantId');

    if (!plantPhotoDir.existsSync()) {
      await plantPhotoDir.create(recursive: true);
    }

    final photoId = _uuid.v4();
    final targetPath = '${plantPhotoDir.path}/$photoId.jpg';

    // Compress the image to JPEG at 80% quality
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // Fallback: copy original file if decoding fails
      await image.copy(targetPath);
      return targetPath;
    }

    final compressed = img.encodeJpg(decoded, quality: 80);
    await File(targetPath).writeAsBytes(compressed);
    return targetPath;
  }

  /// Delete a photo file from disk.
  Future<void> deletePhotoFile(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Delete all photo files for a plant.
  Future<void> deleteAllPhotoFiles(String plantId) async {
    final dir = await getApplicationDocumentsDirectory();
    final plantPhotoDir = Directory('${dir.path}/$_photoSubdir/$plantId');
    if (plantPhotoDir.existsSync()) {
      await plantPhotoDir.delete(recursive: true);
    }
  }

  /// Check if a photo file exists on disk.
  bool photoFileExists(String filePath) {
    return File(filePath).existsSync();
  }
}
