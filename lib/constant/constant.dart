import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:zxcvbn/zxcvbn.dart';

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.39.1:4000";
String Api_url = "http://192.168.1.18:4000";

//String Api_url = "https://saas.cloudrentalmanager.com";

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
    'M/d/yyyy, h:mm a'        // 05032024 (no separators)
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



String formatDate4(String dateTime) {
  DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}


String formatDate3(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String reverseFormatDate(String formattedDate) {
  print(formattedDate);
  DateTime dateTime = DateFormat('dd-MM-yyyy').parse(formattedDate);
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

 Color blueColor = Color.fromRGBO(21, 43, 81, 1);
//Color blueColor = Color.fromRGBO(21, 43, 70, .5);

Color greyColor = Color.fromRGBO(73, 81, 96, 1);
Color grey = Color.fromRGBO(21, 43, 83, .5);
TableRow buildTableRow(String leftLabel, String leftValue, String rightLabel, String rightValue) {
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

  var result = Zxcvbn().evaluate(password);
  if (result.score! < 3) {
    return 'Password is too weak.';
  }
  if (RegExp(r'(\d)\1{2,}|\d{3,}|[A-Za-z]{3,}').hasMatch(password)) {
    return 'Avoid sequential or repeating patterns.';
  }

  return null; // Indicate that the password is valid
}

