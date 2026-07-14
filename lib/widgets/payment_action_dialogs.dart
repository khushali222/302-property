import 'package:flutter/material.dart';

import '../constant/constant.dart';

/// Web-aligned dialogs for the Failed Payments actions (Reprocess / Ignore /
/// Schedule). The visuals mirror the web CRM (rounded white card, outlined
/// amber warning circle, bold navy title, muted subtitle, evenly-spaced
/// buttons). The dialogs only collect the user's choice — the calling screen
/// keeps the existing repository/API wiring.

const Color _amber = Color(0xFFF0A23C);
const Color _muted = Color(0xFF667085);
const Color _danger = Color(0xFFD92D20);
const Color _dangerBg = Color(0xFFFDECEC);
const Color _outlineBorder = Color(0xFFD0D5DD);

Widget _warningIcon() {
  return Container(
    width: 74,
    height: 74,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: _amber, width: 3),
    ),
    child: const Icon(Icons.priority_high_rounded, color: _amber, size: 38),
  );
}

Widget _dialogShell({required List<Widget> children}) {
  return Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    ),
  );
}

Widget _title(String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: blueColor),
    );

Widget _subtitle(String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, color: _muted),
    );

Widget _primaryButton(String label, VoidCallback? onTap) {
  return SizedBox(
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: blueColor.withOpacity(0.4),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
  );
}

Widget _outlineButton(String label, VoidCallback onTap) {
  return SizedBox(
    height: 48,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: blueColor,
        backgroundColor: Colors.white,
        side: const BorderSide(color: _outlineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
  );
}

Widget _dangerButton(String label, VoidCallback onTap) {
  return SizedBox(
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _dangerBg,
        foregroundColor: _danger,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ),
  );
}

/// "Reprocess Failed Payment" chooser: Cancel / Schedule / Process Now.
Future<void> showReprocessFailedPaymentDialog(
  BuildContext context, {
  required VoidCallback onSchedule,
  required VoidCallback onProcessNow,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _dialogShell(
      children: [
        _warningIcon(),
        const SizedBox(height: 20),
        _title("Reprocess Failed Payment"),
        const SizedBox(height: 8),
        _subtitle("Choose how to reprocess this payment:"),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _outlineButton("Cancel", () => Navigator.pop(ctx))),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton("Schedule", () {
                Navigator.pop(ctx);
                onSchedule();
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _primaryButton("Process Now", () {
            Navigator.pop(ctx);
            onProcessNow();
          }),
        ),
      ],
    ),
  );
}

/// "Are you sure you want to ignore this payment failure?" — Yes / No.
Future<void> showIgnorePaymentFailureDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _dialogShell(
      children: [
        _warningIcon(),
        const SizedBox(height: 20),
        _title("Are you sure you want to ignore this payment failure?"),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _outlineButton("Yes", () {
                Navigator.pop(ctx);
                onConfirm();
              }),
            ),
            const SizedBox(width: 12),
            Expanded(child: _dangerButton("No", () => Navigator.pop(ctx))),
          ],
        ),
      ],
    ),
  );
}

/// Date-picker dialog. Returns the chosen date as `yyyy-MM-dd`, or null if
/// cancelled. Used by both the failed "Schedule" flow ("Schedule Payment") and
/// the Payments "Reschedule" flow (default title).
Future<String?> showSchedulePaymentDialog(
  BuildContext context, {
  String title = "Schedule Payment",
  String message = "Pick a future date (starting tomorrow)",
  String confirmLabel = "Schedule",
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _SchedulePaymentDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    ),
  );
}

class _SchedulePaymentDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const _SchedulePaymentDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  State<_SchedulePaymentDialog> createState() => _SchedulePaymentDialogState();
}

class _SchedulePaymentDialogState extends State<_SchedulePaymentDialog> {
  String? _selected; // yyyy-MM-dd

  Future<void> _pickDate() async {
    final DateTime tomorrow =
        DateTime.now().add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(2101),
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor,
              onPrimary: Colors.white,
              onSurface: blueColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: blueColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selected = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _dialogShell(
      children: [
        _title(widget.title),
        const SizedBox(height: 8),
        _subtitle(widget.message),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _outlineBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selected ?? "YYYY-MM-DD",
                    style: TextStyle(
                      fontSize: 15,
                      color: _selected == null ? Colors.grey : blueColor,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 18, color: blueColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _primaryButton(
                widget.confirmLabel,
                _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlineButton("Cancel", () => Navigator.pop(context)),
            ),
          ],
        ),
      ],
    );
  }
}
