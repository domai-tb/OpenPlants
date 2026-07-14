import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_page.dart';

/// Multi-step questionnaire for collecting symptom and plant context information
/// to feed into the diagnosis engine.
class DiagnosisPage extends StatefulWidget {
  /// Optional pre-filled plant species name.
  final String? plantSpecies;

  /// Symptoms to select when the questionnaire opens.
  final Set<PlantSymptom> initialSymptoms;

  /// Optional pre-filled watering frequency.
  final WateringFrequency? initialWateringFrequency;

  /// Optional pre-filled light exposure level.
  final LightExposure? initialLightExposure;

  /// Optional pre-filled humidity level.
  final HumidityLevel? initialHumidityLevel;

  /// Optional pre-filled pot type.
  final PotType? initialPotType;

  /// Optional pre-filled soil type.
  final SoilType? initialSoilType;

  /// Optional pre-filled answer about recent fertilizing.
  final bool? initialRecentFertilizing;

  /// Optional pre-filled answer about visible pest signs.
  final bool? initialPestSigns;

  const DiagnosisPage({
    super.key,
    this.plantSpecies,
    this.initialSymptoms = const {},
    this.initialWateringFrequency,
    this.initialLightExposure,
    this.initialHumidityLevel,
    this.initialPotType,
    this.initialSoilType,
    this.initialRecentFertilizing,
    this.initialPestSigns,
  });

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  // Form data
  final Set<PlantSymptom> _selectedSymptoms = {};
  WateringFrequency? _wateringFrequency;
  LightExposure? _lightExposure;
  HumidityLevel? _humidityLevel;
  PotType? _potType;
  SoilType? _soilType;
  bool? _recentFertilizing;
  bool? _pestSigns;
  late final TextEditingController _plantSpeciesController;

  // Page control
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    _selectedSymptoms.addAll(widget.initialSymptoms);
    _wateringFrequency = widget.initialWateringFrequency;
    _lightExposure = widget.initialLightExposure;
    _humidityLevel = widget.initialHumidityLevel;
    _potType = widget.initialPotType;
    _soilType = widget.initialSoilType;
    _recentFertilizing = widget.initialRecentFertilizing;
    _pestSigns = widget.initialPestSigns;
    _plantSpeciesController = TextEditingController(text: widget.plantSpecies ?? '');
  }

  @override
  void dispose() {
    _plantSpeciesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _selectedSymptoms.isNotEmpty;
      case 1:
      case 2:
      case 3:
        return true; // Optional fields
      default:
        return true;
    }
  }

  Future<void> _goNext() async {
    if (!_canProceedFromStep(_currentStep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.diagnosisSymptomRequired)),
      );
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _goBack() async {
    if (_currentStep > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _startDiagnosis() async {
    if (_evaluating) return;
    setState(() => _evaluating = true);

    try {
      final plantSpecies = _plantSpeciesController.text.trim();
      final diagnosisContext = DiagnosisContext(
        symptoms: _selectedSymptoms.toList(),
        plantSpecies: plantSpecies.isEmpty ? null : plantSpecies,
        potType: _potType,
        soilType: _soilType,
        wateringFrequency: _wateringFrequency,
        lightExposure: _lightExposure,
        humidityLevel: _humidityLevel,
        recentFertilizing: _recentFertilizing,
        pestSigns: _pestSigns,
      );

      final repository = AppScope.of(context).services.diagnosis;
      final result = repository.evaluate(diagnosisContext);

      final entity = DiagnosisResultEntity(
        id: const Uuid().v4(),
        plantId: '',
        plantSymptoms: _selectedSymptoms.toList(),
        causes: result.causes,
        type: result.type,
        context: diagnosisContext,
        createdAt: DateTime.now(),
      );

      await repository.saveResult(entity);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiagnosisResultPage(entity: entity),
        ),
      );
    } finally {
      if (mounted) setState(() => _evaluating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.diagnosisTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentStep = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSymptomStep(),
                _buildContextStep(),
                _buildAdditionalStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  // --- Progress Indicator ---

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.diagnosisStepProgress(_currentStep + 1, _totalSteps),
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                _stepTitle(_currentStep),
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return context.l10n.diagnosisStepSymptoms;
      case 1:
        return context.l10n.diagnosisStepContext;
      case 2:
        return context.l10n.diagnosisStepDetails;
      case 3:
        return context.l10n.diagnosisStepReview;
      default:
        return '';
    }
  }

  // --- Step 1: Symptom Selection ---

  Widget _buildSymptomStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.diagnosisSelectSymptoms,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlantSymptom.values.map((symptom) {
              final selected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                selected: selected,
                label: Text(_symptomLabel(symptom)),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Step 2: Plant Context (Environment) ---

  Widget _buildContextStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.diagnosisEnvironmentTitle,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Watering Frequency
          Text(context.l10n.diagnosisWateringFrequency, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WateringFrequency.values.map((freq) {
              final selected = _wateringFrequency == freq;
              return ChoiceChip(
                selected: selected,
                label: Text(_wateringLabel(freq)),
                onSelected: (value) {
                  setState(() => _wateringFrequency = value ? freq : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Light Exposure
          Text(context.l10n.diagnosisLightExposure, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LightExposure.values.map((light) {
              final selected = _lightExposure == light;
              return ChoiceChip(
                selected: selected,
                label: Text(_lightLabel(light)),
                onSelected: (value) {
                  setState(() => _lightExposure = value ? light : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Humidity Level
          Text(context.l10n.diagnosisHumidityLevel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HumidityLevel.values.map((humidity) {
              final selected = _humidityLevel == humidity;
              return ChoiceChip(
                selected: selected,
                label: Text(_humidityLabel(humidity)),
                onSelected: (value) {
                  setState(() => _humidityLevel = value ? humidity : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Pot Type
          Text(context.l10n.diagnosisPotType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PotType.values.map((pot) {
              final selected = _potType == pot;
              return ChoiceChip(
                selected: selected,
                label: Text(_potLabel(pot)),
                onSelected: (value) {
                  setState(() => _potType = value ? pot : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Soil Type
          Text(context.l10n.diagnosisSoilType, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SoilType.values.map((soil) {
              final selected = _soilType == soil;
              return ChoiceChip(
                selected: selected,
                label: Text(_soilLabel(soil)),
                onSelected: (value) {
                  setState(() => _soilType = value ? soil : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Additional Questions ---

  Widget _buildAdditionalStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.diagnosisAdditionalInfo,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Plant Species
          Text(context.l10n.diagnosisPlantSpecies, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _plantSpeciesController,
            decoration: InputDecoration(
              hintText: context.l10n.diagnosisPlantSpeciesHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Fertilizing
          _buildOptionalBooleanQuestion(
            title: context.l10n.diagnosisRecentFertilizing,
            subtitle: context.l10n.diagnosisRecentFertilizingHint,
            value: _recentFertilizing,
            onChanged: (value) => setState(() => _recentFertilizing = value),
          ),
          const Divider(),

          // Pest Signs
          _buildOptionalBooleanQuestion(
            title: context.l10n.diagnosisPestSigns,
            subtitle: context.l10n.diagnosisPestSignsHint,
            value: _pestSigns,
            onChanged: (value) => setState(() => _pestSigns = value),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalBooleanQuestion({
    required String title,
    required String subtitle,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(context.l10n.diagnosisAnswerYes)),
              ButtonSegment(value: false, label: Text(context.l10n.diagnosisAnswerNo)),
            ],
            selected: value == null ? const <bool>{} : <bool>{value},
            emptySelectionAllowed: true,
            onSelectionChanged: (selection) => onChanged(selection.isEmpty ? null : selection.first),
          ),
        ],
      ),
    );
  }

  // --- Step 4: Review ---

  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.diagnosisReviewTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildReviewSection(
            theme,
            icon: Icons.healing,
            title: context.l10n.diagnosisReviewSymptoms,
            value: _selectedSymptoms.map(_symptomLabel).join(', '),
          ),
          const SizedBox(height: 12),
          if (_wateringFrequency != null)
            _buildReviewSection(
              theme,
              icon: Icons.water_drop,
              title: context.l10n.diagnosisReviewWatering,
              value: _wateringLabel(_wateringFrequency!),
            ),
          const SizedBox(height: 12),
          if (_lightExposure != null)
            _buildReviewSection(
              theme,
              icon: Icons.light_mode,
              title: context.l10n.diagnosisReviewLight,
              value: _lightLabel(_lightExposure!),
            ),
          const SizedBox(height: 12),
          if (_humidityLevel != null)
            _buildReviewSection(
              theme,
              icon: Icons.water,
              title: context.l10n.diagnosisReviewHumidity,
              value: _humidityLabel(_humidityLevel!),
            ),
          const SizedBox(height: 12),
          if (_potType != null)
            _buildReviewSection(
              theme,
              icon: Icons.circle_outlined,
              title: context.l10n.diagnosisReviewPotType,
              value: _potLabel(_potType!),
            ),
          const SizedBox(height: 12),
          if (_soilType != null)
            _buildReviewSection(
              theme,
              icon: Icons.landscape,
              title: context.l10n.diagnosisReviewSoil,
              value: _soilLabel(_soilType!),
            ),
          const SizedBox(height: 12),
          if (_plantSpeciesController.text.trim().isNotEmpty)
            _buildReviewSection(
              theme,
              icon: Icons.eco,
              title: context.l10n.diagnosisReviewSpecies,
              value: _plantSpeciesController.text.trim(),
            ),
          const SizedBox(height: 12),
          _buildReviewSection(
            theme,
            icon: Icons.science,
            title: context.l10n.diagnosisReviewRecentlyFertilized,
            value: _optionalBooleanLabel(_recentFertilizing),
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            theme,
            icon: Icons.bug_report,
            title: context.l10n.diagnosisReviewPestSigns,
            value: _optionalBooleanLabel(_pestSigns),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  // --- Navigation Bar ---

  Widget _buildNavigationBar() {
    final isLastStep = _currentStep == _totalSteps - 1;
    final isFirstStep = _currentStep == 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!isFirstStep)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _evaluating ? null : _goBack,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.l10n.back),
                ),
              ),
            if (!isFirstStep) const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _evaluating ? null : (isLastStep ? _startDiagnosis : _goNext),
                icon: _evaluating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isLastStep ? Icons.search : Icons.arrow_forward),
                label: Text(
                  _evaluating
                      ? context.l10n.diagnosisEvaluating
                      : (isLastStep ? context.l10n.diagnosisStartDiagnosis : context.l10n.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Label Helpers ---

  String _optionalBooleanLabel(bool? value) {
    if (value == null) return context.l10n.diagnosisAnswerUnknown;
    return value ? context.l10n.diagnosisAnswerYes : context.l10n.diagnosisAnswerNo;
  }

  String _symptomLabel(PlantSymptom symptom) {
    switch (symptom) {
      case PlantSymptom.yellowingLeaves:
        return context.l10n.diagnosisSymptomYellowingLeaves;
      case PlantSymptom.droopingWilt:
        return context.l10n.diagnosisSymptomDroopingWilt;
      case PlantSymptom.brownTips:
        return context.l10n.diagnosisSymptomBrownTips;
      case PlantSymptom.brownPatches:
        return context.l10n.diagnosisSymptomBrownPatches;
      case PlantSymptom.paleLeaves:
        return context.l10n.diagnosisSymptomPaleLeaves;
      case PlantSymptom.leggyGrowth:
        return context.l10n.diagnosisSymptomLeggyGrowth;
      case PlantSymptom.visibleInsects:
        return context.l10n.diagnosisSymptomVisibleInsects;
      case PlantSymptom.stickyResidue:
        return context.l10n.diagnosisSymptomStickyResidue;
      case PlantSymptom.moldOnSoil:
        return context.l10n.diagnosisSymptomMoldOnSoil;
      case PlantSymptom.foulSmell:
        return context.l10n.diagnosisSymptomFoulSmell;
      case PlantSymptom.stuntedGrowth:
        return context.l10n.diagnosisSymptomStuntedGrowth;
      case PlantSymptom.leafCurling:
        return context.l10n.diagnosisSymptomLeafCurling;
      case PlantSymptom.leafDrop:
        return context.l10n.diagnosisSymptomLeafDrop;
      case PlantSymptom.softStems:
        return 'Soft Stems';
      case PlantSymptom.drySoil:
        return 'Dry Soil';
      case PlantSymptom.wetSoil:
        return 'Wet Soil';
      case PlantSymptom.leafSpots:
        return 'Leaf Spots';
    }
  }

  String _wateringLabel(WateringFrequency freq) {
    switch (freq) {
      case WateringFrequency.frequent:
        return context.l10n.diagnosisWateringFrequent;
      case WateringFrequency.normal:
        return context.l10n.diagnosisWateringNormal;
      case WateringFrequency.infrequent:
        return context.l10n.diagnosisWateringInfrequent;
    }
  }

  String _lightLabel(LightExposure light) {
    switch (light) {
      case LightExposure.low:
        return context.l10n.diagnosisLightLow;
      case LightExposure.indirect:
        return context.l10n.diagnosisLightIndirect;
      case LightExposure.direct:
        return context.l10n.diagnosisLightDirect;
    }
  }

  String _humidityLabel(HumidityLevel humidity) {
    switch (humidity) {
      case HumidityLevel.low:
        return context.l10n.diagnosisHumidityLow;
      case HumidityLevel.moderate:
        return context.l10n.diagnosisHumidityModerate;
      case HumidityLevel.high:
        return context.l10n.diagnosisHumidityHigh;
    }
  }

  String _potLabel(PotType pot) {
    switch (pot) {
      case PotType.standard:
        return context.l10n.diagnosisPotStandard;
      case PotType.selfWatering:
        return context.l10n.diagnosisPotSelfWatering;
      case PotType.noDrainage:
        return context.l10n.diagnosisPotNoDrainage;
    }
  }

  String _soilLabel(SoilType soil) {
    switch (soil) {
      case SoilType.standard:
        return context.l10n.diagnosisSoilStandard;
      case SoilType.succulent:
        return context.l10n.diagnosisSoilSucculent;
      case SoilType.orchid:
        return context.l10n.diagnosisSoilOrchid;
      case SoilType.cactus:
        return context.l10n.diagnosisSoilCactus;
    }
  }
}
