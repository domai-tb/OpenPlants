import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_plant/pages/light_assessment/brightness_mapper.dart';
import 'package:open_plant/pages/light_assessment/interactive_light_assessment_page.dart';
import 'package:open_plant/pages/light_assessment/camera_estimation_service.dart';
import 'package:open_plant/pages/light_assessment/light_assessment_usecases.dart';
import 'package:open_plant/pages/light_assessment/light_assessment_repository.dart';
import 'package:open_plant/pages/light_assessment/light_assessment_datasource.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

// ---------------------------------------------------------------------------
// Fake camera service — no real platform channels needed.
// ---------------------------------------------------------------------------

class FakeCameraService extends CameraEstimationService {
  bool _initialized = false;
  void Function(double, LightLevel, double)? _onFrame;

  bool shouldThrowOnInitialize = false;

  /// Emit a synthetic frame to the stream callback.
  void emitFrame(double brightness, LightLevel level, double confidence) {
    _onFrame?.call(brightness, level, confidence);
  }

  @override
  bool get isControllerInitialized => _initialized;

  @override
  CameraController? get controller => null;

  @override
  Future<void> initialize() async {
    if (shouldThrowOnInitialize) {
      throw const CameraEstimationException('Camera not available');
    }
    _initialized = true;
  }

  @override
  Future<void> startFrameStream({
    required void Function(double brightness, LightLevel level, double confidence) onFrame,
  }) async {
    _onFrame = onFrame;
    onFrame(0.5, BrightnessMapper.mapToLightLevel(0.5), 0.8);
  }

  @override
  Future<void> stopFrameStream() async {}

  @override
  @override
  Future<CameraEstimationResult> estimate() async {
    return const CameraEstimationResult(
      level: LightLevel.brightIndirect,
      brightness: 0.65,
      description: 'Bright, indirect light',
    );
  }

  @override
  Future<CameraEstimationResult> estimateFromFile(File photoFile) async {
    return const CameraEstimationResult(
      level: LightLevel.medium,
      brightness: 0.4,
      description: 'Medium light',
    );
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _onFrame = null;
  }
}

// ---------------------------------------------------------------------------
// In-memory light data source for tests.
// ---------------------------------------------------------------------------

class _InMemoryLightDataSource implements LightAssessmentDataSource {
  final Map<String, LightLevel?> _store = {};

  @override
  Future<LightLevel?> loadLightLevel(String plantId) async => _store[plantId];

  @override
  Future<void> saveLightLevel(String plantId, LightLevel level) async {
    _store[plantId] = level;
  }

  @override
  Future<void> clearLightLevel(String plantId) async {
    _store[plantId] = null;
  }
}

// ---------------------------------------------------------------------------
// Permission handler channel mock
// ---------------------------------------------------------------------------

/// Sets up the permission_handler method channel to return [status] for
/// `camera` (permission value `1`).
///
/// Values: 0=denied, 1=granted, 2=restricted, 3=limited, 4=permanentlyDenied.
void mockCameraPermission({int status = 1}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'checkPermissionStatus':
          return status;
        case 'requestPermissions':
          // arguments is List<int> of permission values; return Map<int,int>
          return <int, int>{1: status};
        case 'openSettings':
          return true;
        case 'shouldShowRequestPermissionRationale':
          return false;
        default:
          return null;
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps enough times for the async camera initialisation to settle.
Future<void> pumpUntilCameraReady(
  WidgetTester tester, {
  int maxPumps = 10,
}) async {
  for (int i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeCameraService fakeCamera;
  late _InMemoryLightDataSource dataSource;
  late LightAssessmentRepository repository;
  late LightAssessmentUseCases usecases;
  late LightLevel? capturedLevel;

  setUp(() {
    fakeCamera = FakeCameraService();
    dataSource = _InMemoryLightDataSource();
    repository = LightAssessmentRepository(dataSource: dataSource);
    usecases = LightAssessmentUseCases(
      repository: repository,
      getLatestPhoto: (_) async => null,
      addPhoto: (_, __) async => PlantPhoto(
        id: 'test-photo',
        date: DateTime.now(),
        filePath: '/tmp/test.jpg',
      ),
    );
    capturedLevel = null;

    mockCameraPermission();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      null,
    );
  });

  Widget buildPage({
    String? plantId,
    String? plantName,
    ValueChanged<LightLevel>? onLightLevelSet,
  }) {
    return MaterialApp(
      home: InteractiveLightAssessmentPage(
        plantId: plantId,
        plantName: plantName,
        usecases: usecases,
        onLightLevelSet: onLightLevelSet,
        cameraService: fakeCamera,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading and initialization
  // ---------------------------------------------------------------------------

  group('Loading and initialization', () {
    testWidgets('shows loading state then transitions to camera view', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1', plantName: 'Monstera'));

      // Loading state immediately after creation
      expect(find.text('Initializing camera...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let async init complete
      await pumpUntilCameraReady(tester);

      // Camera view title visible after init
      expect(find.text('Light Assessment — Monstera'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Camera view overlays
  // ---------------------------------------------------------------------------

  group('Camera view overlays', () {
    testWidgets('shows guidance text', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      expect(
        find.textContaining('Move around to see how light levels change'),
        findsOneWidget,
      );
    });

    testWidgets('shows battery warning and can dismiss it', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Battery warning visible
      expect(
        find.textContaining('Continuous camera use may increase battery'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.battery_alert), findsOneWidget);

      // Dismiss by tapping the battery warning close button (last Icons.close in tree)
      await tester.tap(find.byIcon(Icons.close).last);
      await tester.pump();

      expect(
        find.textContaining('Continuous camera use may increase battery'),
        findsNothing,
      );
    });

    testWidgets('shows light level indicator with brightness bar', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Fake calls onFrame(0.5, brightIndirect, 0.8) synchronously
      expect(find.text('Bright Indirect'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Confidence: 80%'), findsOneWidget);
    });

    testWidgets('updates light level indicator when new frame arrives', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Initial state: fake onFrame set brightIndirect
      expect(find.text('Bright Indirect'), findsOneWidget);

      // Emit a new frame with low light
      fakeCamera.emitFrame(0.1, LightLevel.low, 0.7);
      await tester.pump();

      expect(find.text('Low'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
    });

    testWidgets('shows close button and bottom controls', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Top close button
      expect(find.byIcon(Icons.close), findsAtLeast(1));

      // Bottom controls
      expect(find.textContaining('Set this level'), findsWidgets);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byKey(const Key('capture_button')), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Set this level
  // ---------------------------------------------------------------------------

  group('Set this level (plant context)', () {
    testWidgets('saves level and pops the page', (tester) async {
      await tester.pumpWidget(
        buildPage(
          plantId: 'plant-1',
          plantName: 'Monstera',
          onLightLevelSet: (level) => capturedLevel = level,
        ),
      );
      await pumpUntilCameraReady(tester);

      // Tap "Set this level (Bright Indirect)"
      await tester.tap(find.text('Set this level (Bright Indirect)'));
      await tester.pump();
      // Let the async _setCurrentLevel + Navigator.pop() complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Level saved (brightIndirect from fake's sync onFrame)
      final saved = await usecases.getLightLevel('plant-1');
      expect(saved, LightLevel.brightIndirect);
      expect(capturedLevel, LightLevel.brightIndirect);

      // Page popped
      expect(find.byType(InteractiveLightAssessmentPage), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Capture → result view
  // ---------------------------------------------------------------------------

  group('Capture and result view', () {
    testWidgets('shows result view after capture', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Tap capture button
      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pump(); // flash animation starts
      await tester.pump(const Duration(milliseconds: 250)); // flash done, estimate completes
      await tester.pump(); // setState for _showResult

      // Result view visible
      expect(find.text('Assessment Result'), findsOneWidget);
      expect(find.text('Bright, indirect light'), findsOneWidget);
      expect(find.text('Brightness: 65%'), findsOneWidget);
      expect(find.text('Accept & Save'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
    });

    testWidgets('retake returns to camera view', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Capture
      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(find.text('Assessment Result'), findsOneWidget);

      // Tap Retake
      await tester.tap(find.text('Retake'));
      await tester.pump();

      // Result view gone, back to camera view
      expect(find.text('Assessment Result'), findsNothing);
      expect(find.textContaining('Light Assessment'), findsOneWidget);
    });

    testWidgets('accept saves level and pops the page', (tester) async {
      await tester.pumpWidget(
        buildPage(
          plantId: 'plant-1',
          onLightLevelSet: (level) => capturedLevel = level,
        ),
      );
      await pumpUntilCameraReady(tester);

      // Capture
      await tester.tap(find.byKey(const Key('capture_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      // Accept
      await tester.tap(find.text('Accept & Save'));
      await tester.pump();
      // Let the async _acceptCapturedPhoto + Navigator.pop() complete
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Level saved (brightIndirect from fake estimate)
      final saved = await usecases.getLightLevel('plant-1');
      expect(saved, LightLevel.brightIndirect);
      expect(capturedLevel, LightLevel.brightIndirect);

      // Page popped
      expect(find.byType(InteractiveLightAssessmentPage), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Camera timeout
  // ---------------------------------------------------------------------------

  group('Camera timeout', () {
    testWidgets('shows timeout overlay when 2 minutes elapse', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Advance time past the 2-minute camera timeout
      await tester.pump(const Duration(minutes: 2, seconds: 1));

      expect(find.text('Camera timed out'), findsOneWidget);
      expect(find.text('Continue assessing'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('"Continue assessing" dismisses the timeout', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Advance past timeout
      await tester.pump(const Duration(minutes: 2, seconds: 1));

      expect(find.text('Camera timed out'), findsOneWidget);

      // Tap Continue assessing
      await tester.tap(find.text('Continue assessing'));
      await tester.pump();

      // Timeout gone, camera view restored
      expect(find.text('Camera timed out'), findsNothing);
      expect(find.textContaining('Light Assessment'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Permission states
  // ---------------------------------------------------------------------------

  group('Permission states', () {
    testWidgets('shows permission request when not granted', (tester) async {
      mockCameraPermission(status: 0); // denied

      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      expect(
        find.textContaining('Camera access is needed to assess light levels'),
        findsOneWidget,
      );
      expect(find.text('Grant access'), findsOneWidget);
      expect(find.text('Use gallery instead'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows permission permanently denied', (tester) async {
      mockCameraPermission(status: 4); // permanentlyDenied

      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      expect(
        find.textContaining('Camera permission was permanently denied'),
        findsOneWidget,
      );
      expect(find.text('Open settings'), findsOneWidget);
      expect(find.text('Go back'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------

  group('Error handling', () {
    testWidgets('camera init failure falls back to camera view', (tester) async {
      fakeCamera.shouldThrowOnInitialize = true;

      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // After init failure, page shows camera view (no error banner)
      // The page sets _hasPermission = true on error as fallback
      expect(find.textContaining('Light Assessment'), findsOneWidget);
      expect(find.byKey(const Key('capture_button')), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Standalone mode (no plant context)
  // ---------------------------------------------------------------------------

  group('Standalone mode', () {
    testWidgets('shows generic title when no plant name', (tester) async {
      await tester.pumpWidget(buildPage());
      await pumpUntilCameraReady(tester);

      expect(find.text('Light Assessment'), findsOneWidget);
    });

    testWidgets('shows plant name when provided', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1', plantName: 'Monstera'));
      await pumpUntilCameraReady(tester);

      expect(find.text('Light Assessment — Monstera'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Permission flow interactions
  // ---------------------------------------------------------------------------

  group('Permission flow interactions', () {
    testWidgets('Cancel button pops the page', (tester) async {
      mockCameraPermission(status: 0); // denied

      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Page should be popped
      expect(find.byType(InteractiveLightAssessmentPage), findsNothing);
    });

    testWidgets('Go back button pops the page when permanently denied', (tester) async {
      mockCameraPermission(status: 4); // permanentlyDenied

      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      expect(find.text('Go back'), findsOneWidget);

      await tester.tap(find.text('Go back'));
      await tester.pump();

      // Page should be popped
      expect(find.byType(InteractiveLightAssessmentPage), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Timer cleanup
  // ---------------------------------------------------------------------------

  group('Timer cleanup', () {
    testWidgets('timers are cancelled on dispose', (tester) async {
      await tester.pumpWidget(buildPage(plantId: 'plant-1'));
      await pumpUntilCameraReady(tester);

      // Remove the widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // No error means timers were properly cancelled
    });
  });
}
