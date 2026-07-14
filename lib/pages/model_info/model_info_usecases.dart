import 'package:open_plants/pages/model_info/model_info_item_entity.dart';
import 'package:open_plants/pages/model_info/model_info_repository.dart';

/// Business logic for the model info feature.
class ModelInfoUseCase {
  final ModelInfoRepository _repository;

  const ModelInfoUseCase({required ModelInfoRepository repository}) : _repository = repository;

  /// Returns the model metadata.
  Future<ModelInfoItem> getModelInfo() => _repository.getModelInfo();
}
