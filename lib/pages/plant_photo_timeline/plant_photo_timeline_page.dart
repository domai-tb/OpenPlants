import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/date_utils.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:open_plant/widgets/confirm_dialog.dart';

/// Dedicated page showing a plant's growth photo timeline.
///
/// Displays photos in reverse-chronological order with date labels.
/// Supports full-screen viewing, deletion, and date editing.
class PlantPhotoTimelinePage extends StatefulWidget {
  final String plantId;
  final String plantName;

  const PlantPhotoTimelinePage({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<PlantPhotoTimelinePage> createState() => _PlantPhotoTimelinePageState();
}

class _PlantPhotoTimelinePageState extends State<PlantPhotoTimelinePage> {
  late PlantPhotoTimelineUseCases _usecases;
  bool _wired = false;
  List<PlantPhoto> _photos = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantPhotoTimeline;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final photos = await _usecases.getTimeline(widget.plantId);
    if (!mounted) return;
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  Future<void> _deletePhoto(PlantPhoto photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: context.l10n.growthPhotoDeleteTitle,
        message: context.l10n.growthPhotoDeleteConfirm,
        confirmLabel: context.l10n.deletePlant,
      ),
    );

    if (confirmed == true && mounted) {
      await _usecases.deletePhoto(widget.plantId, photo.id);
      if (mounted) {
        setState(() => _photos.removeWhere((p) => p.id == photo.id));
      }
    }
  }

  Future<void> _editDate(PlantPhoto photo) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: photo.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted && picked != photo.date) {
      final updated = await _usecases.updatePhotoDate(
        widget.plantId,
        photo.id,
        picked,
      );
      if (mounted) {
        setState(() => _photos = updated);
      }
    }
  }

  void _openFullScreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenPhotoView(
          photos: _photos.toList(),
          initialIndex: index,
          onDeleted: (photo) {
            setState(() => _photos.removeWhere((p) => p.id == photo.id));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.plantName} — Timeline'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimeline(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.growthPhotosNoTimeline,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.growthPhotosNoTimelineHint,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return _buildPhotoCard(theme, photo, index);
      },
    );
  }

  Widget _buildPhotoCard(ThemeData theme, PlantPhoto photo, int index) {
    final file = File(photo.filePath);
    final exists = file.existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date label (tap to edit)
          GestureDetector(
            onTap: () => _editDate(photo),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(photo.date),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Photo (tap for full-screen, long-press for delete)
          GestureDetector(
            onTap: () => _openFullScreen(index),
            onLongPress: () => _deletePhoto(photo),
            child: exists
                ? Image.file(
                    file,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 300,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.growthPhotoNotFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          // Caption
          if (photo.caption != null && photo.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                photo.caption!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => formatDateShort(date);
}

/// Full-screen photo viewer with swipe navigation.
class _FullScreenPhotoView extends StatefulWidget {
  final List<PlantPhoto> photos;
  final int initialIndex;
  final ValueChanged<PlantPhoto> onDeleted;

  const _FullScreenPhotoView({
    required this.photos,
    required this.initialIndex,
    required this.onDeleted,
  });

  @override
  State<_FullScreenPhotoView> createState() => _FullScreenPhotoViewState();
}

class _FullScreenPhotoViewState extends State<_FullScreenPhotoView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteCurrentPhoto() async {
    final photo = widget.photos[_currentIndex];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: context.l10n.growthPhotoDeleteTitle,
        message: context.l10n.growthPhotoDeleteConfirm,
        confirmLabel: context.l10n.deletePlant,
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDeleted(photo);
      if (_currentIndex >= widget.photos.length - 1 && _currentIndex > 0) {
        _currentIndex--;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCurrentPhoto,
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 300) {
            Navigator.of(context).pop();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            final photo = widget.photos[index];
            final file = File(photo.filePath);
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: file.existsSync()
                    ? Image.file(
                        file,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
