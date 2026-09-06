import 'package:flutter/material.dart';
import 'package:open_plants/l10n/l10n.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule_usecases.dart';

/// Section on the plant detail page showing custom care rules.
class CareRulesSection extends StatelessWidget {
  final String plantId;
  final CustomCareRuleUsecases usecases;
  final CareScheduleUsecases? careScheduleUsecases;

  const CareRulesSection({
    super.key,
    required this.plantId,
    required this.usecases,
    this.careScheduleUsecases,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<CustomCareRuleEntity>>(
      future: usecases.getByPlant(plantId),
      builder: (context, snapshot) {
        final rules = snapshot.data ?? [];
        final activeCount = rules.where((r) => r.isEnabled).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.careRulesTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                if (rules.isNotEmpty)
                  TextButton(
                    onPressed: () => _openRuleList(context),
                    child: Text(l10n.careRulesManage),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (rules.isEmpty)
              _buildEmptyState(context, theme, l10n)
            else
              _buildSummary(context, theme, activeCount, l10n),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => _openRuleList(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.careRulesEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.careRulesEmptyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    ThemeData theme,
    int activeCount,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: () => _openRuleList(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.rule, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.careRulesActiveCount(activeCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _openRuleList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CareRuleListSheet(
        plantId: plantId,
        usecases: usecases,
        careScheduleUsecases: careScheduleUsecases,
      ),
    );
  }
}

/// Bottom sheet listing all custom care rules for a plant.
class CareRuleListSheet extends StatefulWidget {
  final String plantId;
  final CustomCareRuleUsecases usecases;
  final CareScheduleUsecases? careScheduleUsecases;

  const CareRuleListSheet({
    super.key,
    required this.plantId,
    required this.usecases,
    this.careScheduleUsecases,
  });

  @override
  State<CareRuleListSheet> createState() => _CareRuleListSheetState();
}

class _CareRuleListSheetState extends State<CareRuleListSheet> {
  List<ComputedRule> _computedRules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    if (widget.careScheduleUsecases != null) {
      final computed = await widget.careScheduleUsecases!.getComputedRules(widget.plantId);
      if (mounted) {
        setState(() {
          _computedRules = computed;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.careRulesTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addRule(context),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _computedRules.isEmpty
                  ? _buildEmptyState(context, theme, l10n)
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _computedRules.length,
                      itemBuilder: (context, index) {
                        final rule = _computedRules[index];
                        return CareRuleItem(
                          rule: rule,
                          onToggle: (intervalDays) async {
                            await widget.careScheduleUsecases?.toggleComputedRule(
                              plantId: widget.plantId,
                              taskType: rule.taskType,
                              intervalDays: intervalDays,
                            );
                            await _loadRules();
                          },
                          onEdit: () => _editComputedRule(context, rule),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rule_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.careRulesAdd,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.careRulesEmptyHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addRule(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.careRulesAdd),
          ),
        ],
      ),
    );
  }

  void _addRule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CareRuleFormSheet(
        plantId: widget.plantId,
        usecases: widget.usecases,
        onSaved: _loadRules,
      ),
    );
  }

  void _editComputedRule(BuildContext context, ComputedRule rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CareRuleFormSheet(
        plantId: widget.plantId,
        usecases: widget.usecases,
        existingTaskType: rule.taskType,
        existingIntervalDays: rule.effectiveIntervalDays,
        onSaved: _loadRules,
      ),
    );
  }
}

/// A single care rule item showing computed rules with visual badges.
class CareRuleItem extends StatelessWidget {
  final ComputedRule rule;
  final ValueChanged<int> onToggle;
  final VoidCallback? onEdit;

  const CareRuleItem({
    super.key,
    required this.rule,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: _buildBadge(theme, l10n),
      title: Text(rule.taskType),
      subtitle: Text('Every ${rule.effectiveIntervalDays} days'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
          Switch(
            value: rule.isEnabled,
            onChanged: (value) => onToggle(rule.effectiveIntervalDays),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, AppLocalizations l10n) {
    if (rule.isOverridden) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          l10n.careRulesBadgeCustom,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.careRulesBadgeDefault,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Bottom sheet form for adding or editing a custom care rule.
class CareRuleFormSheet extends StatefulWidget {
  final String plantId;
  final CustomCareRuleUsecases usecases;
  final CustomCareRuleEntity? existingRule;
  final String? existingTaskType;
  final int? existingIntervalDays;
  final VoidCallback? onSaved;

  const CareRuleFormSheet({
    super.key,
    required this.plantId,
    required this.usecases,
    this.existingRule,
    this.existingTaskType,
    this.existingIntervalDays,
    this.onSaved,
  });

  @override
  State<CareRuleFormSheet> createState() => _CareRuleFormSheetState();
}

class _CareRuleFormSheetState extends State<CareRuleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _taskTypeController = TextEditingController();
  final _intervalController = TextEditingController();
  final _reminderTimeController = TextEditingController();

  String? _selectedBuiltInType;
  bool _useCustomType = false;
  bool _reminderEnabled = false;
  List<String> _selectedDays = [];

  bool get _isEditing => widget.existingRule != null || widget.existingTaskType != null;

  static const _daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const _builtInTypes = [
    'watering',
    'fertilizing',
    'misting',
    'pruning',
    'rotating',
    'repotting',
    'leafCleaning',
    'pestInspection',
  ];

  static const _builtInLabels = [
    'Watering',
    'Fertilizing',
    'Misting',
    'Pruning',
    'Rotating',
    'Repotting',
    'Leaf Cleaning',
    'Pest Inspection',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final rule = widget.existingRule;
      final taskType = rule?.taskType ?? widget.existingTaskType;
      final interval = rule?.intervalDays ?? widget.existingIntervalDays ?? 7;

      _intervalController.text = interval.toString();
      if (rule != null) {
        _reminderEnabled = rule.reminderEnabled;
        _reminderTimeController.text = rule.reminderTime ?? '';
        _selectedDays = rule.reminderDays != null ? List.from(rule.reminderDays!) : [];
      }

      // Check if it's a built-in type
      if (taskType != null) {
        final builtInIndex = _builtInTypes.indexOf(taskType);
        if (builtInIndex >= 0) {
          _selectedBuiltInType = taskType;
          _useCustomType = false;
        } else {
          _taskTypeController.text = taskType;
          _useCustomType = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _taskTypeController.dispose();
    _intervalController.dispose();
    _reminderTimeController.dispose();
    super.dispose();
  }

  String? get _effectiveTaskType {
    if (_useCustomType) {
      return _taskTypeController.text.trim().isEmpty ? null : _taskTypeController.text.trim();
    }
    return _selectedBuiltInType;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final taskType = _effectiveTaskType;
    if (taskType == null) return;

    final interval = int.tryParse(_intervalController.text) ?? 7;

    try {
      if (widget.existingRule != null) {
        await widget.usecases.update(
          widget.existingRule!.id,
          taskType: taskType,
          intervalDays: interval,
          reminderEnabled: _reminderEnabled,
          reminderTime:
              _reminderEnabled && _reminderTimeController.text.isNotEmpty ? _reminderTimeController.text : null,
          clearReminderTime: !_reminderEnabled || _reminderTimeController.text.isEmpty,
          reminderDays: _reminderEnabled && _selectedDays.isNotEmpty ? _selectedDays : null,
          clearReminderDays: !_reminderEnabled || _selectedDays.isEmpty,
        );
      } else if (widget.existingTaskType != null) {
        // Editing a computed rule without an existing custom rule: create
        // or update the custom override for that task type.
        await widget.usecases.createOrUpdateOverride(
          plantId: widget.plantId,
          taskType: taskType,
          intervalDays: interval,
        );
        // Reminder fields for computed overrides are not part of the
        // original contract; if needed, a follow-up update could apply them.
      } else {
        await widget.usecases.create(
          plantId: widget.plantId,
          taskType: taskType,
          intervalDays: interval,
          reminderEnabled: _reminderEnabled,
          reminderTime:
              _reminderEnabled && _reminderTimeController.text.isNotEmpty ? _reminderTimeController.text : null,
          reminderDays: _reminderEnabled && _selectedDays.isNotEmpty ? _selectedDays : null,
        );
      }

      widget.onSaved?.call();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save rule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.careRulesEdit : l10n.careRulesAdd),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Task Type
            Text(
              l10n.careRulesTaskType,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(l10n.careRulesBuiltIn),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n.careRulesCustom),
                ),
              ],
              selected: {_useCustomType},
              onSelectionChanged: (selected) {
                setState(() => _useCustomType = selected.first);
              },
            ),
            const SizedBox(height: 12),
            if (!_useCustomType)
              DropdownButtonFormField<String>(
                initialValue: _selectedBuiltInType,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.careRulesSelectType,
                ),
                items: List.generate(
                  _builtInTypes.length,
                  (i) => DropdownMenuItem(
                    value: _builtInTypes[i],
                    child: Text(_builtInLabels[i]),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _selectedBuiltInType = value);
                },
                validator: (value) {
                  if (!_useCustomType && value == null) {
                    return l10n.careRulesSelectTypeRequired;
                  }
                  return null;
                },
              )
            else
              TextFormField(
                controller: _taskTypeController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.careRulesCustomType,
                  hintText: l10n.careRulesCustomTypeHint,
                ),
                validator: (value) {
                  if (_useCustomType && (value == null || value.trim().isEmpty)) {
                    return l10n.careRulesCustomTypeRequired;
                  }
                  return null;
                },
              ),
            const SizedBox(height: 24),

            // Interval
            Text(
              l10n.careRulesInterval,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.careRulesIntervalHint,
                hintText: '7',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.careRulesIntervalRequired;
                }
                final n = int.tryParse(value);
                if (n == null || n <= 0) {
                  return l10n.careRulesIntervalPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Reminder
            SwitchListTile(
              title: Text(l10n.careRulesEnableReminder),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() => _reminderEnabled = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _reminderTimeController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.careRulesEnableReminder,
                  hintText: l10n.careRulesReminderTimeHint,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.careRulesReminderDays,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _daysOfWeek.map((day) {
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3).toUpperCase()),
                    selected: selected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
