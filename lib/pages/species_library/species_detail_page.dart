import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';

/// Detail page showing all species fields in structured layout with care plan,
/// toxicity highlights, and difficulty badge.
class SpeciesDetailPage extends StatelessWidget {
  final SpeciesEntity species;
  final SpeciesLibraryUsecases usecases;

  const SpeciesDetailPage({
    super.key,
    required this.species,
    required this.usecases,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carePlan = usecases.generateCarePlan(species);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          species.commonNames.isNotEmpty ? species.commonNames.first : species.scientificName,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: scientific name + difficulty badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.scientificName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (species.commonNames.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            species.commonNames.sublist(1).join(', '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DifficultyBadgeLarge(difficulty: species.difficulty),
              ],
            ),
            const SizedBox(height: 12),

            // Toxicity warnings
            if (species.toxicToHumans || species.toxicToPets) ...[
              _ToxicityWarning(
                toxicToHumans: species.toxicToHumans,
                toxicToPets: species.toxicToPets,
              ),
              const SizedBox(height: 16),
            ],

            // Description
            Text(
              species.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            // Care summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      species.careSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Care Plan Section
            Text(
              context.l10n.speciesLibraryCarePlan,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _CarePlanSection(
              icon: Icons.water_drop,
              title: context.l10n.speciesLibraryWatering,
              guidance: carePlan.wateringGuidance,
            ),
            const SizedBox(height: 12),
            _CarePlanSection(
              icon: Icons.light_mode,
              title: context.l10n.speciesLibraryLight,
              guidance: carePlan.lightGuidance,
            ),
            const SizedBox(height: 12),
            _CarePlanSection(
              icon: Icons.air,
              title: context.l10n.speciesLibraryHumidity,
              guidance: carePlan.humidityGuidance,
            ),
            const SizedBox(height: 12),
            _CarePlanSection(
              icon: Icons.landscape,
              title: context.l10n.speciesLibrarySoil,
              guidance: carePlan.soilRecommendation,
            ),
            const SizedBox(height: 12),
            _CarePlanSection(
              icon: Icons.repeat,
              title: context.l10n.speciesLibraryRepotting,
              guidance: carePlan.repottingAdvice,
            ),
            const SizedBox(height: 24),

            // Quick Facts Section
            Text(
              context.l10n.speciesLibraryQuickFacts,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _QuickFactRow(
              label: context.l10n.speciesLibraryLightNeeds,
              value: _lightNeedsLabel(context, species.lightNeeds),
            ),
            _QuickFactRow(
              label: context.l10n.speciesLibraryWaterNeeds,
              value: _waterNeedsLabel(context, species.waterNeeds),
            ),
            _QuickFactRow(
              label: context.l10n.speciesLibraryHumidityPref,
              value: _humidityLabel(context, species.humidityPreference),
            ),
            _QuickFactRow(
              label: context.l10n.speciesLibrarySoilType,
              value: species.soilType,
            ),
            _QuickFactRow(
              label: context.l10n.speciesLibraryRepottingInterval,
              value: context.l10n.speciesLibraryMonths(species.repottingIntervalMonths),
            ),
          ],
        ),
      ),
    );
  }

  String _lightNeedsLabel(BuildContext context, LightNeeds needs) {
    return switch (needs) {
      LightNeeds.low => context.l10n.speciesLibraryLightLow,
      LightNeeds.medium => context.l10n.speciesLibraryLightMedium,
      LightNeeds.bright => context.l10n.speciesLibraryLightBright,
      LightNeeds.direct => context.l10n.speciesLibraryLightDirect,
    };
  }

  String _waterNeedsLabel(BuildContext context, WaterNeeds needs) {
    return switch (needs) {
      WaterNeeds.low => context.l10n.speciesLibraryWaterLow,
      WaterNeeds.moderate => context.l10n.speciesLibraryWaterModerate,
      WaterNeeds.frequent => context.l10n.speciesLibraryWaterFrequent,
    };
  }

  String _humidityLabel(BuildContext context, HumidityPreference pref) {
    return switch (pref) {
      HumidityPreference.low => context.l10n.speciesLibraryHumidityLow,
      HumidityPreference.moderate => context.l10n.speciesLibraryHumidityModerate,
      HumidityPreference.high => context.l10n.speciesLibraryHumidityHigh,
    };
  }
}

class _DifficultyBadgeLarge extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyBadgeLarge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (Color bgColor, Color textColor, IconData icon, String label) = switch (difficulty) {
      Difficulty.easy => (
          Colors.green.shade100,
          Colors.green.shade800,
          Icons.eco,
          context.l10n.speciesLibraryEasy,
        ),
      Difficulty.moderate => (
          Colors.orange.shade100,
          Colors.orange.shade800,
          Icons.eco,
          context.l10n.speciesLibraryModerate,
        ),
      Difficulty.challenging => (
          Colors.red.shade100,
          Colors.red.shade800,
          Icons.eco,
          context.l10n.speciesLibraryChallenging,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToxicityWarning extends StatelessWidget {
  final bool toxicToHumans;
  final bool toxicToPets;

  const _ToxicityWarning({
    required this.toxicToHumans,
    required this.toxicToPets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final warnings = <String>[];
    if (toxicToHumans) warnings.add(context.l10n.speciesLibraryToxicToHumans);
    if (toxicToPets) warnings.add(context.l10n.speciesLibraryToxicToPets);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.speciesLibraryToxicityWarning,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...warnings.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      w,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarePlanSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String guidance;

  const _CarePlanSection({
    required this.icon,
    required this.title,
    required this.guidance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guidance,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFactRow extends StatelessWidget {
  final String label;
  final String value;

  const _QuickFactRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
