/// Safe JSON number parsing for model `fromJson` factories.
///
/// The API is JavaScript/Mongo backed, so the same field can arrive in more
/// than one shape across responses:
///   * `5`        -> Dart `int`
///   * `5.0`      -> Dart `double`
///   * `"5.00"`   -> Dart `String` (common when a value was posted from a form)
///   * missing/`null`
///
/// A direct cast only accepts one of those, so `json['amount'] as double`
/// throws a `TypeError` the moment the value comes back as an int or a string.
/// Inside `fromJson` that error propagates out of the list parse, the
/// FutureBuilder reports `hasError`, and the screen renders red (debug) or
/// blank (release) with no rows at all — one unexpected value takes the whole
/// table down.
///
/// These helpers accept every shape above and return null when the value is
/// missing or genuinely not a number, so a single bad field degrades to an
/// empty cell instead of an empty screen.
library;

/// Numeric value of [value] as a double, or null when it isn't a number.
double? asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final String raw = value.trim();
    if (raw.isEmpty) return null;
    // Currency-ish strings ("$1,200.00") still carry a usable number.
    return double.tryParse(raw.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  }
  return null;
}

/// Numeric value of [value] as an int, or null when it isn't a number.
/// A fractional value is truncated, matching `num.toInt()`.
int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) {
    final String raw = value.trim();
    if (raw.isEmpty) return null;
    final int? direct = int.tryParse(raw);
    if (direct != null) return direct;
    return double.tryParse(raw.replaceAll(RegExp(r'[^0-9.\-]'), ''))?.toInt();
  }
  return null;
}

/// As [asDoubleOrNull] but falling back to [fallback] (0 by default) so
/// non-nullable fields keep a usable value.
double asDouble(dynamic value, [double fallback = 0]) =>
    asDoubleOrNull(value) ?? fallback;

/// As [asIntOrNull] but falling back to [fallback] (0 by default).
int asInt(dynamic value, [int fallback = 0]) => asIntOrNull(value) ?? fallback;
