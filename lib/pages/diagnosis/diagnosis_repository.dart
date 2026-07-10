import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_usecases.dart';

/// Repository for the diagnosis feature.
///
/// Delegates rule evaluation to the usecases layer (DiagnosisEngine).
class DiagnosisRepository {
  final DiagnosisEngine _engine;

  const DiagnosisRepository({
    required DiagnosisEngine engine,
  }) : _engine = engine;

  /// Evaluates the given [context] and returns ranked causes.
  DiagnosisResult evaluate(DiagnosisContext context) {
    return _engine.evaluate(context);
  }
}
