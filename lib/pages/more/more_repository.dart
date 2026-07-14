import 'package:open_plants/pages/more/more_datasource.dart';
import 'package:open_plants/pages/more/more_item_entity.dart';

class MoreRepository {
  final MoreDataSource dataSource;

  const MoreRepository({required this.dataSource});

  Future<List<MoreItemEntity>> listItems() => dataSource.fetchItems();
}
