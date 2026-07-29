import 'package:flutter/material.dart';

/// Suffix for read-only date fields: a calendar icon that opens the picker
/// plus an "X" that clears the selected date. The "X" is only shown while
/// the field has a value (web parity: the browser-native date input offers
/// a Clear action). Use only on fields whose date is optional to submit.
class ClearableDateSuffix extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPick;

  /// Called when the "X" is tapped. Defaults to clearing [controller].
  /// Pass a callback when extra state (e.g. a backing DateTime) must reset.
  final VoidCallback? onClear;

  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  const ClearableDateSuffix({
    Key? key,
    required this.controller,
    required this.onPick,
    this.onClear,
    this.icon = Icons.calendar_today_outlined,
    this.iconColor,
    this.iconSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value.text.isNotEmpty)
              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear date',
                icon: Icon(Icons.close,
                    size: iconSize, color: iconColor ?? Colors.grey),
                onPressed: onClear ?? controller.clear,
              ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              visualDensity: VisualDensity.compact,
              icon: Icon(icon, size: iconSize, color: iconColor),
              onPressed: onPick,
            ),
          ],
        );
      },
    );
  }
}
