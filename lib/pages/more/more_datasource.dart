import 'package:open_plant/pages/more/more_item_entity.dart';

class MoreDataSource {
  Future<List<MoreItemEntity>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      MoreItemEntity(id: 'settings', title: 'Settings', subtitle: 'OpenPlant settings'),
      MoreItemEntity(id: 'about', title: 'About', subtitle: 'About OpenPlant'),
    ];
  }
}
