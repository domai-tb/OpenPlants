import 'package:openplants/pages/more/more_item_entity.dart';

class MoreDataSource {
  Future<List<MoreItemEntity>> fetchItems() => Future.value(const [
        MoreItemEntity(id: 'species_list'),
        MoreItemEntity(id: 'rooms'),
        MoreItemEntity(id: 'light_assessment'),
        MoreItemEntity(id: 'log_symptom'),
        MoreItemEntity(id: 'diagnosis'),
        MoreItemEntity(id: 'notifications'),
        MoreItemEntity(id: 'settings'),
        MoreItemEntity(id: 'about'),
      ]);
}
