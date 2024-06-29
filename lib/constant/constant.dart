import 'dart:ui';

import 'package:intl/intl.dart';

String image_url = "https://saas.cloudrentalmanager.com/api/images/get-file/";
//String image_url = "http://192.168.182.128:4000/api/images/get-file/";

//String Api_url = "http://192.168.1.17:4000";
//String Api_url = "http://192.168.1.19:4000";
String Api_url = "http://192.168.1.15:4000";
//String Api_url = "http://192.168.149.213:4000";

//String Api_url = "https://saas.cloudrentalmanager.com";

String formatDate(String dateTime) {
  return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateTime));
}

String formatDate2(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

Color blueColor = Color.fromRGBO(21, 43, 83, 1);
