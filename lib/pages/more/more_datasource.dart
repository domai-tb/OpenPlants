import 'package:open_plant/pages/more/more_item_entity.dart';

class MoreDataSource {
  Future<List<MoreItemEntity>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      MoreItemEntity(id: 'species_list', title: 'Species List', subtitle: 'Browse all plant species'),
      MoreItemEntity(id: 'rooms', title: 'Rooms', subtitle: 'Manage room locations'),
      MoreItemEntity(id: 'light_assessment', title: 'Light Assessment', subtitle: 'Assess light levels for your plants'),
      MoreItemEntity(id: 'log_symptom', title: 'Log Symptom', subtitle: 'Record a plant health issue'),
      MoreItemEntity(id: 'diagnosis', title: 'Plant Diagnosis', subtitle: 'Diagnose plant problems'),
      MoreItemEntity(id: 'settings', title: 'Settings', subtitle: 'OpenPlant settings'),
      MoreItemEntity(id: 'about', title: 'About', subtitle: 'About OpenPlant'),
    ];
  }
}
