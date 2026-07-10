import 'package:flutter/material.dart';

/// Type of entry on the plant health timeline.
enum TimelineEntryType {
  symptom,
  diagnosis,
}

/// A single entry on a plant's health timeline.
///
/// Represents either a logged symptom or a completed diagnosis, unified
/// into a single model for chronological display.
class TimelineEntry {
  /// Unique identifier for this timeline entry.
  final String id;

  /// The plant this entry belongs to.
  final String plantId;

  /// Whether this entry represents a symptom log or a diagnosis result.
  final TimelineEntryType type;

  /// Primary label displayed on the card (e.g. symptom name or "Diagnosis").
  final String title;

  /// Secondary text shown below the title (e.g. severity or cause ID).
  final String? subtitle;

  /// When this event occurred.
  final DateTime date;

  /// Optional severity string for symptom entries (e.g. "mild", "severe").
  final String? severity;

  /// Optional icon to display alongside the entry.
  final IconData? iconData;

  const TimelineEntry({
    required this.id,
    required this.plantId,
    required this.type,
    required this.title,
    this.subtitle,
    required this.date,
    this.severity,
    this.iconData,
  });

  /// Creates a copy with optional field overrides.
  TimelineEntry copyWith({
    String? id,
    String? plantId,
    TimelineEntryType? type,
    String? title,
    String? subtitle,
    DateTime? date,
    String? severity,
    bool clearSeverity = false,
    IconData? iconData,
    bool clearIcon = false,
  }) {
    return TimelineEntry(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      severity: clearSeverity ? null : (severity ?? this.severity),
      iconData: clearIcon ? null : (iconData ?? this.iconData),
    );
  }

  /// Serializes this entry to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'date': date.toIso8601String(),
      'severity': severity,
    };
  }

  /// Deserializes from a JSON map.
  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      type: TimelineEntryType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      date: DateTime.parse(json['date'] as String),
      severity: json['severity'] as String?,
    );
  }
}
