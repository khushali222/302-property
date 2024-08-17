import 'dart:ui';

import 'package:intl/intl.dart';

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.1.17:4000";
//String Api_url = "http://192.168.1.19:4000";
//String Api_url = "http://192.168.1.15:4000";
//String Api_url = "http://192.168.1.14:4000";
//String Api_url = "http://192.168.38.213:4000";
String Api_url = "http://192.168.1.40:4000";


//String Api_url = "https://saas.cloudrentalmanager.com";

String image_upload_url = "https://saas.cloudrentalmanager.com";

String formatDate(String dateTime) {
  return DateFormat('dd-MM-yyyy').format(DateTime.parse(dateTime));
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


