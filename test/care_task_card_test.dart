import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/care_schedule/widgets/care_task_card.dart';

void main() {
  testWidgets('metric alert tasks only offer completion', (tester) async {
    final task = CareTask(
      taskType: const CareTaskType.custom('metric_alert:soil'),
      plantId: 'plant-1',
      plantName: 'Fern',
      dueDate: DateTime(2025),
      status: CareTaskStatus.dueToday,
      effectiveIntervalDays: 0,
      alertEpisodeId: 'episode-1',
      alertMetricName: 'Soil moisture',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CareTaskCard(
            task: task,
            onDone: () {},
            onSnooze: (_) {},
            onSkip: () {},
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(PopupMenuButton<int>), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
