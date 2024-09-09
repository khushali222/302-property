import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.1.17:4000";
//String Api_url = "http://192.168.1.19:4000";
//String Api_url = "http://192.168.1.15:4000";
//String Api_url = "http://192.168.1.14:4000q";
String Api_url = "http://192.168.1.25:4000";
//String Api_url = "http://192.168.38.213:4000"



//String Api_url = "https://saas.cloudrentalmanager.com";

String image_upload_url = "https://saas.cloudrentalmanager.com";

String formatDate(String dateTime) {
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

String formatDatenew(String dateTime) {
  DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}

String formatDate4(String dateTime) {
  DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateTime);
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}

String formatDate2(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String formatDate3(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String reverseFormatDate(String formattedDate) {
  DateTime dateTime = DateFormat('dd-MM-yyyy').parse(formattedDate);
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

Color blueColor = Color.fromRGBO(21, 43, 83, 1);

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

