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

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.39.1:4000";
//String Api_url = "http://192.168.1.8:4000";

//String Api_url = "https://saas.cloudrentalmanager.com";
String Api_url = "https://staging.cloudrentalmanager.com";

String image_upload_url = "https://saas.cloudrentalmanager.com";

formatDate(String dateTime) {
  //print(dateTime);
  List<String> dateFormats = [
    'yyyy-MM-dd',
    'yyyy-M-d',
    'dd-MM-yyyy',
    'd-M-yyyy',
    'M/d/yyyy',
    'MM/dd/yyyy',
    'M/d/yyyy, h:mm:ss a',
    'M/d/yyyy, h:mm a' // 05032024 (no separators)
  ];

  DateTime? parsedDate;

  for (String format in dateFormats) {
    //  print(dateTime);
    try {
      parsedDate = DateFormat(format).parse(dateTime);
      //  print(parsedDate);
      break;
    } catch (e) {
      continue;
    }
  }

  if (parsedDate == null) {
    return dateTime;
    //  throw FormatException("Date format not recognized: $dateTime");
  }
  // print(parsedDate);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}

// String formatDate4(String dateTime) {
//   DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);0
//   return DateFormat('dd-MM-yyyy').format(parsedDate);
// }

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
    print(formattedDate);
    // Try parsing the date
    DateTime dateTime = DateFormat('dd-MM-yyyy').parse(formattedDate);
    // Return the formatted date in 'yyyy-MM-dd' format
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    print("Error while formatting date: $e");
    return ""; // Return an empty string if there is an error
  }
}

Color blueColor = Color.fromRGBO(21, 43, 81, 1);
Color blueColorDisabled = blueColor.withOpacity(0.6);
//Color blueColor = Color.fromRGBO(21, 43, 70, .5);

Color greyColor = Color.fromRGBO(73, 81, 96, 1);
Color grey = Color.fromRGBO(21, 43, 83, .5);
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
  if (password.length < 8 || password.length > 16) {
    return 'Password must be between 8 and 16 characters.';
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
                  padding: EdgeInsets.symmetric(vertical: 9,horizontal: 1),
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
                      padding: EdgeInsets.symmetric(vertical: 7,horizontal: 6),
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
            padding: const EdgeInsets.only(top: 8.0,left: 8,bottom: 5),
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }
}





