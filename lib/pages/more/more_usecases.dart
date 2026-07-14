import 'package:open_plants/pages/more/more_item_entity.dart';
import 'package:open_plants/pages/more/more_repository.dart';

class MoreUsecases {
  final MoreRepository repository;

  const MoreUsecases({required this.repository});

  Future<List<MoreItemEntity>> getMenuItems() => repository.listItems();
}
