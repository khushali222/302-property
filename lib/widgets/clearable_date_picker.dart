import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';

/// Result of [showClearableDatePicker]:
/// - `picked`  → the user confirmed a date (`date` is non-null)
/// - `clear`   → the user tapped Clear (the field must be blanked)
/// - a `null` Future result → the user cancelled (keep the old value)
class ClearableDatePickerResult {
  final DateTime? date;
  final bool cleared;

  const ClearableDatePickerResult.picked(DateTime this.date) : cleared = false;

  const ClearableDatePickerResult.clear()
      : date = null,
        cleared = true;
}

/// Drop-in replacement for [showDatePicker] on OPTIONAL date fields: the same
/// navy-themed Material calendar, with a "Clear" action inside the dialog
/// (web parity: the browser-native date input popup offers Clear).
Future<ClearableDatePickerResult?> showClearableDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String helpText = 'Select date',
}) {
  return showDialog<ClearableDatePickerResult>(
    context: context,
    builder: (context) => _ClearableDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    ),
  );
}

class _ClearableDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String helpText;

  const _ClearableDatePickerDialog({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.helpText,
  }) : super(key: key);

  @override
  State<_ClearableDatePickerDialog> createState() =>
      _ClearableDatePickerDialogState();
}

class _ClearableDatePickerDialogState
    extends State<_ClearableDatePickerDialog> {
  late DateTime _selected;
  bool _inputMode = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clamp so an out-of-range initial date never crashes the calendar
    // (e.g. end-date pickers where firstDate is a future start date).
    _selected = widget.initialDate;
    if (_selected.isBefore(widget.firstDate)) _selected = widget.firstDate;
    if (_selected.isAfter(widget.lastDate)) _selected = widget.lastDate;
  }

  void _confirm() {
    if (_inputMode) {
      final form = _formKey.currentState;
      if (form == null || !form.validate()) return;
      form.save();
    }
    Navigator.of(context)
        .pop(ClearableDatePickerResult.picked(_selected));
  }

  ButtonStyle get _filledNavy => TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: blueColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 328),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: blueColor,
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.helpText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('EEE, MMM d').format(_selected),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _inputMode
                              ? 'Switch to calendar'
                              : 'Switch to input',
                          icon: Icon(
                            _inputMode
                                ? Icons.calendar_today_outlined
                                : Icons.edit_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _inputMode = !_inputMode),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Match the look the old showDatePicker builders produced
              // (ThemeData.light + navy colorScheme) for the calendar body.
              Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: blueColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: _inputMode
                    ? Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Form(
                          key: _formKey,
                          child: InputDatePickerFormField(
                            initialDate: _selected,
                            firstDate: widget.firstDate,
                            lastDate: widget.lastDate,
                            autofocus: true,
                            onDateSaved: (date) => _selected = date,
                            onDateSubmitted: (date) {
                              _selected = date;
                            },
                          ),
                        ),
                      )
                    : CalendarDatePicker(
                        initialDate: _selected,
                        firstDate: widget.firstDate,
                        lastDate: widget.lastDate,
                        onDateChanged: (date) =>
                            setState(() => _selected = date),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pop(const ClearableDatePickerResult.clear()),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: _filledNavy,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: _filledNavy,
                      onPressed: _confirm,
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
