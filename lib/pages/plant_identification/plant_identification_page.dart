import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/plant_identification/identification_state.dart';
import 'package:open_plant/pages/plant_identification/widgets/green_dot_lattice_overlay.dart';
import 'package:open_plant/pages/plant_identification/widgets/species_result_card.dart';
import 'package:open_plant/pages/species_library/species_library_item_entity.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';
import 'package:open_plant/pages/species_library/species_detail_page.dart';
import 'package:open_plant/widgets/inline_camera_preview.dart';

class PlantIdentificationPage extends StatefulWidget {
  const PlantIdentificationPage({
    super.key,
  });

  @override
  State<PlantIdentificationPage> createState() => _PlantIdentificationPageState();

  /// Opens the plant identification flow as a full-screen modal bottom sheet.
  static Future<void> showAsModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const PlantIdentificationPage(),
    );
  }
}

class _PlantIdentificationPageState extends State<PlantIdentificationPage> {
  late PlantClassifierUsecases _usecases;
  late SpeciesLibraryUsecases _speciesUsecases;
  bool _wired = false;

  IdentificationState _state = const IdentificationIdle();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    final services = AppScope.of(context).services;
    _usecases = services.plantIdentification;
    _speciesUsecases = services.speciesLibrary;
    _wired = true;
  }

  Future<void> _onCaptured(Uint8List imageBytes) async {
    if (!mounted) return;
    await _startIdentification(imageBytes);
  }

  Future<void> _startIdentification(Uint8List imageBytes) async {
    setState(() {
      _state = IdentificationIdentifying(imageBytes: imageBytes);
    });

    try {
      final result = await _usecases.classifyImage(imageBytes);
      if (!mounted) return;
      setState(() {
        _state = IdentificationResult(
          imageBytes: imageBytes,
          result: result,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = IdentificationError(
          message: '${context.l10n.plantIdIdentificationFailed}: $e',
        );
      });
    }
  }

  void _retake() {
    setState(() {
      _state = const IdentificationIdle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.plantIdentificationTitle,
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return switch (_state) {
      IdentificationIdle() => InlineCameraPreview(
          onCaptured: _onCaptured,
        ),
      IdentificationIdentifying(:final imageBytes) => _buildImageWithOverlay(
          theme,
          imageBytes,
          showLattice: true,
        ),
      IdentificationResult(:final imageBytes, :final result) => _buildResultView(theme, imageBytes, result),
      IdentificationError(:final message) => _buildErrorView(theme, message),
    };
  }

  Widget _buildImageWithOverlay(
    ThemeData theme,
    Uint8List imageBytes, {
    required bool showLattice,
  }) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  if (showLattice) ...[
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: GreenDotLatticeOverlay(isVisible: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(
    ThemeData theme,
    Uint8List imageBytes,
    ClassificationResult result,
  ) {
    final predictions = result.predictions;

    return Column(
      children: [
        // Captured image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              imageBytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Results header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                context.l10n.plantIdResults,
                style: theme.textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _retake,
                icon: const Icon(Icons.camera_alt),
                label: Text(context.l10n.plantIdRetake),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Results list
        Expanded(
          child: predictions.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.plantIdCouldNotIdentify,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  itemCount: predictions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return SpeciesResultCard(
                      prediction: predictions[index],
                      isTopResult: index == 0,
                      topResultLabel: context.l10n.plantIdBestMatch,
                    );
                  },
                ),
        ),
        // Species detail button for top result
        if (predictions.isNotEmpty) _buildSpeciesDetailButton(theme, predictions.first.name),
      ],
    );
  }

  Widget _buildSpeciesDetailButton(ThemeData theme, String scientificName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: FutureBuilder<SpeciesEntity?>(
        future: _speciesUsecases.speciesForIdentifiedPlant(scientificName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('Species lookup failed: ${snapshot.error}');
            return const SizedBox.shrink();
          }

          final species = snapshot.data;
          if (species == null) return const SizedBox.shrink();

          return SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openSpeciesDetail(species),
              icon: const Icon(Icons.menu_book),
              label: Text(context.l10n.speciesLibraryViewDetails),
            ),
          );
        },
      ),
    );
  }

  void _openSpeciesDetail(SpeciesEntity species) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpeciesDetailPage(
          species: species,
          usecases: _speciesUsecases,
        ),
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _retake,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.plantIdTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
