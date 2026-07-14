import 'package:flutter_test/flutter_test.dart';

import 'package:open_plants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_repository.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_usecases.dart';

/// In-memory mock datasource for testing.
class _MockPlantJournalDataSource extends PlantJournalDataSource {
  final List<JournalEntry> _entries = [];

  @override
  Future<List<JournalEntry>> loadAll() async => List.unmodifiable(_entries);

  @override
  Future<List<JournalEntry>> loadByPlant(String plantId) async =>
      _entries.where((e) => e.plantId == plantId).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  @override
  Future<void> saveAll(List<JournalEntry> entries) async {
    _entries
      ..clear()
      ..addAll(entries);
  }

  @override
  Future<void> save(JournalEntry entry) async => _entries.add(entry);

  @override
  Future<void> update(JournalEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) throw Exception('Not found: ${entry.id}');
    _entries[index] = entry;
  }

  @override
  Future<void> delete(String id) async => _entries.removeWhere((e) => e.id == id);

  @override
  Future<String> savePhoto(dynamic sourceFile, String entryId) async => '/mock/photos/$entryId.jpg';

  @override
  Future<void> deletePhoto(String photoPath) async {}
}

void main() {
  late _MockPlantJournalDataSource datasource;
  late PlantJournalRepository repository;
  late PlantJournalUseCases usecases;

  setUp(() {
    datasource = _MockPlantJournalDataSource();
    repository = PlantJournalRepository(dataSource: datasource);
    usecases = PlantJournalUseCases(repository: repository);
  });

  group('JournalEntry', () {
    test('toJson/fromJson roundtrip preserves all fields', () {
      final entry = JournalEntry(
        id: 'test-id',
        plantId: 'plant-1',
        type: JournalEntryType.photo,
        timestamp: DateTime(2025, 3, 15, 10, 30),
        notes: 'Test notes',
        photoPath: '/path/to/photo.jpg',
      );

      final json = entry.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored.id, entry.id);
      expect(restored.plantId, entry.plantId);
      expect(restored.type, entry.type);
      expect(restored.timestamp, entry.timestamp);
      expect(restored.notes, entry.notes);
      expect(restored.photoPath, entry.photoPath);
    });

    test('copyWith overrides specified fields', () {
      final entry = JournalEntry(
        id: 'id-1',
        plantId: 'plant-1',
        type: JournalEntryType.text,
        timestamp: DateTime(2025),
        notes: 'Original',
      );

      final updated = entry.copyWith(
        notes: 'Updated',
        type: JournalEntryType.growth,
      );

      expect(updated.notes, 'Updated');
      expect(updated.type, JournalEntryType.growth);
      expect(updated.id, 'id-1');
      expect(updated.plantId, 'plant-1');
    });

    test('copyWith clearNotes sets notes to null', () {
      final entry = JournalEntry(
        id: 'id-1',
        plantId: 'plant-1',
        type: JournalEntryType.text,
        timestamp: DateTime(2025),
        notes: 'Something',
      );

      final cleared = entry.copyWith(clearNotes: true);
      expect(cleared.notes, isNull);
    });
  });

  group('JournalEntryType', () {
    test('toJson/fromJson roundtrip for all types', () {
      for (final type in JournalEntryType.values) {
        final json = type.toJson();
        final restored = JournalEntryTypeExtension.fromJson(json);
        expect(restored, type);
      }
    });

    test('fromJson returns text for unknown value', () {
      final result = JournalEntryTypeExtension.fromJson('unknown');
      expect(result, JournalEntryType.text);
    });
  });

  group('PlantJournalRepository', () {
    test('addEntry generates UUID and persists', () async {
      final entry = JournalEntry(
        id: '',
        plantId: 'plant-1',
        type: JournalEntryType.text,
        timestamp: DateTime(2025),
        notes: 'Test',
      );

      final saved = await repository.addEntry(entry);

      expect(saved.id, isNotEmpty);
      expect(saved.id.length, 36);
      expect(saved.plantId, 'plant-1');
      expect(saved.notes, 'Test');
    });

    test('getEntries returns entries for specific plant only', () async {
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'Plant 1 entry',
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-2',
          type: JournalEntryType.text,
          timestamp: DateTime(2025, 1, 2),
          notes: 'Plant 2 entry',
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.photo,
          timestamp: DateTime(2025, 1, 3),
          notes: 'Plant 1 entry 2',
        ),
      );

      final plant1Entries = await repository.getEntries('plant-1');
      final plant2Entries = await repository.getEntries('plant-2');

      expect(plant1Entries.length, 2);
      expect(plant2Entries.length, 1);
      expect(plant2Entries.first.notes, 'Plant 2 entry');
    });

    test('getEntries returns newest first', () async {
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'Old',
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025, 6),
          notes: 'New',
        ),
      );

      final entries = await repository.getEntries('plant-1');
      expect(entries.first.notes, 'New');
      expect(entries.last.notes, 'Old');
    });

    test('deleteEntry removes entry', () async {
      final saved = await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'To delete',
        ),
      );

      await repository.deleteEntry(saved.id);
      final entries = await repository.getEntries('plant-1');
      expect(entries, isEmpty);
    });

    test('deleteEntriesForPlant removes all entries for a plant', () async {
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'Entry 1',
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.photo,
          timestamp: DateTime(2025),
          notes: 'Entry 2',
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-2',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'Other plant',
        ),
      );

      await repository.deleteEntriesForPlant('plant-1');

      final plant1 = await repository.getEntries('plant-1');
      final plant2 = await repository.getEntries('plant-2');

      expect(plant1, isEmpty);
      expect(plant2.length, 1);
    });

    test('countEntries returns correct count', () async {
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
        ),
      );
      await repository.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.photo,
          timestamp: DateTime(2025),
        ),
      );

      final count = await repository.countEntries('plant-1');
      expect(count, 2);
    });
  });

  group('PlantJournalUseCases', () {
    test('addEntry delegates to repository', () async {
      final entry = JournalEntry(
        id: '',
        plantId: 'plant-1',
        type: JournalEntryType.growth,
        timestamp: DateTime(2025),
        notes: 'Growing well',
      );

      final saved = await usecases.addEntry(entry);

      expect(saved.id, isNotEmpty);
      expect(saved.type, JournalEntryType.growth);
      expect(saved.notes, 'Growing well');
    });

    test('getEntries delegates to repository', () async {
      await usecases.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'Test',
        ),
      );

      final entries = await usecases.getEntries('plant-1');
      expect(entries.length, 1);
    });

    test('deleteEntry removes entry', () async {
      final saved = await usecases.addEntry(
        JournalEntry(
          id: '',
          plantId: 'plant-1',
          type: JournalEntryType.text,
          timestamp: DateTime(2025),
          notes: 'To delete',
        ),
      );

      await usecases.deleteEntry(saved.id);
      final entries = await usecases.getEntries('plant-1');
      expect(entries, isEmpty);
    });
  });
}
