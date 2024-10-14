// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import '../constant/constant.dart';
//
// class DateProvider with ChangeNotifier {
//   DateTime _currentDate = DateTime.now();
//   String _dateFormat = 'MM-dd-yyyy';
//   int dateformateselect = 0;// default date format
//
//   DateTime get currentDate => _currentDate;
//   String get dateFormat => _dateFormat;
//   int get _dateformateselect => dateformateselect;
//
//   DateProvider() {
//    _loadDateFormat();
//   }
//
//
//   // Future<void> _loadDateFormat() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final dateFormat = prefs.getString('dateFormat');
//   //   final _dateformateselect = prefs.getInt('dateformateselect');
//   //
//   //   if (dateFormat != null && _dateformateselect != null) {
//   //     _dateFormat = dateFormat;
//   //     dateformateselect = _dateformateselect;
//   //   }
//   // }
//
//   Future<void> _loadDateFormat() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? id = prefs.getString("adminId");
//     String? token = prefs.getString('token');
//    //  final response = await http.post(
//    //    Uri.parse('${Api_url}/api/themes/date-format'),
//    //    headers: {
//    //      "authorization": "CRM $token",
//    //      "id": "CRM $id",
//    //    },
//    //    body: jsonEncode({
//    //      'admin_id': id,
//    //    }),
//    //  );
//    // print('date formate ${response.body}');
//    //  var responseData = json.decode(response.body);
//    //  if (responseData["statusCode"] == 200) {
//    //    final jsonData = jsonDecode(response.body);
//    //
//    //    _dateFormat = jsonData['format'].toString();
//    //   // dateformateselect = jsonData['formatIndex'];
//    //    dateformateselect = _dateformateselect;
//    //    checkToken(jsonData["token"]);
//    //    notifyListeners();
//    //  } else {
//    //
//    //  }
//     checkToken(token!);
//   }
//
//   Future<void> _saveDateFormat() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? id = prefs.getString("adminId");
//     String? token = prefs.getString('token');
//     final response = await http.post(
//       Uri.parse('${Api_url}/api/themes/date-format'),
//       headers: {
//         "authorization": "CRM $token",
//         "id": "CRM $id",
//       },
//       body: jsonEncode({
//         'format': _dateFormat,
//         'admin_id': id,
//       }),
//     );
//
//     if (response.statusCode != 200) {
//       final jsonData = jsonDecode(response.body);
//       // checkToken(jsonData["token"]);
//      print("hello");
//     }else{
//       final jsonData = jsonDecode(response.body);
//       checkToken(jsonData["token"]);
//     }
//   }
//
//   // Future<void> _saveDateFormat() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.setString('dateFormat', _dateFormat);
//   //   await prefs.setInt('dateformateselect', dateformateselect);
//   // }
//
//   void updateDateFormat(String newFormat,selectindex) {
//     _dateFormat = newFormat;
//     dateformateselect = selectindex;
//     _saveDateFormat();
//     print(_dateFormat);
//     notifyListeners();
//   }
//
//   String formatCurrentDate(String dateTime) {
//
//       //print(dateTime);
//       List<String> dateFormats = [
//         'yyyy-MM-dd',
//         'yyyy-M-d',
//         'dd-MM-yyyy',
//         'd-M-yyyy',
//         'M/d/yyyy',
//         'MM/dd/yyyy',
//         'M/d/yyyy, h:mm:ss a',
//         'M/d/yyyy, h:mm a'        // 05032024 (no separators)
//       ];
//
//       DateTime? parsedDate;
//
//       for (String format in dateFormats) {
//         //  print(dateTime);
//         try {
//           parsedDate = DateFormat(format).parse(dateTime);
//           //  print(parsedDate);
//           break;
//         } catch (e) {
//           continue;
//         }
//       }
//
//       if (parsedDate == null) {
//         return dateTime;
//         //  throw FormatException("Date format not recognized: $dateTime");
//       }
//       // print(parsedDate);
//
//
//     return DateFormat(_dateFormat).format(parsedDate);
//   }
//
//   Future<void> checkToken(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final adminId = prefs.getString("adminId");
//
//       final response = await http.post(
//         Uri.parse('${Api_url}/api/auth'),
//         headers: {
//           "authorization": "CRM $token",
//           "id": "CRM $adminId",
//           "Content-Type": "application/json"
//         },
//         body: json.encode({"token": token}),
//       );
//         print(' token ${response.body}');
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (jsonData["statusCode"] == 200) {
//
//           _dateFormat = jsonData['format'].toString();
//           dateformateselect = _dateformateselect;
//           notifyListeners();
//         } else {
//
//         }
//       } else {
//
//       }
//     } catch (e) {
//
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constant/constant.dart';

class DateProvider with ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  String _dateFormat = 'MM-DD-YYYY';
  int dateformateselect = 0; // default date format

  DateTime get currentDate => _currentDate;
  String get dateFormat => _dateFormat;
  int get _dateformateselect => dateformateselect;
  DateProvider() {
    _loadDateFormat();
    //_loadSelectedDateFormat();
  }

  Future<void> _loadDateFormat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    if (token != null) {
      await checkToken(token);
    } else {
      // If no token, set to default
      _dateFormat = 'MM-dd-yyyy';
      dateformateselect = 0;
      notifyListeners();
    }
  }

  Future<void> _saveDateFormat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(_dateFormat);
    if (token != null) {
      final response = await http.post(
        Uri.parse('${Api_url}/api/themes/date-format'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          'format': _dateFormat,
          'admin_id': id,
        }),
      );
      print(jsonEncode({
        'format': _dateFormat,
        'admin_id': id,
      }));
      print(response.body);
      if (response.statusCode != 200) {
        // Handle error
        print("Failed to save date format.");
      } else {
        final jsonData = jsonDecode(response.body);
        await checkToken(jsonData["token"]);
      }
    }
  }

  void updateDateFormat(String newFormat,  selectIndex) {
    print(newFormat);
    _dateFormat = newFormat;
    dateformateselect = selectIndex;
    _saveDateFormat();
    _saveSelectedDateFormat();
    notifyListeners();
  }

  String formatCurrentDate(String dateTime) {
    List<String> dateFormats = [
      'yyyy-MM-dd',
      'yyyy-M-d',
      'dd-MM-yyyy',
      'd-M-yyyy',
      'M/d/yyyy',
      'MM/dd/yyyy',
      'M/d/yyyy, h:mm:ss a',
      'M/d/yyyy, h:mm a'
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
      return dateTime; // Return original if parsing fails
    }

    return DateFormat(_dateFormat).format(parsedDate);
  }

  Future<void> checkToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString("adminId");

      final response = await http.post(
        Uri.parse('${Api_url}/api/auth'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
          "Content-Type": "application/json"
        },
        body: json.encode({"token": token}),
      );
      print("date formate calling ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 200) {
          _dateFormat = jsonData['format'].toString();
          dateformateselect = _dateformateselect;
         // _loadSelectedDateFormat();
          notifyListeners();
        } else {
          // Handle invalid token case
          _dateFormat = 'MM-dd-yyyy'; // Reset to default
          dateformateselect = 0;
          notifyListeners();
        }
      } else {
        // Handle error
        _dateFormat = 'MM-dd-yyyy'; // Reset to default
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveSelectedDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDateFormat', _dateFormat);
    await prefs.setInt('selectedDateIndex', dateformateselect);
  }

  Future<void> _loadSelectedDateFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedDateFormat = prefs.getString('selectedDateFormat');
    final selectedDateIndex = prefs.getInt('selectedDateIndex');

    if (selectedDateFormat != null && selectedDateIndex != null) {
      _dateFormat = selectedDateFormat;
      dateformateselect = selectedDateIndex;
      notifyListeners();
    }
  }
}








