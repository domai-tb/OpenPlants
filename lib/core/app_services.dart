import 'package:open_plant/pages/page1/page1_usecases.dart';
import 'package:open_plant/pages/page2/page2_usecases.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/page4/page4_usecases.dart';
import 'package:open_plant/pages/page5/page5_usecases.dart';
import 'package:open_plant/pages/page6/page6_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';

/// Aggregates feature use-cases for convenient access via `AppScope`.
///
/// Wiring happens in `lib/core/injection.dart` (GetIt), so pages can stay free of
/// plugin imports.
class AppServices {
  final Page1Usecases page1;
  final Page2Usecases page2;
  final PlantClassifierUsecases plantIdentification;
  final Page4Usecases page4;
  final Page5Usecases page5;
  final Page6Usecases page6;
  final PlantCollectionUsecases plantCollection;
  final SpeciesLibraryUsecases speciesLibrary;

  const AppServices({
    required this.page1,
    required this.page2,
    required this.plantIdentification,
    required this.page4,
    required this.page5,
    required this.page6,
    required this.plantCollection,
    required this.speciesLibrary,
  });
}
