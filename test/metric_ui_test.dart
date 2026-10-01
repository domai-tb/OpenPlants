import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_history_page.dart';
import 'package:openplants/pages/plant_metrics/metric_list_page.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

class _LocalizedApp extends StatelessWidget {
  final Widget home;

  const _LocalizedApp({required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}

String _unitLabel(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(MetricListPage)))!.metricsUnit;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MetricUsecases usecases;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    final repo = MetricRepository(
      definitionDataSource: MetricDefinitionDataSource(prefs: prefs),
      measurementDataSource: MetricMeasurementDataSource(prefs: prefs),
    );
    usecases = MetricUsecases(repository: repo);
  });

  group('MetricListPage', () {
    testWidgets('requires a unit and trims it before saving', (tester) async {
      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      Finder field(String label) => find.byWidgetPredicate(
            (widget) => widget is TextField && widget.decoration?.labelText == label,
          );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Metric name is required'), findsOneWidget);
      expect(find.text('Unit is required'), findsOneWidget);

      await tester.enterText(field('Name'), 'Leaf firmness');
      await tester.enterText(field(_unitLabel(tester)), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Unit is required'), findsOneWidget);
      expect(await usecases.getDefinitionsForPlant('plant-1'), isEmpty);

      await tester.enterText(field(_unitLabel(tester)), '  cm  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final definition = (await usecases.getDefinitionsForPlant('plant-1')).single;
      expect(definition.name, 'Leaf firmness');
      expect(definition.unit, 'cm');
    });

    testWidgets('shows empty state when no metrics', (tester) async {
      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No metrics yet'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('shows metric list when definitions exist', (tester) async {
      await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('shows latest value when measurements exist', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 22.5,
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('22.5°C'), findsOneWidget);
    });

    testWidgets('shows a retry action when loading fails', (tester) async {
      final retryOnce = _FailOnceMetricUsecases(repository: usecases.repository);
      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(plantId: 'plant-1', plantName: 'My Plant', usecases: retryOnce),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('An error has occurred.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('No metrics yet'), findsOneWidget);
    });

    testWidgets('shows malformed numeric measurements without crashing', (tester) async {
      final definition = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );
      await prefs.setString(
        'metric_measurements_v1',
        jsonEncode([
          {
            'id': 'bad-measurement',
            'metricId': definition.id,
            'plantId': 'plant-1',
            'value': 'warm',
            'measuredAt': DateTime(2026).toIso8601String(),
          },
        ]),
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(plantId: 'plant-1', plantName: 'My Plant', usecases: usecases),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid measurement'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows malformed history values without casting them as numbers', (tester) async {
      final definition = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );
      await prefs.setString(
        'metric_measurements_v1',
        jsonEncode([
          {
            'id': 'bad-measurement',
            'metricId': definition.id,
            'plantId': 'plant-1',
            'value': 'warm',
            'measuredAt': DateTime(2026).toIso8601String(),
          },
        ]),
      );

      await tester.pumpWidget(_LocalizedApp(home: MetricHistoryPage(definition: definition, usecases: usecases)));
      await tester.pumpAndSettle();

      expect(find.text('Invalid measurement'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a retry action when history loading fails', (tester) async {
      final definition = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );
      final retryOnce = _FailOnceMetricHistoryUsecases(repository: usecases.repository);

      await tester.pumpWidget(_LocalizedApp(home: MetricHistoryPage(definition: definition, usecases: retryOnce)));
      await tester.pumpAndSettle();

      expect(find.text('An error has occurred.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('edits, toggles, confirms, and deletes a metric with its measurements', (tester) async {
      final definition = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );
      await usecases.recordMeasurement(metricId: definition.id, plantId: 'plant-1', value: 22.5);

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(plantId: 'plant-1', plantName: 'My Plant', usecases: usecases),
        ),
      );
      await tester.pumpAndSettle();

      Finder field(String label) => find.byWidgetPredicate(
            (widget) => widget is TextField && widget.decoration?.labelText == label,
          );

      await tester.tap(find.byTooltip('Metric actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Name'), 'Room temperature');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await usecases.getDefinitionById(definition.id))?.name, 'Room temperature');
      expect(await usecases.getMeasurementsForMetric(definition.id), hasLength(1));

      await tester.tap(find.byTooltip('Metric actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disable'));
      await tester.pumpAndSettle();
      expect((await usecases.getDefinitionById(definition.id))?.isEnabled, isFalse);

      await tester.tap(find.byTooltip('Metric actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();
      expect((await usecases.getDefinitionById(definition.id))?.isEnabled, isTrue);

      await tester.tap(find.byTooltip('Metric actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await usecases.getDefinitionById(definition.id), isNotNull);

      await tester.tap(find.byTooltip('Metric actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(await usecases.getDefinitionById(definition.id), isNull);
      expect(await usecases.getMeasurementsForMetric(definition.id), isEmpty);
    });

    testWidgets('scoping: only shows metrics for specified plant', (tester) async {
      await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Plant 1 Metric',
        valueType: MetricValueType.numeric,
        unit: 'value',
      );
      await usecases.createDefinition(
        plantId: 'plant-2',
        name: 'Plant 2 Metric',
        valueType: MetricValueType.boolean,
        unit: 'state',
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plant 1 Metric'), findsOneWidget);
      expect(find.text('Plant 2 Metric'), findsNothing);
    });

    testWidgets('creates numeric metrics with visible alert thresholds', (tester) async {
      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      Finder field(String label) => find.byWidgetPredicate(
            (widget) => widget is TextField && widget.decoration?.labelText == label,
          );

      await tester.enterText(field('Name'), 'Soil moisture');
      await tester.enterText(field(_unitLabel(tester)), '%');
      await tester.enterText(field('Minimum alert value (optional)'), '80');
      await tester.enterText(field('Maximum alert value (optional)'), '20');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Minimum cannot exceed maximum'), findsOneWidget);
      expect(await usecases.getDefinitionsForPlant('plant-1'), isEmpty);

      await tester.enterText(field('Minimum alert value (optional)'), '20');
      await tester.enterText(field('Maximum alert value (optional)'), '80');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final definition = (await usecases.getDefinitionsForPlant('plant-1')).single;
      expect(definition.numericBounds?.lower, 20);
      expect(definition.numericBounds?.upper, 80);
    });

    testWidgets('creates categorical metrics with options and selected alert values', (tester) async {
      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricListPage(
            plantId: 'plant-1',
            plantName: 'My Plant',
            usecases: usecases,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<MetricValueType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categorical').last);
      await tester.pumpAndSettle();

      Finder field(String label) => find.byWidgetPredicate(
            (widget) => widget is TextField && widget.decoration?.labelText == label,
          );

      await tester.enterText(field('Name'), 'Leaf color');
      await tester.enterText(field(_unitLabel(tester)), 'state');
      await tester.enterText(field('Options'), 'Green, green');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Options must be unique'), findsOneWidget);
      expect(await usecases.getDefinitionsForPlant('plant-1'), isEmpty);

      await tester.enterText(field('Options'), 'Green, Yellow, Brown');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alert on Yellow'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final definition = (await usecases.getDefinitionsForPlant('plant-1')).single;
      expect(definition.categoryOptions, ['Green', 'Yellow', 'Brown']);
      expect(definition.alertValues, {'Yellow'});
    });
  });

  group('MetricHistoryPage', () {
    testWidgets('shows empty state when no measurements', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricHistoryPage(definition: def, usecases: usecases),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('shows measurement list when data exists', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 65.0,
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricHistoryPage(definition: def, usecases: usecases),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('65.0%'), findsOneWidget);
    });

    testWidgets('shows graph for numeric metrics', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 50.0,
      );
      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 70.0,
      );

      await tester.pumpWidget(
        _LocalizedApp(
          home: MetricHistoryPage(definition: def, usecases: usecases),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}

class _FailOnceMetricUsecases extends MetricUsecases {
  _FailOnceMetricUsecases({required super.repository});

  bool _shouldFail = true;

  @override
  Future<List<MetricDefinition>> getDefinitionsForPlant(String plantId) {
    if (_shouldFail) {
      _shouldFail = false;
      return Future.error(StateError('temporary storage failure'));
    }
    return super.getDefinitionsForPlant(plantId);
  }
}

class _FailOnceMetricHistoryUsecases extends MetricUsecases {
  _FailOnceMetricHistoryUsecases({required super.repository});

  bool _shouldFail = true;

  @override
  Future<List<MetricMeasurement>> getMeasurementsForMetric(String metricId) {
    if (_shouldFail) {
      _shouldFail = false;
      return Future.error(StateError('temporary measurement storage failure'));
    }
    return super.getMeasurementsForMetric(metricId);
  }
}
