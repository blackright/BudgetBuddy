import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../../../shared/presentation/modals/app_date_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../shared/presentation/time_picker_dialogs.dart';
import 'medical_sheet_header.dart';

class ReminderPickerSheet extends StatefulWidget {
  const ReminderPickerSheet({
    super.key,
    this.initialDate,
    this.allowClear = false,
  });

  final DateTime? initialDate;

  /// When true, the sheet offers "No reminder" and pops [cleared].
  final bool allowClear;

  /// Sentinel value meaning "remove the reminder"; `null` from [show] still
  /// means the sheet was dismissed without a choice.
  static final DateTime cleared = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    bool allowClear = false,
  }) {
    return showAppSheet<DateTime>(
      context,
      isScrollControlled: true,
      builder: (context) =>
          ReminderPickerSheet(initialDate: initialDate, allowClear: allowClear),
    );
  }

  @override
  State<ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<ReminderPickerSheet> {
  late DateTime _selectedDate;
  Timer? _ticker;
  late DateTime _floor;

  @override
  void initState() {
    super.initState();
    _floor = DateTime.now().add(const Duration(minutes: 30));
    _selectedDate = widget.initialDate ?? _defaultSuggestion();

    if (_selectedDate.isBefore(_floor)) {
      _selectedDate = _floor;
    }

    // Tick every 15 seconds to move the floor forward
    _ticker = Timer.periodic(const Duration(seconds: 15), (timer) {
      final newFloor = DateTime.now().add(const Duration(minutes: 30));
      setState(() {
        _floor = newFloor;
        if (_selectedDate.isBefore(_floor)) {
          _selectedDate = _floor;
          HapticFeedback.lightImpact();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime _defaultSuggestion() {
    final now = DateTime.now();
    final target = now.add(const Duration(days: 3));
    return DateTime(target.year, target.month, target.day, 9);
  }

  void _onConfirm() {
    final currentFloor = DateTime.now().add(const Duration(minutes: 30));
    if (_selectedDate.isBefore(currentFloor)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Time adjusted to the earliest allowed (30 min from now).')),
      );
      setState(() {
        _selectedDate = currentFloor;
      });
      return;
    }
    Navigator.of(context).pop(_selectedDate);
  }

  void _setPreset(Duration duration) {
    var date = DateTime.now().add(duration);
    var minutes = date.minute;
    var nextHalfHour = (minutes < 30) ? 30 : 60;
    date = DateTime(date.year, date.month, date.day, date.hour)
        .add(Duration(minutes: nextHalfHour));

    if (date.isBefore(_floor)) {
      date = _floor;
    }
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSheetHeader(
              title: 'Follow-up reminder',
              subtitle: 'Choose when to revisit this bill.',
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Tomorrow'),
                  onPressed: () => _setPreset(const Duration(days: 1)),
                ),
                ActionChip(
                  label: const Text('In 3 days'),
                  onPressed: () => _setPreset(const Duration(days: 3)),
                ),
                ActionChip(
                  label: const Text('In 1 week'),
                  onPressed: () => _setPreset(const Duration(days: 7)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              trailing: Text(DateFormat.yMMMd().format(_selectedDate)),
              onTap: () async {
                final date = await showAppDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime
                      .now(), // Use today as firstDate, floor handles specific time
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedDate.hour,
                      _selectedDate.minute,
                    );
                    if (_selectedDate.isBefore(_floor)) {
                      _selectedDate = _floor;
                    }
                  });
                }
              },
            ),
            ListTile(
              title: const Text('Time'),
              trailing: Text(DateFormat.jm().format(_selectedDate)),
              onTap: () async {
                final time = await showSafeTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate),
                );
                if (time != null) {
                  setState(() {
                    var newDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      time.hour,
                      time.minute,
                    );
                    if (newDate.isBefore(_floor)) {
                      newDate = _floor;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot select past time.')),
                      );
                    }
                    _selectedDate = newDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              onPressed: _onConfirm,
              child: const Text('Save reminder'),
            ),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep unchanged'),
            ),
            if (widget.allowClear)
              TextButton.icon(
                key: const Key('noReminderAction'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () =>
                    Navigator.of(context).pop(ReminderPickerSheet.cleared),
                icon: const Icon(Icons.notifications_off_outlined),
                label: const Text('No reminder'),
              ),
          ],
        ),
      )),
    );
  }
}
