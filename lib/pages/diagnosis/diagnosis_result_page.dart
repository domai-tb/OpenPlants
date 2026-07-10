import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_page.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_page.dart';

/// Page that displays the semantic outcome returned by the diagnosis engine.
///
/// Accepts either a transient [DiagnosisResult] or a persisted
/// [DiagnosisResultEntity]. When [entity] is provided, its data is used
/// for display — otherwise the transient [result] is shown.
class DiagnosisResultPage extends StatefulWidget {
  static const double _maximumContentWidth = 760;

  /// The evaluation result to display (transient, from live diagnosis).
  final DiagnosisResult? result;

  /// Optional persisted entity — takes precedence over [result] when provided.
  final DiagnosisResultEntity? entity;

  /// Optional loader used by widget tests. Production resolves entries through
  /// [AppScope] services.
  final Future<SymptomLogEntry?> Function(String symptomId)? linkedSymptomLoader;

  const DiagnosisResultPage({
    super.key,
    this.result,
    this.entity,
    this.linkedSymptomLoader,
  });

  @override
  State<DiagnosisResultPage> createState() => _DiagnosisResultPageState();

  /// Creates a transient [DiagnosisResult] from a persisted entity.
  static DiagnosisResult? resultFromEntity(DiagnosisResultEntity? entity) {
    if (entity == null) return null;

    return switch (entity.type) {
      DiagnosisResultType.rankedCauses => DiagnosisResult.ranked(entity.causes),
      DiagnosisResultType.emptyInput => const DiagnosisResult.emptyInput(),
      DiagnosisResultType.noClearMatch => DiagnosisResult.noClearMatch(entity.causes.first),
    };
  }
}

class _DiagnosisResultPageState extends State<DiagnosisResultPage> {
  SymptomLogEntry? _linkedSymptom;
  bool _requestedLinkedSymptom = false;

  /// Creates a transient [DiagnosisResult] from a persisted entity.
  DiagnosisResult get _effectiveResult => DiagnosisResultPage.resultFromEntity(widget.entity) ?? widget.result!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLinkedSymptom) return;
    _requestedLinkedSymptom = true;
    _loadLinkedSymptom();
  }

  Future<void> _loadLinkedSymptom() async {
    final symptomId = widget.entity?.symptomLogEntryId;
    if (symptomId == null) return;

    final loader = widget.linkedSymptomLoader;
    final symptomLogger = loader == null ? AppScope.of(context).services.symptomLogger : null;
    final symptom = loader != null
        ? await loader(symptomId)
        : (await symptomLogger!.getSymptomHistory(widget.entity!.plantId))
            .where((entry) => entry.id == symptomId)
            .firstOrNull;
    if (!mounted) return;

    setState(() => _linkedSymptom = symptom);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosisResultsTitle),
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: DiagnosisResultPage._maximumContentWidth),
                child: _buildOutcome(context, horizontalPadding),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutcome(BuildContext context, double horizontalPadding) {
    switch (_effectiveResult.type) {
      case DiagnosisResultType.rankedCauses:
        return _buildRankedResults(context, horizontalPadding);
      case DiagnosisResultType.emptyInput:
        return _buildEmptyInput(context, horizontalPadding);
      case DiagnosisResultType.noClearMatch:
        return _buildNoClearMatch(context, horizontalPadding);
    }
  }

  Widget _buildRankedResults(BuildContext context, double horizontalPadding) {
    final theme = Theme.of(context);
    final rankedCauses = List<ScoredCause>.of(_effectiveResult.causes)
      ..sort((first, second) {
        final scoreComparison = second.score.compareTo(first.score);
        return scoreComparison != 0 ? scoreComparison : first.causeId.compareTo(second.causeId);
      });

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 32),
      children: [
        _buildDisclaimer(context, theme),
        const SizedBox(height: 16),
        if (_linkedSymptom != null) ...[
          _buildLinkedSymptomButton(context, _linkedSymptom!),
          const SizedBox(height: 16),
        ],
        ...rankedCauses.map((cause) => _buildCauseCard(context, theme, cause)),
        const SizedBox(height: 8),
        _buildRestartButton(context, label: context.l10n.diagnosisStartOver),
      ],
    );
  }

  Widget _buildEmptyInput(BuildContext context, double horizontalPadding) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 32),
      children: [
        _buildDisclaimer(context, theme),
        const SizedBox(height: 24),
        if (_linkedSymptom != null) ...[
          _buildLinkedSymptomButton(context, _linkedSymptom!),
          const SizedBox(height: 24),
        ],
        _buildMessageCard(
          theme: theme,
          icon: Icons.playlist_remove,
          title: l10n.diagnosisEmptyInputTitle,
          description: l10n.diagnosisEmptyInputDesc,
        ),
        const SizedBox(height: 24),
        _buildRestartButton(context, label: l10n.diagnosisStartOver),
      ],
    );
  }

  Widget _buildNoClearMatch(BuildContext context, double horizontalPadding) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final suggestions = [
      l10n.diagnosisSuggestionAppropriateLight,
      l10n.diagnosisSuggestionCheckSoilMoisture,
      l10n.diagnosisSuggestionInspectPlant,
      l10n.diagnosisSuggestionConsiderRepotting,
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 32),
      children: [
        _buildDisclaimer(context, theme),
        const SizedBox(height: 24),
        if (_linkedSymptom != null) ...[
          _buildLinkedSymptomButton(context, _linkedSymptom!),
          const SizedBox(height: 24),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageHeader(theme, Icons.help_outline, l10n.diagnosisNoClearMatch),
                const SizedBox(height: 12),
                Text(l10n.diagnosisNoClearMatchDesc, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(l10n.diagnosisGeneralSuggestions, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                ...suggestions.map((suggestion) => _buildBulletItem(theme, suggestion)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildRestartButton(context, label: l10n.diagnosisTryAgain),
      ],
    );
  }

  Widget _buildMessageCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageHeader(theme, icon, title),
            const SizedBox(height: 12),
            Text(description, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
      ],
    );
  }

  Widget _buildRestartButton(BuildContext context, {required String label}) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagnosisPage()));
      },
      icon: const Icon(Icons.refresh),
      label: Text(label),
    );
  }

  Widget _buildLinkedSymptomButton(BuildContext context, SymptomLogEntry symptom) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SymptomLoggerPage(
              plantId: symptom.plantId,
              entry: symptom,
            ),
          ),
        );
      },
      icon: const Icon(Icons.healing),
      label: Text(context.l10n.healthTimelineViewLinkedSymptom),
    );
  }

  Widget _buildDisclaimer(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.diagnosisDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCauseCard(BuildContext context, ThemeData theme, ScoredCause cause) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(_causeName(l10n, cause.causeId), style: theme.textTheme.headlineSmall)),
                const SizedBox(width: 8),
                _buildConfidenceBadge(theme, l10n, cause.confidence),
              ],
            ),
            const SizedBox(height: 12),
            Text(_localizedEvidence(l10n, cause), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            _buildExpandableSection(
              theme,
              title: l10n.diagnosisRecommendedActions,
              icon: Icons.checklist,
              items: _localizedActions(l10n, cause.causeId),
            ),
            const SizedBox(height: 8),
            _buildExpandableSection(
              theme,
              title: l10n.diagnosisFollowUpChecks,
              icon: Icons.search,
              items: _localizedChecks(l10n, cause.causeId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(ThemeData theme, AppLocalizations l10n, ConfidenceLevel level) {
    final (color, label) = switch (level) {
      ConfidenceLevel.high => (theme.colorScheme.primary, l10n.diagnosisConfidenceHigh),
      ConfidenceLevel.medium => (theme.colorScheme.tertiary, l10n.diagnosisConfidenceMedium),
      ConfidenceLevel.low => (theme.colorScheme.outline, l10n.diagnosisConfidenceLow),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
    );
  }

  Widget _buildExpandableSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 24, bottom: 8),
      leading: Icon(icon, size: 20),
      title: Text(title, style: theme.textTheme.titleSmall),
      children: items.map((item) => _buildBulletItem(theme, item)).toList(),
    );
  }

  Widget _buildBulletItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  static String _causeName(AppLocalizations l10n, String causeId) {
    return switch (causeId) {
      'overwatering' => l10n.diagnosisCauseOverwatering,
      'underwatering' => l10n.diagnosisCauseUnderwatering,
      'low_light' => l10n.diagnosisCauseLowLight,
      'sunburn' => l10n.diagnosisCauseSunburn,
      'low_humidity' => l10n.diagnosisCauseLowHumidity,
      'nutrient_problem' => l10n.diagnosisCauseNutrientProblem,
      'root_issue' => l10n.diagnosisCauseRootIssue,
      'pests' => l10n.diagnosisCausePests,
      _ => l10n.diagnosisCauseNoClearMatch,
    };
  }

  static String _localizedEvidence(AppLocalizations l10n, ScoredCause cause) {
    final evidence = cause.evidence;
    final symptomText = _localizedReportedSymptoms(l10n, evidence);
    final parts = <String>[
      if (symptomText.isNotEmpty) l10n.diagnosisEvidenceReportedSymptoms(symptomText),
    ];

    switch (cause.causeId) {
      case 'overwatering':
        if (evidence.contains('You water frequently')) {
          parts.add(l10n.diagnosisEvidenceFrequentWateringTooWet);
        }
        if (evidence.contains('no drainage holes')) {
          parts.add(l10n.diagnosisEvidenceNoDrainage);
        }
        parts.add(l10n.diagnosisEvidenceOverwateringSigns);
      case 'underwatering':
        if (evidence.contains('You water infrequently')) {
          parts.add(l10n.diagnosisEvidenceInfrequentWateringTooDry);
        }
        parts.add(l10n.diagnosisEvidenceUnderwateringSigns);
      case 'low_light':
        if (evidence.contains('receives low light')) {
          parts.add(l10n.diagnosisEvidenceLowLightExposure);
        }
        parts.add(l10n.diagnosisEvidenceLowLightSigns);
      case 'sunburn':
        if (evidence.contains('receives direct sunlight')) {
          parts.add(l10n.diagnosisEvidenceDirectSunlight);
        }
        parts.add(l10n.diagnosisEvidenceSunburnSigns);
      case 'low_humidity':
        if (evidence.contains('humidity in your environment is low')) {
          parts.add(l10n.diagnosisEvidenceLowHumidityEnvironment);
        }
        parts.add(l10n.diagnosisEvidenceLowHumiditySigns);
      case 'nutrient_problem':
        if (evidence.contains("haven't fertilized recently")) {
          parts.add(l10n.diagnosisEvidenceNotFertilizedRecently);
        }
        parts.add(l10n.diagnosisEvidenceNutrientSigns);
      case 'root_issue':
        if (evidence.contains('Frequent watering can lead to root problems')) {
          parts.add(l10n.diagnosisEvidenceFrequentWateringRootProblems);
        }
        parts.add(l10n.diagnosisEvidenceRootProblemSigns);
      case 'pests':
        if (evidence.contains("You've noticed signs of pests")) {
          parts.add(l10n.diagnosisEvidencePestSignsObserved);
        }
        parts.add(l10n.diagnosisEvidencePestInfestationSigns);
      default:
        parts.add(l10n.diagnosisEvidenceDefault);
    }

    return parts.join(' ');
  }

  static String _localizedReportedSymptoms(AppLocalizations l10n, String evidence) {
    const prefix = 'You reported ';
    final start = evidence.indexOf(prefix);
    if (start < 0) {
      return '';
    }

    final symptomStart = start + prefix.length;
    final symptomEnd = evidence.indexOf('.', symptomStart);
    if (symptomEnd < 0) {
      return '';
    }

    return evidence
        .substring(symptomStart, symptomEnd)
        .split(' and ')
        .map((symptom) => _localizedSymptom(l10n, symptom))
        .join(', ');
  }

  static String _localizedSymptom(AppLocalizations l10n, String symptom) {
    return switch (symptom) {
      'yellowing leaves' => l10n.diagnosisSymptomYellowingLeaves,
      'drooping or wilting' => l10n.diagnosisSymptomDroopingWilt,
      'brown leaf tips' => l10n.diagnosisSymptomBrownTips,
      'brown patches' => l10n.diagnosisSymptomBrownPatches,
      'pale leaves' => l10n.diagnosisSymptomPaleLeaves,
      'leggy growth' => l10n.diagnosisSymptomLeggyGrowth,
      'visible insects' => l10n.diagnosisSymptomVisibleInsects,
      'sticky residue' => l10n.diagnosisSymptomStickyResidue,
      'mold on soil' => l10n.diagnosisSymptomMoldOnSoil,
      'foul smell from soil' => l10n.diagnosisSymptomFoulSmell,
      'stunted growth' => l10n.diagnosisSymptomStuntedGrowth,
      'leaf curling' => l10n.diagnosisSymptomLeafCurling,
      'leaf drop' => l10n.diagnosisSymptomLeafDrop,
      _ => l10n.diagnosisEvidenceDefault,
    };
  }

  static List<String> _localizedActions(AppLocalizations l10n, String causeId) {
    return switch (causeId) {
      'overwatering' => [
          l10n.diagnosisActionOverwateringDrySoil,
          l10n.diagnosisActionOverwateringDrainage,
          l10n.diagnosisActionOverwateringTrimRoots,
        ],
      'underwatering' => [
          l10n.diagnosisActionUnderwateringWaterThoroughly,
          l10n.diagnosisActionUnderwateringSchedule,
          l10n.diagnosisActionUnderwateringBottomWater,
        ],
      'low_light' => [
          l10n.diagnosisActionLowLightMovePlant,
          l10n.diagnosisActionLowLightGrowLight,
          l10n.diagnosisActionLowLightRotate,
        ],
      'sunburn' => [
          l10n.diagnosisActionSunburnIndirectLight,
          l10n.diagnosisActionSunburnCurtain,
          l10n.diagnosisActionSunburnRemoveLeaves,
        ],
      'low_humidity' => [
          l10n.diagnosisActionLowHumidityMist,
          l10n.diagnosisActionLowHumidityGroupPlants,
          l10n.diagnosisActionLowHumidityPebbleTray,
        ],
      'nutrient_problem' => [
          l10n.diagnosisActionNutrientsFertilize,
          l10n.diagnosisActionNutrientsRepot,
          l10n.diagnosisActionNutrientsCheckPh,
        ],
      'root_issue' => [
          l10n.diagnosisActionRootsInspect,
          l10n.diagnosisActionRootsTrim,
          l10n.diagnosisActionRootsRepot,
        ],
      'pests' => [
          l10n.diagnosisActionPestsIsolate,
          l10n.diagnosisActionPestsTreat,
          l10n.diagnosisActionPestsInspect,
        ],
      _ => [l10n.diagnosisActionDefaultCare, l10n.diagnosisActionDefaultMoisture],
    };
  }

  static List<String> _localizedChecks(AppLocalizations l10n, String causeId) {
    return switch (causeId) {
      'overwatering' => [
          l10n.diagnosisCheckOverwateringRoots,
          l10n.diagnosisCheckOverwateringMoisture,
        ],
      'underwatering' => [
          l10n.diagnosisCheckUnderwateringRootBall,
          l10n.diagnosisCheckUnderwateringSoil,
        ],
      'low_light' => [
          l10n.diagnosisCheckLowLightGrowth,
          l10n.diagnosisCheckLowLightHours,
        ],
      'sunburn' => [
          l10n.diagnosisCheckSunburnPatches,
          l10n.diagnosisCheckSunburnNewLeaves,
        ],
      'low_humidity' => [
          l10n.diagnosisCheckLowHumidityTips,
          l10n.diagnosisCheckLowHumidityMeasure,
        ],
      'nutrient_problem' => [
          l10n.diagnosisCheckNutrientsGrowth,
          l10n.diagnosisCheckNutrientsRoots,
        ],
      'root_issue' => [
          l10n.diagnosisCheckRootsHealthy,
          l10n.diagnosisCheckRootsRecovery,
        ],
      'pests' => [
          l10n.diagnosisCheckPestsWeekly,
          l10n.diagnosisCheckPestsNearbyPlants,
        ],
      _ => [l10n.diagnosisCheckDefaultMoreDetails, l10n.diagnosisCheckDefaultExpert],
    };
  }
}
