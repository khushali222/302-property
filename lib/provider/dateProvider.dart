import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateProvider with ChangeNotifier {
  DateTime _currentDate = DateTime.now();
  String _dateFormat = 'dd-MM-yyyy';
  int dateformateselect = 0;// default date format

  DateTime get currentDate => _currentDate;
  String get dateFormat => _dateFormat;

  void updateDateFormat(String newFormat,selectindex) {
    _dateFormat = newFormat;
    dateformateselect = selectindex;
    print(_dateFormat);
    notifyListeners();
  }

  String formatCurrentDate(String dateTime) {

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


    return DateFormat(_dateFormat).format(parsedDate);
  }
}