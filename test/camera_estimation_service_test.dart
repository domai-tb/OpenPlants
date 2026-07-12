import 'package:flutter_test/flutter_test.dart';
import 'package:open_plant/pages/light_assessment/brightness_mapper.dart';
import 'package:open_plant/pages/light_assessment/camera_estimation_service.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  group('BrightnessMapper', () {
    test('mapToLightLevel returns low for brightness < 0.25', () {
      expect(BrightnessMapper.mapToLightLevel(0), LightLevel.low);
      expect(BrightnessMapper.mapToLightLevel(0.1), LightLevel.low);
      expect(BrightnessMapper.mapToLightLevel(0.24), LightLevel.low);
    });

    test('mapToLightLevel returns medium for brightness 0.25–0.50', () {
      expect(BrightnessMapper.mapToLightLevel(0.25), LightLevel.medium);
      expect(BrightnessMapper.mapToLightLevel(0.35), LightLevel.medium);
      expect(BrightnessMapper.mapToLightLevel(0.49), LightLevel.medium);
    });

    test('mapToLightLevel returns brightIndirect for brightness 0.50–0.75', () {
      expect(BrightnessMapper.mapToLightLevel(0.50), LightLevel.brightIndirect);
      expect(BrightnessMapper.mapToLightLevel(0.60), LightLevel.brightIndirect);
      expect(BrightnessMapper.mapToLightLevel(0.74), LightLevel.brightIndirect);
    });

    test('mapToLightLevel returns direct for brightness >= 0.75', () {
      expect(BrightnessMapper.mapToLightLevel(0.75), LightLevel.direct);
      expect(BrightnessMapper.mapToLightLevel(0.90), LightLevel.direct);
      expect(BrightnessMapper.mapToLightLevel(1), LightLevel.direct);
    });

    test('mapToLightLevel clamps values outside 0–1 range', () {
      expect(BrightnessMapper.mapToLightLevel(-0.1), LightLevel.low);
      expect(BrightnessMapper.mapToLightLevel(1.5), LightLevel.direct);
    });

    test('describeEstimate returns human-readable description for each level', () {
      expect(BrightnessMapper.describeEstimate(LightLevel.low), contains('low'));
      expect(BrightnessMapper.describeEstimate(LightLevel.medium), contains('medium'));
      expect(BrightnessMapper.describeEstimate(LightLevel.brightIndirect), contains('bright indirect'));
      expect(BrightnessMapper.describeEstimate(LightLevel.direct), contains('direct sunlight'));
    });
  });

  group('CameraEstimationResult', () {
    test('constructor assigns fields correctly', () {
      const result = CameraEstimationResult(
        level: LightLevel.medium,
        brightness: 0.45,
        description: 'Looks like medium light',
      );
      expect(result.level, LightLevel.medium);
      expect(result.brightness, 0.45);
      expect(result.description, 'Looks like medium light');
    });

    test('result with low brightness', () {
      const result = CameraEstimationResult(
        level: LightLevel.low,
        brightness: 0.1,
        description: 'Looks like low light',
      );
      expect(result.level, LightLevel.low);
      expect(result.brightness, closeTo(0.1, 0.01));
    });

    test('result with high brightness', () {
      const result = CameraEstimationResult(
        level: LightLevel.direct,
        brightness: 0.9,
        description: 'Looks like direct sunlight',
      );
      expect(result.level, LightLevel.direct);
      expect(result.brightness, closeTo(0.9, 0.01));
    });
  });

  group('CameraEstimationException', () {
    test('toString returns formatted message', () {
      const exception = CameraEstimationException('Test error');
      expect(exception.toString(), 'CameraEstimationException: Test error');
    });

    test('message is accessible', () {
      const exception = CameraEstimationException('Camera not found');
      expect(exception.message, 'Camera not found');
    });
  });
}
