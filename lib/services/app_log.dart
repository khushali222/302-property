import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only error logging.
///
/// Use this instead of `print()` inside `catch` blocks. In release builds it is
/// a no-op, so nothing an error message happens to carry — ids, payload
/// fragments, API responses — can reach the device log where `adb logcat` or a
/// crash reporter could pick it up.
///
/// ```dart
/// } catch (e) {
///   logError('Failed to load charges: $e');
/// }
/// ```
///
/// Note this does not make the failure visible to the user. If the failure is
/// something they triggered, also surface it (toast/snackbar) and leave the
/// screen recoverable.
void logError(Object? message, [Object? error, StackTrace? stackTrace]) {
  if (!kDebugMode) return;
  developer.log('$message', name: 'CRM', error: error, stackTrace: stackTrace);
}
