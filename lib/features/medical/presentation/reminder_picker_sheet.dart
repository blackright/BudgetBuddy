import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../shared/presentation/time_picker_dialogs.dart';

class ReminderPickerSheet extends StatefulWidget {
  const ReminderPickerSheet({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  static Future<DateTime?> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ReminderPickerSheet(initialDate: initialDate),
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
    final in14Days = now.add(const Duration(days: 14));
    // next half hour mark
    var minutes = in14Days.minute;
    var nextHalfHour = (minutes < 30) ? 30 : 60;
    return DateTime(
      in14Days.year,
      in14Days.month,
      in14Days.day,
      in14Days.hour,
    ).add(Duration(minutes: nextHalfHour));
  }

  void _onConfirm() {
    final currentFloor = DateTime.now().add(const Duration(minutes: 30));
    if (_selectedDate.isBefore(currentFloor)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time adjusted to the earliest allowed (30 min from now).')),
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
    date = DateTime(date.year, date.month, date.day, date.hour).add(Duration(minutes: nextHalfHour));
    
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
            Text('Follow-up Reminder', style: Theme.of(context).textTheme.titleLarge),
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
                  label: const Text('Next week'),
                  onPressed: () => _setPreset(const Duration(days: 7)),
                ),
                ActionChip(
                  label: const Text('In 2 weeks'),
                  onPressed: () => _setPreset(const Duration(days: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              trailing: Text(DateFormat.yMMMd().format(_selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(), // Use today as firstDate, floor handles specific time
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      date.year, date.month, date.day,
                      _selectedDate.hour, _selectedDate.minute,
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
                      _selectedDate.year, _selectedDate.month, _selectedDate.day,
                      time.hour, time.minute,
                    );
                    if (newDate.isBefore(_floor)) {
                      newDate = _floor;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot select past time.')),
                      );
                    }
                    _selectedDate = newDate;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _onConfirm,
              child: const Text('Save'),
            ),
          ],
        ),
      )),
    );
  }
}
