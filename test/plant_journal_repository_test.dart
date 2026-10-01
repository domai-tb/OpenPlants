import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:openplants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:openplants/pages/plant_journal/plant_journal_repository.dart';

void main() {
  late _RecordingJournalDataSource dataSource;
  late PlantJournalRepository repository;

  setUp(() {
    dataSource = _RecordingJournalDataSource();
    repository = PlantJournalRepository(dataSource: dataSource);
  });

  test('stages an added photo and removes it when metadata save fails', () async {
    dataSource.failWrites = true;

    await expectLater(
      () => repository.addEntry(_entry(), photoFile: File('/tmp/source.jpg')),
      throwsA(isA<StateError>()),
    );

    expect(dataSource.events, ['stage', 'add', 'delete:/new/photo.jpg']);
  });

  test('updates metadata before deleting the old photo', () async {
    final existing = _entry(photoPath: '/old/photo.jpg');
    dataSource.entries = [existing];

    await repository.updateEntry(existing, photoFile: File('/tmp/source.jpg'));

    expect(dataSource.events, ['stage', 'update', 'delete:/old/photo.jpg']);
  });

  test('returns updated entry when old photo cleanup fails after save', () async {
    final existing = _entry(photoPath: '/old/photo.jpg');
    dataSource.entries = [existing];
    dataSource.failPhotoDeletes = true;

    final updated = await repository.updateEntry(existing, photoFile: File('/tmp/source.jpg'));

    expect(updated.photoPath, '/new/photo.jpg');
    expect(dataSource.entries.single.photoPath, '/new/photo.jpg');
    expect(dataSource.events, ['stage', 'update', 'delete:/old/photo.jpg']);
  });

  test('keeps the old photo and cleans the staged photo when update fails', () async {
    final existing = _entry(photoPath: '/old/photo.jpg');
    dataSource.entries = [existing];
    dataSource.failWrites = true;

    await expectLater(
      () => repository.updateEntry(existing, photoFile: File('/tmp/source.jpg')),
      throwsA(isA<StateError>()),
    );

    expect(dataSource.events, ['stage', 'update', 'delete:/new/photo.jpg']);
  });

  test('deletes journal metadata before deleting its photo', () async {
    final existing = _entry(photoPath: '/old/photo.jpg');
    dataSource.entries = [existing];
    dataSource.failPhotoDeletes = true;

    await repository.deleteEntry(existing.id);

    expect(dataSource.events, ['delete-entry', 'delete:/old/photo.jpg']);
  });

  test('retains entries when photo cleanup fails so a retry can resume', () async {
    dataSource.entries = [
      _entry().copyWith(id: 'entry-1', photoPath: '/first.jpg'),
      _entry().copyWith(id: 'entry-2', photoPath: '/second.jpg'),
    ];
    dataSource.failPhotoDeletes = true;

    await expectLater(
      () => repository.deleteEntriesForPlant('plant-1'),
      throwsA(isA<StateError>()),
    );

    expect(dataSource.entries, hasLength(2));
    expect(dataSource.events, ['delete:/first.jpg']);
  });
}

JournalEntry _entry({String? photoPath}) => JournalEntry(
      id: 'entry-1',
      plantId: 'plant-1',
      type: JournalEntryType.photo,
      timestamp: DateTime(2026),
      photoPath: photoPath,
    );

class _RecordingJournalDataSource extends PlantJournalDataSource {
  final List<String> events = [];
  List<JournalEntry> entries = [];
  bool failWrites = false;
  bool failPhotoDeletes = false;

  @override
  Future<List<JournalEntry>> loadAll() async => entries;

  @override
  Future<void> save(JournalEntry entry) async {
    events.add('add');
    if (failWrites) throw StateError('Persistence failed');
    entries = [...entries, entry];
  }

  @override
  Future<void> update(JournalEntry entry) async {
    events.add('update');
    if (failWrites) throw StateError('Persistence failed');
    entries = [...entries.where((item) => item.id != entry.id), entry];
  }

  @override
  Future<void> delete(String id) async {
    events.add('delete-entry');
    entries = entries.where((item) => item.id != id).toList();
  }

  @override
  Future<void> saveAll(List<JournalEntry> updatedEntries) async {
    events.add('save-all');
    if (failWrites) throw StateError('Persistence failed');
    entries = updatedEntries;
  }

  @override
  Future<String> savePhoto(File sourceFile, String entryId) async {
    events.add('stage');
    return '/new/photo.jpg';
  }

  @override
  Future<void> deletePhoto(String photoPath) async {
    events.add('delete:$photoPath');
    if (failPhotoDeletes) throw StateError('Photo cleanup failed');
  }
}
