import 'package:flutter_test/flutter_test.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/light_level_modifier.dart';
import 'package:open_plants/pages/light_assessment/brightness_mapper.dart';
import 'package:open_plants/pages/light_assessment/camera_estimation_service.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  group('LightLevelModifier', () {
    group('watering', () {
      test('low light increases watering interval (1.3x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.watering,
          lightLevel: LightLevel.low,
        );
        expect(mod, 1.3);
      });

      test('medium light keeps watering interval (1.0x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.watering,
          lightLevel: LightLevel.medium,
        );
        expect(mod, 1);
      });

      test('bright indirect light reduces watering interval (0.85x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.watering,
          lightLevel: LightLevel.brightIndirect,
        );
        expect(mod, 0.85);
      });

      test('direct light reduces watering interval most (0.7x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.watering,
          lightLevel: LightLevel.direct,
        );
        expect(mod, 0.7);
      });
    });

    group('misting', () {
      test('low light does not affect misting (1.0x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.misting,
          lightLevel: LightLevel.low,
        );
        expect(mod, 1);
      });

      test('direct light does not affect misting (1.0x)', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.misting,
          lightLevel: LightLevel.direct,
        );
        expect(mod, 1);
      });
    });

    group('other task types', () {
      test('fertilizing is not affected by light level', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.fertilizing,
          lightLevel: LightLevel.low,
        );
        expect(mod, 1);
      });

      test('pruning is not affected by light level', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.pruning,
          lightLevel: LightLevel.direct,
        );
        expect(mod, 1);
      });
    });

    group('null light level', () {
      test('null light level returns 1.0 for watering', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.watering,
        );
        expect(mod, 1);
      });

      test('null light level returns 1.0 for misting', () {
        final mod = LightLevelModifier.compute(
          taskType: BuiltInTaskType.misting,
        );
        expect(mod, 1);
      });
    });
  });

  group('BrightnessMapper', () {
    test('maps dark to low', () {
      final level = BrightnessMapper.mapToLightLevel(0.1);
      expect(level, LightLevel.low);
    });

    test('maps medium brightness to medium', () {
      final level = BrightnessMapper.mapToLightLevel(0.35);
      expect(level, LightLevel.medium);
    });

    test('maps bright to brightIndirect', () {
      final level = BrightnessMapper.mapToLightLevel(0.6);
      expect(level, LightLevel.brightIndirect);
    });

    test('maps very bright to direct', () {
      final level = BrightnessMapper.mapToLightLevel(0.85);
      expect(level, LightLevel.direct);
    });

    test('clamps values below 0', () {
      final level = BrightnessMapper.mapToLightLevel(-0.5);
      expect(level, LightLevel.low);
    });

    test('clamps values above 1', () {
      final level = BrightnessMapper.mapToLightLevel(1.5);
      expect(level, LightLevel.direct);
    });

    test('describeEstimate returns appropriate strings', () {
      expect(BrightnessMapper.describeEstimate(LightLevel.low), contains('low light'));
      expect(BrightnessMapper.describeEstimate(LightLevel.medium), contains('medium light'));
      expect(BrightnessMapper.describeEstimate(LightLevel.brightIndirect), contains('bright indirect'));
      expect(BrightnessMapper.describeEstimate(LightLevel.direct), contains('direct'));
    });

    test('boundary values map correctly', () {
      // Exact boundary: 0.25 should be medium (not low)
      expect(BrightnessMapper.mapToLightLevel(0.25), LightLevel.medium);
      // Exact boundary: 0.50 should be brightIndirect (not medium)
      expect(BrightnessMapper.mapToLightLevel(0.50), LightLevel.brightIndirect);
      // Exact boundary: 0.75 should be direct (not brightIndirect)
      expect(BrightnessMapper.mapToLightLevel(0.75), LightLevel.direct);
    });
  });

  group('CameraEstimationService', () {
    test('isAvailable returns false when no cameras exist', () async {
      final service = CameraEstimationService();
      // On test environment, no cameras are available
      final available = await service.isAvailable();
      expect(available, isFalse);
    });

    test('estimate throws when not initialized', () async {
      final service = CameraEstimationService();
      expect(
        service.estimate,
        throwsA(isA<CameraEstimationException>()),
      );
    });

    test('dispose is safe to call multiple times', () async {
      final service = CameraEstimationService();
      await service.dispose();
      await service.dispose(); // Should not throw
    });
  });
}
