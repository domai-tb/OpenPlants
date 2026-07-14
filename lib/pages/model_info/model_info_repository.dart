import 'package:open_plants/pages/model_info/model_info_datasource.dart';
import 'package:open_plants/pages/model_info/model_info_item_entity.dart';

/// Repository mapping raw JSON from the datasource to [ModelInfoItem] entities.
class ModelInfoRepository {
  final ModelInfoDatasource _datasource;

  const ModelInfoRepository({required ModelInfoDatasource datasource}) : _datasource = datasource;

  /// Returns the model metadata as a [ModelInfoItem].
  Future<ModelInfoItem> getModelInfo() async {
    final json = await _datasource.loadModelMeta();
    return ModelInfoItem.fromJson(json);
  }
}
