import 'dart:ui';

import 'package:intl/intl.dart';

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.1.17:4000";
//String Api_url = "http://192.168.1.19:4000";
//String Api_url = "http://192.168.1.15:4000";
//String Api_url = "http://192.168.1.14:4000";
//String Api_url = "http://192.168.1.40:4000";
//String Api_url = "http://192.168.38.213:4000";

String Api_url = "https://saas.cloudrentalmanager.com";

String image_upload_url = "https://saas.cloudrentalmanager.com";

String formatDate(String dateTime) {
  List<String> dateFormats = [
    // Common date formats
    'dd-MM-yyyy',         // 31-12-2024
    'd-M-yyyy',           // 5-3-2024
    'yyyy-MM-dd',         // 2024-12-31
    'yyyy-M-d',           // 2024-3-5
    'MM/dd/yyyy',         // 12/31/2024
    'M/d/yyyy',           // 3/5/2024
    'd/M/yyyy',           // 5/3/2024
    'MM/dd/yy',           // 12/31/24
    'M/d/yy',             // 3/5/24
    'd-M-yy',             // 5-3-24
    'dd-MM-yy',           // 05-03-24
    'dd/MM/yyyy',         // 05/03/2024
    'd/M/yy',             // 5/3/24
    'MM-dd-yyyy',         // 03-05-2024
    'yyyy/MM/dd',         // 2024/05/03

    // Date with time formats
    'd/M/yyyy, h:mm a',   // 5/3/2024, 3:55 PM
    'M/d/yyyy, h:mm:ss a',// 5/3/2024, 3:55:28 PM
    'yyyy-MM-dd HH:mm:ss',// 2024-05-03 15:55:28
    'yyyy-MM-dd hh:mm:ss a',// 2024-05-03 03:55:28 PM
    'MM/dd/yyyy, hh:mm a',// 03/05/2024, 03:55 PM
    'yyyy-MM-ddTHH:mm:ss',// 2024-05-03T15:55:28 (ISO 8601)

    // Full date and time formats
    'EEE, d MMM yyyy HH:mm:ss Z', // Tue, 5 May 2024 15:55:28 +0000
    'EEEE, MMMM d, yyyy',         // Tuesday, May 5, 2024
    'd MMM yyyy',                 // 5 May 2024
    'dd MMM yyyy',                // 05 May 2024
    'yyyyMMdd',                   // 20240503 (no separators)
    'ddMMyyyy',                   // 05032024 (no separators)
  ];


  DateTime? parsedDate;

  for (String format in dateFormats) {
    try {
      parsedDate = DateFormat(format).parse(dateTime);
      break;
    } catch (e) {
      continue;
    }
  }

  if (parsedDate == null) {
    return dateTime;
  //  throw FormatException("Date format not recognized: $dateTime");
  }

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
  return dateTime.toIso8601String();
}

Color blueColor = Color.fromRGBO(21, 43, 83, 1);

Color greyColor = Color.fromRGBO(73, 81, 96, 1);


