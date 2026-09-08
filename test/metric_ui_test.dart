import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_history_page.dart';
import 'package:openplants/pages/plant_metrics/metric_list_page.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MetricUsecases usecases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = MetricRepository(
      definitionDataSource: MetricDefinitionDataSource(prefs: prefs),
      measurementDataSource: MetricMeasurementDataSource(prefs: prefs),
    );
    usecases = MetricUsecases(repository: repo);
  });

  group('MetricListPage', () {
    testWidgets('shows empty state when no metrics', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MetricListPage(
          plantId: 'plant-1',
          plantName: 'My Plant',
          usecases: usecases,
        ),
      ));
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

      await tester.pumpWidget(MaterialApp(
        home: MetricListPage(
          plantId: 'plant-1',
          plantName: 'My Plant',
          usecases: usecases,
        ),
      ));
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

      await tester.pumpWidget(MaterialApp(
        home: MetricListPage(
          plantId: 'plant-1',
          plantName: 'My Plant',
          usecases: usecases,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('22.5°C'), findsOneWidget);
    });

    testWidgets('scoping: only shows metrics for specified plant', (tester) async {
      await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Plant 1 Metric',
        valueType: MetricValueType.numeric,
      );
      await usecases.createDefinition(
        plantId: 'plant-2',
        name: 'Plant 2 Metric',
        valueType: MetricValueType.boolean,
      );

      await tester.pumpWidget(MaterialApp(
        home: MetricListPage(
          plantId: 'plant-1',
          plantName: 'My Plant',
          usecases: usecases,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Plant 1 Metric'), findsOneWidget);
      expect(find.text('Plant 2 Metric'), findsNothing);
    });
  });

  group('MetricHistoryPage', () {
    testWidgets('shows empty state when no measurements', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
      );

      await tester.pumpWidget(MaterialApp(
        home: MetricHistoryPage(definition: def, usecases: usecases),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No measurements yet'), findsOneWidget);
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

      await tester.pumpWidget(MaterialApp(
        home: MetricHistoryPage(definition: def, usecases: usecases),
      ));
      await tester.pumpAndSettle();

      expect(find.text('65.0%'), findsOneWidget);
    });

    testWidgets('shows graph for numeric metrics', (tester) async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
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

      await tester.pumpWidget(MaterialApp(
        home: MetricHistoryPage(definition: def, usecases: usecases),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
