import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:zxcvbn/zxcvbn.dart';

String image_url = "https://staging.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.1.37:4000/api/images/get-file/";
//String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";

//String Api_url = "http://192.168.39.1:4000";
//String Api_url = "http://192.168.1.33:4000";

//String Api_url = "https://saas.cloudrentalmanager.com";
String Api_url = "https://staging.cloudrentalmanager.com";
//String Api_url = "https://development.cloudrentalmanager.com";

//String image_upload_url = "https://saas.cloudrentalmanager.com";
String image_upload_url = "https://staging.cloudrentalmanager.com";

// ===================== Safe JSON coercion helpers =====================
// The backend is loosely typed — the same field can arrive as a String on one
// environment and a number/bool on another (e.g. a phone number as "(555)…" on
// staging but 5551234567 on production). A direct cast like
// `String? x = json['x']` then throws a TypeError and the whole parse — and
// often the screen — dies. Use these in EVERY `fromJson` instead of casting:
//
//   name   = asStr(json['name']);      // any value -> String ("" if null)
//   active = asBool(json['active']);   // bool / 1-0 / "true" -> bool
//   count  = asInt(json['count']);     // num / "12" -> int
//   items  = asObjectList(json['items']).map(Item.fromJson).toList();

/// Any value → String. Returns [fallback] (default "") for null.
String asStr(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

/// Any value → bool. Accepts real bools, 1/0 numbers, "true"/"1"/"yes" strings.
bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }
  return fallback;
}

/// Any value → int. Handles num and numeric strings; [fallback] (default 0)
/// otherwise. Doubles are truncated.
int asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

/// Any value → double. Handles num and numeric strings; [fallback] (default 0)
/// otherwise.
double asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? fallback;
  return fallback;
}

/// Nullable, type-preserving numeric parse for model `fromJson`.
/// Keeps null as null (does NOT coerce to 0), keeps int as int and double as
/// double (so payload round-trips are unchanged), and parses a numeric String
/// to num. Use for `num?` fields so a decimal/int/string from the API can't
/// throw "type 'X' is not a subtype of type 'int?'".
num? asNumN(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

/// Nullable variants for `double?` / `int?` fields: null stays null, any present
/// value (int, double, or numeric String) is coerced safely to the field type.
double? asDoubleN(dynamic value) => value == null ? null : asDouble(value);
int? asIntN(dynamic value) => value == null ? null : asInt(value);

/// A loose value → Map<String, dynamic> (empty map if it isn't a map).
Map<String, dynamic> asObject(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

/// A loose value → list of JSON objects. Tolerates null / non-list inputs and
/// skips non-object entries, so a malformed array can't crash a parse.
List<Map<String, dynamic>> asObjectList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}
// ======================================================================

// formatDate(String dateTime) {
//   //print(dateTime);
//   List<String> dateFormats = [
//     'yyyy-MM-dd',
//     'yyyy-M-d',
//     'dd-MM-yyyy',
//     'd-M-yyyy',
//     'M/d/yyyy',
//     'MM/dd/yyyy',
//     'M/d/yyyy, h:mm:ss a',
//     'M/d/yyyy, h:mm a' // 05032024 (no separators)
//   ];
//
//   DateTime? parsedDate;
//
//   for (String format in dateFormats) {
//     //  print(dateTime);
//     try {
//       parsedDate = DateFormat(format).parse(dateTime);
//       //  print(parsedDate);
//       break;
//     } catch (e) {
//       continue;
//     }
//   }
//
//   if (parsedDate == null) {
//     return dateTime;
//     //  throw FormatException("Date format not recognized: $dateTime");
//   }
//   // print(parsedDate);
//   return DateFormat('yyyy-MM-dd').format(parsedDate);
// }

// String formatDate4(String dateTime) {
//   DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);0
//   return DateFormat('dd-MM-yyyy').format(parsedDate);
// }

formatDate(String dateTime) {
  print("formatDate input: '$dateTime'");

  // If already in correct format, return as is
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateTime.trim())) {
    print("formatDate output (already correct): '$dateTime'");
    return dateTime;
  }

  List<String> dateFormats = [
    'yyyy-MM-dd',
    'yyyy-M-d',
    'yyyy-MMM-dd', // e.g. 2025-Jan-01
    'yyyy-MMM-d', // e.g. 2025-Jan-1
    'dd-MM-yyyy',
    'd-M-yyyy',
    'd-MMM-yyyy', // e.g. 1-Jan-2025
    'dd-MMM-yyyy', // e.g. 01-Jan-2025
    'M/d/yyyy',
    'MM/dd/yyyy',
    'M/d/yyyy, h:mm:ss a',
    'M/d/yyyy, h:mm a',
    'dd/MMMM/yyyy', // e.g. 01/August/2032
    'd/MMMM/yyyy', // e.g. 1/August/2032
    'dd/MMM/yyyy', // e.g. 01/Aug/2032
    'd/MMM/yyyy', // e.g. 1/Aug/2032
  ];

  DateTime? parsedDate;

  for (String format in dateFormats) {
    try {
      parsedDate = DateFormat(format).parse(dateTime);
      print("formatDate parsed with format '$format': $parsedDate");
      break;
    } catch (e) {
      print("formatDate failed to parse '$dateTime' with format '$format': $e");
      continue;
    }
  }

  if (parsedDate == null) {
    print("formatDate failed to parse: '$dateTime'");
    return dateTime;
  }

  String result = DateFormat('yyyy-MM-dd').format(parsedDate);
  print("formatDate output: '$result'");
  return result;
}

String formatDate4(String dateTime) {
  if (dateTime.isEmpty) {
    return ""; // Handle empty or invalid date input
  }

  try {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return ""; // Return this if parsing fails
  }
}

String formatDate3(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

// String reverseFormatDate(String formattedDate) {
//   print(formattedDate);
//   DateTime dateTime = DateFormat('dd-MM-yyyy').parse(formattedDate);
//   return DateFormat('yyyy-MM-dd').format(dateTime);
// }
String reverseFormatDate(String formattedDate) {
  // Check if the formattedDate is empty or invalid
  if (formattedDate.isEmpty) {
    print("Empty date received, returning an empty string");
    return ""; // Return an empty string if the date is empty
  }

  try {
    print("reverseFormatDate input: '$formattedDate'");
    print("Input length: ${formattedDate.length}");
    print("Input bytes: ${formattedDate.codeUnits}");

    // Clean the input string - remove any extra whitespace
    String cleanDate = formattedDate.trim();

    // If the date is already in yyyy-MM-dd format, return it as is
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleanDate)) {
      print("Date is already in yyyy-MM-dd format, returning as is");
      return cleanDate;
    }

    // Special handling for yyyy-MM-dd format that might have extra characters
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(cleanDate)) {
      print("Date appears to be in yyyy-MM-dd format with extra characters");
      String extractedDate = cleanDate.substring(0, 10);
      print("Extracted date: $extractedDate");
      return extractedDate;
    }

    // List of possible date formats that DateProvider might return
    // Prioritize dd-MM-yyyy format first since it's the most common UI format
    List<String> dateFormats = [
      'dd-MM-yyyy',
      'd-M-yyyy',
      'yyyy-MM-dd',
      'yyyy-M-d',
      'MM/dd/yyyy',
      'M/d/yyyy',
      'MM-dd-yyyy',
      'M-d-yyyy',
      'dd/MM/yyyy',
      'd/M/yyyy',
      // Month-name format ("2026-Jul-29"). DateProvider sets this whenever the
      // admin picks YYYY-MMM-DD; without it the parse fell through and this
      // function returned "", sending an empty date to the API. Appended last
      // so it can only catch inputs every earlier pattern already rejected.
      'yyyy-MMM-dd',
      'yyyy-MMM-d',
    ];

    DateTime? parsedDate;

    // Try to parse the date using different formats
    for (String format in dateFormats) {
      try {
        parsedDate = DateFormat(format).parse(cleanDate);
        print("Successfully parsed with format: $format");
        print("Parsed date: $parsedDate");
        break;
      } catch (e) {
        print("Failed to parse with format $format: $e");
        continue;
      }
    }

    // If parsing failed, try manual parsing for common formats
    if (parsedDate == null) {
      print("Trying manual parsing...");
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(cleanDate)) {
        // yyyy-MM-dd format
        List<String> parts = cleanDate.split('-');
        if (parts.length == 3) {
          int year = int.tryParse(parts[0]) ?? 0;
          int month = int.tryParse(parts[1]) ?? 0;
          int day = int.tryParse(parts[2]) ?? 0;
          if (year > 0 && month > 0 && month <= 12 && day > 0 && day <= 31) {
            parsedDate = DateTime(year, month, day);
            print("Manually parsed date: $parsedDate");
          }
        }
      } else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(cleanDate)) {
        // dd-MM-yyyy format
        List<String> parts = cleanDate.split('-');
        if (parts.length == 3) {
          int day = int.tryParse(parts[0]) ?? 0;
          int month = int.tryParse(parts[1]) ?? 0;
          int year = int.tryParse(parts[2]) ?? 0;
          if (year > 0 && month > 0 && month <= 12 && day > 0 && day <= 31) {
            parsedDate = DateTime(year, month, day);
            print("Manually parsed date: $parsedDate");
          }
        }
      }
    }

    if (parsedDate == null) {
      print("Could not parse date: $formattedDate");
      return ""; // Return empty string if parsing fails
    }

    // Return the formatted date in 'yyyy-MM-dd' format for API
    String result = DateFormat('yyyy-MM-dd').format(parsedDate);
    print("reverseFormatDate output: $result");
    return result;
  } catch (e) {
    print("Error while formatting date: $e");
    return ""; // Return an empty string if there is an error
  }
}

/// Shared insurance date-range rule (web parity): the expiration date must be
/// strictly AFTER the effective date — equal dates are an error.
/// Returns an error message when the range is invalid, or null when valid.
/// Callers show the returned message themselves (toast/snackbar).
String? validateInsuranceDateRange(DateTime? effective, DateTime? expiration) {
  if (effective == null || expiration == null) {
    return "Please select both Effective Date and Expiration Date";
  }
  if (expiration.isBefore(effective) || expiration.isAtSameMomentAs(effective)) {
    return "Expiration Date must be after Effective Date";
  }
  return null;
}

Color blueColor = Color.fromRGBO(21, 43, 81, 1);
Color blueColorDisabled = blueColor.withOpacity(0.6);
//Color blueColor = Color.fromRGBO(21, 43, 70, .5);

Color greyColor = Color.fromRGBO(73, 81, 96, 1);
Color grey = Color.fromRGBO(21, 43, 83, .5);

// ===== Unified mobile palette (Work Order + shared screens) =====
const Color navyClr      = Color(0xFF1C2D4E); // primary navy
const Color navyHoverClr = Color(0xFF16243F); // pressed/hover
const Color tintBg       = Color(0xFFEEF2F8); // card header / alt row
const Color tint2        = Color(0xFFE1E9F4); // nested sub-cards
const Color pageBg       = Color(0xFFF4F6F9); // app background
const Color borderClr    = Color(0xFFE4E8EF); // outer card border
const Color innerBdClr   = Color(0xFFD8DDE6); // inner divider
const Color outlineClr   = Color(0xFFD3DAE5); // outlined button border
const Color checkOffClr  = Color(0xFFB6BFCD); // unchecked checkbox border
const Color mutedClr     = Color(0xFF6B7A90); // secondary text / labels
const Color subjectClr   = Color(0xFF5A86B8); // subject / unit accent
const Color greenClr     = Color(0xFF1F9D55); // success / New / Completed
const Color greenBg      = Color(0xFFDCFCE7); // green pill bgR
const Color orangeClr    = Color(0xFFD97706); // in-progress / charge
const Color orangeBg     = Color(0xFFFEF3C7); // orange pill bg
const Color statusBlue   = Color(0xFF2868A0); // New status / view icon
const Color statusBlueBg = Color(0xFFE8F0FA); // view button bg
const Color closedClr    = Color(0xFF6B7A90); // closed status
const Color redClr       = Color(0xFFDC3545); // delete / error
const Color redDotClr    = Color(0xFFE62E2E); // notification dot
TableRow buildTableRow(
    String leftLabel, String leftValue, String rightLabel, String rightValue) {
  return TableRow(
    children: [
      TableCell(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
              ),
              SizedBox(height: 4.0), // Space between label and value
              Text(
                leftValue,
                style: TextStyle(color: grey),
              ),
            ],
          ),
        ),
      ),
      TableCell(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rightLabel,
                style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
              ),
              SizedBox(height: 4.0), // Space between label and value
              Text(
                rightValue,
                style: TextStyle(color: grey),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

String getDisplayValue(String? value) {
  // Return 'N/A' if the value is null or empty, otherwise return the value
  return (value == null || value.trim().isEmpty) ? 'N/A' : value;
}

// Common currency formatting function for US-centric format
String formatCurrency(double? amount) {
  if (amount == null) return '\$0.00';

  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  return formatter.format(amount);
}
//Color grey = Color.fromRGBO(21, 43, 83, .5);
//Color grey = Color.fromRGBO(21, 43, 83, .5);

String formatPhoneNumber(String phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    return "N/A"; // Return "N/A" if the phone number is null or empty
  }
  // Remove any non-digit characters
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Check if the number has the right length (10 digits for US phone numbers)
  if (digitsOnly.length == 10) {
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else {
    return phoneNumber; // Return original if not valid
  }
}

String formatPhoneNumberedit(String phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    return ""; // Return "N/A" if the phone number is null or empty
  }
  // Remove any non-digit characters
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Check if the number has the right length (10 digits for US phone numbers)
  if (digitsOnly.length == 10) {
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else {
    return phoneNumber; // Return original if not valid
  }
}

// void _checkPasswordStrength(String password) {
//   final result = Zxcvbn().evaluate(password);
//   setState(() {
//     // Safely convert the score to an int, defaulting to 0 if null
//     _score = result.score?.toInt() ?? 0;
//     // Provide a default feedback message if the warning is null
//     _feedback = (result.feedback.warning!.isNotEmpty ? result.feedback.warning : 'Password is strong!')!;
//   });
// }
// bool _validatePassword(String password) {
//   if (password.length < 8 || password.length > 16) {
//     _errorMessage = 'Password must be between 8 and 16 characters.';
//     return false;
//   }
//   if (!RegExp(r'[A-Z]').hasMatch(password)) {
//     _errorMessage = 'Must contain at least one uppercase letter.';
//     return false;
//   }
//   if (!RegExp(r'[a-z]').hasMatch(password)) {
//     _errorMessage = 'Must contain at least one lowercase letter.';
//     return false;
//   }
//   if (!RegExp(r'[0-9]').hasMatch(password)) {
//     _errorMessage = 'Must contain at least one digit.';
//     return false;
//   }
//   if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
//     _errorMessage = 'Must contain at least one special character.';
//     return false;
//   }
//   var result = Zxcvbn().evaluate(password);
//   print(result.score);
//   if (result.score! < 3) {
//     _errorMessage = 'Password is too weak.';
//     return false;
//   }
//   if (RegExp(r'(\d)\1{2,}|\d{3,}|[A-Za-z]{3,}').hasMatch(password)) {
//     _errorMessage = 'Avoid sequential or repeating patterns.';
//     return false;
//   }
//   _errorMessage = null; // Reset error message if all checks pass
//   return true;
// }

String? ValidatePassword(String password) {
  if (password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Must contain at least one uppercase letter.';
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Must contain at least one lowercase letter.';
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'Must contain at least one digit.';
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    return 'Must contain at least one special character.';
  }

  // Avoid sequential or repeating patterns
  // if (RegExp(r'(\d)\1{2,}|[A-Za-z]{4,}|\d{4,}').hasMatch(password)) {
  //   return 'Avoid sequential or excessive repeating patterns.';
  // }

  // Simulated strength check: length-based and diversity
  if (password.length < 12) {
    return 'Password is too weak. Use a longer password.';
  }

  return null; // Indicate the password is valid
}

String generateRandomPassword() {
  const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowerCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
  const String digits = '0123456789';
  const String specialCharacters = '!@#\$%^&*(),.?":{}|<>';
  const String allCharacters =
      '$upperCaseLetters$lowerCaseLetters$digits$specialCharacters';

  // Ensure at least one of each required character type
  List<String> passwordChars = [];
  passwordChars
      .add(upperCaseLetters[Random().nextInt(upperCaseLetters.length)]);
  passwordChars
      .add(lowerCaseLetters[Random().nextInt(lowerCaseLetters.length)]);
  passwordChars.add(digits[Random().nextInt(digits.length)]);
  passwordChars
      .add(specialCharacters[Random().nextInt(specialCharacters.length)]);

  // Fill the rest of the password with random characters
  int remainingLength = Random().nextInt(5) + 8; // Ensure total length is 12-16
  for (int i = 0; i < remainingLength; i++) {
    passwordChars.add(allCharacters[Random().nextInt(allCharacters.length)]);
  }

  // Shuffle to ensure randomness
  passwordChars.shuffle();

  // Join characters into a password string
  String password = passwordChars.join('');

  // Ensure no sequential or repeating patterns
  if (RegExp(r'(\d)\1{2,}|[A-Za-z]{4,}|\d{4,}').hasMatch(password)) {
    return generateRandomPassword(); // Retry if invalid pattern is found
  }

  return password;
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove any non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Check if the number has the right length (10 digits for US phone numbers)
    if (digitsOnly.length > 10) {
      return oldValue; // Return old value if the new input exceeds 10 digits
    }

    String formatted = '';
    if (digitsOnly.length >= 1) {
      formatted +=
          '(${digitsOnly.substring(0, digitsOnly.length >= 3 ? 3 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 4) {
      formatted +=
          ') ${digitsOnly.substring(3, digitsOnly.length >= 6 ? 6 : digitsOnly.length)}';
    }
    if (digitsOnly.length >= 7) {
      formatted += '-${digitsOnly.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CVVFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Restrict to 3 digits maximum
    if (digitsOnly.length > 3) {
      return oldValue;
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Restricts input to a 0–100 percentage. Web parity for the Debit Card Fee
/// Override field: mirrors the web onChange gate — accepts only an empty value,
/// or digits with a single optional decimal point whose numeric value is
/// between 0 and 100 (inclusive). Any keystroke that would fall outside that
/// range (or isn't numeric) is rejected, so out-of-range values can't be typed.
class PercentRangeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    // Allow clearing the field.
    if (text.isEmpty) return newValue;
    // Only digits with at most one decimal point (web regex: /^\d*\.?\d*$/).
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    // Reject values that don't parse (e.g. a lone ".") — matches web parseFloat.
    final parsed = double.tryParse(text);
    if (parsed == null) return oldValue;
    // Range 0–100 inclusive (web: parseFloat(value) >= 0 && <= 100).
    if (parsed < 0 || parsed > 100) return oldValue;
    return newValue;
  }
}

String? ValidateExpirationDate(String expirationDate) {
  // Check if the date is in the correct MM/YYYY format
  //require formate first is 0-9 and second 0-2
  final regex = RegExp(r'^(0[1-9]|1[0-9])\/\d{4}$');
  if (!regex.hasMatch(expirationDate)) {
    return 'Expiration date must be in the format MM/YYYY.';
  }

  // Split the date into month and year
  final parts = expirationDate.split('/');
  final month = int.parse(parts[0]);
  final year = int.parse(parts[1]);

  // Validate that the month is between 01 and 12
  if (month < 1 || month > 12) {
    return 'Month must be between 01 and 12.';
  }

  // Get the current date and the expiration date
  final currentDate = DateTime.now();
  final expirationDateTime = DateTime(year, month);

  // Check if the expiration date is in the past
  if (expirationDateTime.isBefore(currentDate)) {
    return 'Expiration date cannot be in the past.';
  }

  // Check if the expiration date is too far in the future (e.g., 10 years from now)
  final maxDate = currentDate.add(Duration(days: 365 * 10)); // 10 years
  if (expirationDateTime.isAfter(maxDate)) {
    return 'Expiration date cannot be more than 10 years in the future.';
  }

  // Ensure the expiration year is not before the current year
  final minYear = currentDate.year;
  if (year < minYear) {
    return 'Expiration year must be greater than or equal to the current year.';
  }

  return null; // Indicate the expiration date is valid
}

class VideoItem extends StatefulWidget {
  String url;
  final void Function()? onTap;
  VideoItem({super.key, required this.url, this.onTap});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network("${widget.url}")
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller!.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: _controller!.value!.isInitialized
              ? Container(
                  width: 100.0,
                  height: 56.0,
                  child: VideoPlayer(_controller!),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class CustomTableView extends StatelessWidget {
  final List<String> titles;
  final List<List<String>> data;
  final bool isHeader;
  final Map<int, TableColumnWidth> columnWidths;
  final String description;
  final bool showDescription; // Boolean to control visibility

  CustomTableView({
    required this.titles,
    required this.data,
    required this.isHeader,
    required this.columnWidths,
    required this.description,
    this.showDescription = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          columnWidths: columnWidths,
          children: [
            if (isHeader)
              TableRow(
                decoration: BoxDecoration(color: Color.fromRGBO(21, 43, 83, 1)),
                children: titles
                    .map((item) => Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 9, horizontal: 1),
                          child: Text(
                            item,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
            ...data.asMap().entries.map(
              (entry) {
                int index = entry.key;
                List<String> row = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.grey[300] // Light grey for even rows
                        : Colors.white, // White for odd rows
                  ),
                  children: row
                      .map(
                        (cell) => Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 6),
                          child: Text(
                            cell,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
        if (showDescription) // Show description only if true
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, bottom: 5),
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }
}
