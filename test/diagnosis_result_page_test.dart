import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/injection.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:openplants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:openplants/pages/diagnosis/diagnosis_result_page.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_page.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
  });

  final diagnosis = DiagnosisResultEntity(
    id: 'diagnosis-1',
    plantId: 'plant-1',
    symptomLogEntryId: 'symptom-1',
    plantSymptoms: const [PlantSymptom.yellowingLeaves],
    causes: const [
      ScoredCause(
        causeId: 'overwatering',
        score: 1,
        confidence: ConfidenceLevel.high,
        evidence: '',
        recommendedActions: [],
        followUpChecks: [],
      ),
    ],
    type: DiagnosisResultType.rankedCauses,
    context: const DiagnosisContext(symptoms: [PlantSymptom.yellowingLeaves]),
    createdAt: DateTime(2026),
  );

  final symptom = SymptomLogEntry(
    id: 'symptom-1',
    plantId: 'plant-1',
    symptomTypes: const [PlantSymptom.yellowingLeaves],
    severity: Severity.mild,
    affectedParts: const [AffectedPart.leaves],
    onsetTiming: OnsetTiming.today,
    createdAt: DateTime(2026),
  );

  Widget buildPage(Future<SymptomLogEntry?> Function(String) loader) {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DiagnosisResultPage(
          entity: diagnosis,
          linkedSymptomLoader: loader,
        ),
      ),
    );
  }

  testWidgets('renders a persisted result and navigates to its linked symptom', (tester) async {
    await tester.pumpWidget(buildPage((_) async => symptom));
    await tester.pumpAndSettle();

    expect(find.text('View linked symptom'), findsOneWidget);

    await tester.tap(find.text('View linked symptom'));
    await tester.pumpAndSettle();

    expect(find.byType(SymptomLoggerPage), findsOneWidget);
  });

  testWidgets('does not offer navigation when the linked symptom is missing', (tester) async {
    await tester.pumpWidget(buildPage((_) async => null));
    await tester.pumpAndSettle();

    expect(find.text('View linked symptom'), findsNothing);
  });
}
