import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/exceptions.dart';
import 'package:openplants/pages/room_profiles/room_profiles_datasource.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';

void main() {
  late SharedPreferences prefs;
  late RoomProfilesDatasource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = RoomProfilesDatasource(prefs: prefs);
  });

  test('throws on malformed room data and blocks overwriting it', () async {
    const corrupt = '[{"id":"missing-required-fields"}]';
    await prefs.setString('room_profiles_v1', corrupt);

    expect(dataSource.loadRooms(), throwsA(isA<RecordDecodeFailure>()));

    final room = RoomEntity(
      id: 'room-1',
      name: 'Living room',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(dataSource.saveRooms([room]), throwsA(isA<BlockedAfterDecodeFailure>()));
    expect(prefs.getString('room_profiles_v1'), corrupt);
  });

  test('defaults missing environment values to medium', () async {
    final raw = jsonEncode([
      {
        'id': 'room-1',
        'name': 'Living room',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      },
    ]);
    await prefs.setString('room_profiles_v1', raw);

    final room = (await dataSource.loadRooms()).single;

    expect(room.lightLevel, RoomLightLevel.medium);
    expect(room.humidityLevel, RoomHumidityLevel.medium);
  });

  for (final (field, value) in [('lightLevel', 'extreme'), ('humidityLevel', 'extreme')]) {
    test('preserves room data with unknown $field values', () async {
      final corrupt = jsonEncode([
        {
          'id': 'room-1',
          'name': 'Living room',
          'lightLevel': field == 'lightLevel' ? value : 'medium',
          'humidityLevel': field == 'humidityLevel' ? value : 'medium',
          'createdAt': '2026-01-01T00:00:00.000',
          'updatedAt': '2026-01-01T00:00:00.000',
        },
      ]);
      await prefs.setString('room_profiles_v1', corrupt);

      await expectLater(dataSource.loadRooms(), throwsA(isA<RecordDecodeFailure>()));
      await expectLater(
        dataSource.saveRooms([
          RoomEntity(id: 'room-2', name: 'Bedroom', createdAt: DateTime(2026), updatedAt: DateTime(2026)),
        ]),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
      expect(prefs.getString('room_profiles_v1'), corrupt);
    });
  }

  test('loads and saves valid rooms', () async {
    final room = RoomEntity(
      id: 'room-1',
      name: 'Living room',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await dataSource.saveRooms([room]);

    expect((await dataSource.loadRooms()).single.toJson(), room.toJson());
    expect(jsonDecode(prefs.getString('room_profiles_v1')!), hasLength(1));
  });
}
