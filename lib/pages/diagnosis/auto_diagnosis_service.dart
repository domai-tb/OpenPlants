import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Orchestrates automatic diagnosis when a symptom is logged.
///
/// Builds a [DiagnosisContext] from a [SymptomLogEntry], runs it through the
/// [DiagnosisEngine], and persists the result via [DiagnosisRepository].
class AutoDiagnosisService {
  final DiagnosisRepository _repository;
  final DiagnosisEngine _engine;
  final PlantCollectionUsecases? _plantCollection;
  final RoomProfilesUsecases? _roomProfiles;

  const AutoDiagnosisService({
    required DiagnosisRepository repository,
    required DiagnosisEngine engine,
    PlantCollectionUsecases? plantCollection,
    RoomProfilesUsecases? roomProfiles,
  })  : _repository = repository,
        _engine = engine,
        _plantCollection = plantCollection,
        _roomProfiles = roomProfiles;

  /// Runs diagnosis for [entry] and saves the result if there are ranked causes.
  ///
  /// Returns the saved entity's ID, or `null` when the engine produced no results.
  Future<String?> diagnoseAndSave(SymptomLogEntry entry) async {
    final context = await _buildContext(entry);
    final result = _engine.evaluate(context);

    if (!result.hasResults) return null;

    final entity = DiagnosisResultEntity(
      id: '',
      plantId: entry.plantId,
      symptomLogEntryId: entry.id,
      plantSymptoms: entry.symptomTypes,
      causes: result.causes,
      type: result.type,
      context: context,
      createdAt: DateTime.now(),
    );

    final saved = await _repository.saveResult(entity);
    return saved.id;
  }

  /// Returns the most recent diagnosis for [plantId], or `null` if none exists.
  Future<DiagnosisResultEntity?> getLatestDiagnosis(String plantId) async {
    final results = await _repository.getResultsByPlant(plantId);
    return results.isNotEmpty ? results.first : null;
  }

  /// Maps a [SymptomLogEntry] and its plant's room profile to engine input.
  Future<DiagnosisContext> _buildContext(SymptomLogEntry entry) async {
    RoomEntity? room;
    final plant = await _plantCollection?.getPlantById(entry.plantId);
    if (plant?.roomId != null) {
      room = await _roomProfiles?.getById(plant!.roomId!);
    }

    return DiagnosisContext.fromSymptomLogEntry(entry, room: room);
  }
}
