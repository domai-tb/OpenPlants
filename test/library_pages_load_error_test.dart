import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/app_services.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_form_page.dart';
import 'package:openplants/pages/room_profiles/room_profiles_page.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';
import 'package:openplants/pages/species_library/species_library_item_entity.dart';
import 'package:openplants/pages/species_library/species_library_page.dart';
import 'package:openplants/pages/species_library/species_library_usecases.dart';

void main() {
  testWidgets('room profiles shows a retry action after a load failure', (tester) async {
    final roomUsecases = _RetryRoomUsecases();

    await _withoutDebugOutput(() async {
      await tester.pumpWidget(
        _buildApp(
          services: _TestServices(
            roomProfiles: roomUsecases,
            plantCollection: _EmptyPlantUsecases(),
            speciesLibrary: _RetrySpeciesUsecases(),
          ),
          child: const RoomProfilesPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('An error has occurred.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(roomUsecases.calls, 2);
      expect(find.text('No rooms yet'), findsOneWidget);
    });
  });

  testWidgets('species library shows a retry action after a load failure', (tester) async {
    final speciesUsecases = _RetrySpeciesUsecases();

    await _withoutDebugOutput(() async {
      await tester.pumpWidget(
        _buildApp(
          services: _TestServices(
            roomProfiles: _RetryRoomUsecases(),
            plantCollection: _EmptyPlantUsecases(),
            speciesLibrary: speciesUsecases,
          ),
          child: const SpeciesLibraryPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('An error has occurred.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(speciesUsecases.calls, 2);
      expect(find.text('Example plant'), findsOneWidget);
    });
  });

  testWidgets('room form uses the active locale for shared labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppScope(
          settings: _TestSettingsController(),
          services: _TestServices(
            roomProfiles: _RetryRoomUsecases(),
            plantCollection: _EmptyPlantUsecases(),
            speciesLibrary: _RetrySpeciesUsecases(),
          ),
          child: const RoomProfilesFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Speichern'), findsOneWidget);
    expect(find.text('Licht'), findsOneWidget);
    expect(find.text('Luftfeuchtigkeit'), findsOneWidget);
    expect(find.text('Notizen'), findsOneWidget);
  });

  testWidgets('room page uses the active locale for its title and environment labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppScope(
          settings: _TestSettingsController(),
          services: _TestServices(
            roomProfiles: _StaticRoomUsecases(),
            plantCollection: _EmptyPlantUsecases(),
            speciesLibrary: _RetrySpeciesUsecases(),
          ),
          child: const RoomProfilesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Räume'), findsOneWidget);
    expect(find.text('Hell indirekt'), findsOneWidget);
    expect(find.text('Hoch'), findsOneWidget);
  });
}

Future<void> _withoutDebugOutput(Future<void> Function() action) async {
  final originalDebugPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {};
  try {
    await action();
  } finally {
    debugPrint = originalDebugPrint;
  }
}

Widget _buildApp({required AppServices services, required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AppScope(
      settings: _TestSettingsController(),
      services: services,
      child: child,
    ),
  );
}

class _TestServices implements AppServices {
  @override
  final RoomProfilesUsecases roomProfiles;

  @override
  final PlantCollectionUsecases plantCollection;

  @override
  final SpeciesLibraryUsecases speciesLibrary;

  const _TestServices({
    required this.roomProfiles,
    required this.plantCollection,
    required this.speciesLibrary,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestSettingsController extends ChangeNotifier implements SettingsController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RetryRoomUsecases implements RoomProfilesUsecases {
  int calls = 0;

  @override
  Future<List<RoomEntity>> getAll() async {
    if (calls++ == 0) throw StateError('Temporary room read failure');
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StaticRoomUsecases implements RoomProfilesUsecases {
  @override
  Future<List<RoomEntity>> getAll() async => [
        RoomEntity(
          id: 'room-1',
          name: 'Living room',
          lightLevel: RoomLightLevel.bright,
          humidityLevel: RoomHumidityLevel.high,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyPlantUsecases implements PlantCollectionUsecases {
  @override
  Future<List<PlantEntity>> loadPlants() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RetrySpeciesUsecases implements SpeciesLibraryUsecases {
  int calls = 0;

  @override
  Future<List<SpeciesEntity>> getAllSpecies() async {
    if (calls++ == 0) throw StateError('Temporary species read failure');
    return const [_exampleSpecies];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _exampleSpecies = SpeciesEntity(
  scientificName: 'Example plant',
  commonNames: ['Example'],
  difficulty: Difficulty.easy,
  lightNeeds: LightNeeds.medium,
  waterNeeds: WaterNeeds.moderate,
  humidityPreference: HumidityPreference.moderate,
  soilType: 'Potting mix',
  repottingIntervalMonths: 12,
  toxicToHumans: false,
  toxicToPets: false,
  description: 'Example description',
  careSummary: 'Example care',
);
