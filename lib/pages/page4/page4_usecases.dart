import 'package:open_plant/pages/page4/page4_item_entity.dart';
import 'package:open_plant/pages/page4/page4_repository.dart';

class Page4Usecases {
  final Page4Repository repository;

  const Page4Usecases({required this.repository});

  Future<List<Page4ItemEntity>> getItems() => repository.listItems();
}
